import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/features/notes/data/datasource/local/notes_local_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';
import 'package:syncnotes/features/sync/data/services/fake_api_service.dart';

import 'package:syncnotes/sync/monitoring/sync_metrics_service.dart';
import 'package:syncnotes/sync/retry/retry_decision.dart';
import 'package:syncnotes/sync/retry/retry_policy.dart';
import 'package:syncnotes/sync/retry/retry_utils.dart';
import 'package:syncnotes/sync/retry/sync_failure_type.dart';

import 'package:syncnotes/sync/sync_event.dart';
import 'package:syncnotes/sync/sync_event_bus.dart';
import 'package:syncnotes/sync/history/sync_history_repository.dart';
import 'package:syncnotes/core/enums/sync_status.dart';

class SyncService {
  final SyncLocalDataSource localDataSource;
  final NotesLocalDataSource notesLocalDataSource;
  final FakeApiService apiService;
  final SyncMetricsService metricsService;
  final SyncEventBus eventBus;
  final RetryPolicy retryPolicy;
  final SyncHistoryRepository historyRepository;

  bool _isRunning = false;

  final int _maxConcurrentTasks = 3;
  int _activeTasks = 0;

  final Set<String> _processingIds = {};

  SyncService(
    this.localDataSource,
    this.notesLocalDataSource,
    this.apiService,
    this.metricsService,
    this.eventBus,
    this.historyRepository, {
    this.retryPolicy = const RetryPolicy(),
  });

  // ============================================================
  // STEP 2: PROCESS QUEUE (STABLE FINAL VERSION)
  // ============================================================

  Future<void> processQueue() async {
    if (_isRunning) return;

    _isRunning = true;
    eventBus.emit(SyncEvent.started());

    try {
      final operations = await localDataSource.getOperations();

      if (operations.isEmpty) {
        eventBus.emit(SyncEvent.empty());
        return;
      }

      final pendingOps = operations
          .where((e) => !e.isInProgress)
          .toList(growable: false);

      final batch = _sortOperations(pendingOps).take(10).toList();

      for (final operation in batch) {
        try {
          await _processSingleOperation(operation);
        } catch (e) {
          AppLogger.error("Sync operation failed", e);
          eventBus.emit(SyncEvent.error(e.toString()));
        }
      }

      metricsService.printStatistics();
      eventBus.emit(SyncEvent.completed());
    } catch (e) {
      AppLogger.error("Sync queue failed", e);
      eventBus.emit(SyncEvent.error(e.toString()));
    } finally {
      _isRunning = false;
    }
  }

  // ============================================================
  // SAFE SORTING
  // ============================================================

  List<SyncOperationModel> _sortOperations(
    List<SyncOperationModel> operations,
  ) {
    final sorted = List<SyncOperationModel>.from(operations);

    sorted.sort((a, b) {
      final retryCompare = a.retryCount.compareTo(b.retryCount);
      if (retryCompare != 0) return retryCompare;

      return a.timestamp.compareTo(b.timestamp);
    });

    return sorted;
  }

  // ============================================================
  // SINGLE OPERATION
  // ============================================================

  Future<void> _processSingleOperation(SyncOperationModel operation) async {
    if (_processingIds.contains(operation.id)) return;
    if (_activeTasks >= _maxConcurrentTasks) return;

    _processingIds.add(operation.id);
    _activeTasks++;

    try {
      await _processInternal(operation);
    } finally {
      _processingIds.remove(operation.id);
      _activeTasks--;
    }
  }

  // ============================================================
  // CORE SYNC LOGIC
  // ============================================================

  Future<void> _processInternal(SyncOperationModel operation) async {
    bool synced = false;

    try {
      await localDataSource.addOperation(
        operation.copyWith(isInProgress: true),
      );

      eventBus.emit(SyncEvent.operationStarted(operation.id));

      // -----------------------------
      // CONFLICT DETECTION (SAFE)
      // -----------------------------

      final localNote = await notesLocalDataSource.getNoteById(
        operation.noteId,
      );

      final serverNote = await apiService.fetchNote(operation.noteId);

      if (localNote != null && serverNote != null) {
        final localTime = localNote.lastModifiedAt.toUtc();

        final serverTimeStr = serverNote["updatedAt"]?.toString();
        final serverTime = serverTimeStr != null
            ? DateTime.tryParse(serverTimeStr)
            : null;

        if (serverTime != null && serverTime.toUtc().isAfter(localTime)) {
          eventBus.emit(
            SyncEvent.conflictDetected(
              id: operation.id,
              meta: {
                "local": {
                  "id": localNote.id,
                  "title": localNote.title,
                  "body": localNote.body,
                  "updatedAt": localTime.toIso8601String(),
                },
                "remote": serverNote,
              },
            ),
          );

          await localDataSource.addOperation(
            operation.copyWith(status: "conflict", isInProgress: false),
          );
          await historyRepository.addHistoryFromOperation(
            operation,
            status: SyncStatus.conflict,
            hadConflict: true,
          );
          AppLogger.log("⚠️ Conflict detected ${operation.id}");
          return;
        }
      }

      // -----------------------------
      // PUSH TO SERVER
      // -----------------------------

      final success = await apiService.pushToServer(operation);

      if (success) {
        synced = true;

        metricsService.recordSuccess();

        await historyRepository.addHistoryFromOperation(
          operation,
          status: SyncStatus.synced,
        );

        eventBus.emit(SyncEvent.operationSuccess(operation.id));

        await localDataSource.removeOperation(operation.id);

        AppLogger.success("✅ Synced ${operation.id}");
        return;
      }

      metricsService.recordFailure();
      await _handleFailure(operation, SyncFailureType.server);
    } catch (e) {
      AppLogger.error("Sync error ${operation.id}", e);

      metricsService.recordFailure();

      await _handleFailure(operation, SyncFailureType.network);
    } finally {
      if (!synced) {
        await localDataSource.addOperation(
          operation.copyWith(isInProgress: false),
        );
      }
    }
  }

  // ============================================================
  // FAILURE HANDLING
  // ============================================================

  Future<void> _handleFailure(
    SyncOperationModel operation,
    SyncFailureType type,
  ) async {
    final retry = shouldRetryOperation(type, operation.retryCount, retryPolicy);

    if (!retry) {
      eventBus.emit(
        SyncEvent.permanentFailure(
          operation.id,
          "Operation permanently failed",
        ),
      );

      await localDataSource.addOperation(
        operation.copyWith(status: "failed", isInProgress: false),
      );

      await historyRepository.addHistoryFromOperation(
        operation,
        status: SyncStatus.failed,
        errorMessage: "Operation permanently failed",
      );

      return;
    }

    metricsService.recordRetry();

    final delay = calculateDelay(retryPolicy, operation.retryCount);

    eventBus.emit(
      SyncEvent.retryScheduled(
        id: operation.id,
        attempt: operation.retryCount + 1,
        delay: delay,
      ),
    );
    await historyRepository.addHistoryFromOperation(
      operation,
      status: SyncStatus.pending,
    );
    await Future.delayed(delay);

    await localDataSource.addOperation(
      operation.copyWith(
        status: "pending",
        retryCount: operation.retryCount + 1,
        lastTriedAt: DateTime.now().toUtc(),
        isInProgress: false,
      ),
    );
  }

  // ============================================================
  // RECOVERY
  // ============================================================

  Future<void> recoverStuckOperations() async {
    final operations = await localDataSource.getOperations();

    for (final operation in operations) {
      if (!operation.isInProgress) continue;

      await localDataSource.addOperation(
        operation.copyWith(status: "pending", isInProgress: false),
      );
    }
  }
}
