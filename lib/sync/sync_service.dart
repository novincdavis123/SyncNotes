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

class SyncService {
  final SyncLocalDataSource localDataSource;
  final NotesLocalDataSource notesLocalDataSource;
  final FakeApiService apiService;
  final SyncMetricsService metricsService;
  final SyncEventBus eventBus;
  final RetryPolicy retryPolicy;

  bool _isRunning = false;

  final int _maxConcurrentTasks = 3;
  int _activeTasks = 0;

  final Set<String> _processingIds = {};

  SyncService(
    this.localDataSource,
    this.notesLocalDataSource,
    this.apiService,
    this.metricsService,
    this.eventBus, {
    this.retryPolicy = const RetryPolicy(),
  });

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

      final batch = _sortOperations(
        operations.where((e) => !e.isInProgress).toList(),
      ).take(10).toList();

      for (final operation in batch) {
        try {
          await _processSingleOperation(operation);
        } catch (e) {
          eventBus.emit(SyncEvent.error(e.toString()));
        }
      }

      metricsService.printStatistics();

      eventBus.emit(SyncEvent.completed());
    } catch (e) {
      eventBus.emit(SyncEvent.error(e.toString()));
    } finally {
      _isRunning = false;
    }
  }

  List<SyncOperationModel> _sortOperations(
    List<SyncOperationModel> operations,
  ) {
    final sorted = List<SyncOperationModel>.from(operations);

    sorted.sort((a, b) {
      if (a.status != b.status) {
        if (a.status == "pending") return -1;
        if (b.status == "pending") return 1;
      }

      if (a.retryCount != b.retryCount) {
        return a.retryCount.compareTo(b.retryCount);
      }

      return a.timestamp.compareTo(b.timestamp);
    });

    return sorted;
  }

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

  Future<void> _processInternal(SyncOperationModel operation) async {
    bool synced = false;

    try {
      await localDataSource.addOperation(
        operation.copyWith(isInProgress: true),
      );

      eventBus.emit(SyncEvent.operationStarted(operation.id));

      // =====================================================
      // STEP 8 REAL CONFLICT DETECTION
      // =====================================================

      final localNote = await notesLocalDataSource.getNoteById(
        operation.noteId,
      );

      final serverNote = await apiService.fetchNote(operation.noteId);

      if (localNote != null && serverNote != null) {
        final localTime = localNote.lastModifiedAt.toUtc();

        final serverTime = DateTime.parse(serverNote["updatedAt"]).toUtc();

        if (serverTime.isAfter(localTime)) {
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

          AppLogger.log("⚠️ Conflict detected ${operation.id}");

          return;
        }
      }

      // =====================================================
      // NORMAL SYNC
      // =====================================================

      final success = await apiService.pushToServer(operation);

      if (success) {
        synced = true;

        metricsService.recordSuccess();

        eventBus.emit(SyncEvent.operationSuccess(operation.id));

        await localDataSource.removeOperation(operation.id);

        AppLogger.success("✅ Synced ${operation.id}");

        return;
      }

      metricsService.recordFailure();

      await _handleFailure(operation, SyncFailureType.server);
    } catch (e) {
      metricsService.recordFailure();

      await _handleFailure(operation, SyncFailureType.network);

      AppLogger.error("Sync error ${operation.id}", e);
    } finally {
      if (!synced) {
        await localDataSource.addOperation(
          operation.copyWith(isInProgress: false),
        );
      }
    }
  }

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
