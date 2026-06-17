import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/features/notes/data/datasource/local/notes_local_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/remote/notes_remote_datasource.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';
import 'package:syncnotes/features/notes/data/models/note_model.dart';

import 'package:syncnotes/sync_manager/monitoring/sync_metrics_service.dart';
import 'package:syncnotes/sync_manager/retry/retry_decision.dart';
import 'package:syncnotes/sync_manager/retry/retry_policy.dart';
import 'package:syncnotes/sync_manager/retry/retry_utils.dart';
import 'package:syncnotes/sync_manager/retry/sync_failure_type.dart';

import 'package:syncnotes/features/sync/events/sync_event.dart';
import 'package:syncnotes/features/sync/events/sync_event_bus.dart';
import 'package:syncnotes/sync_manager/history/sync_history_repository.dart';
import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/features/conflict/data/conflict_detector.dart';
import 'package:syncnotes/features/conflict/data/conflict_resolution_service.dart';

class SyncService {
  final SyncLocalDataSource localDataSource;
  final NotesLocalDataSource notesLocalDataSource;
  final NotesRemoteDataSource remote;
  final SyncMetricsService metricsService;
  final SyncEventBus eventBus;
  final RetryPolicy retryPolicy;
  final SyncHistoryRepository historyRepository;
  final ConflictDetector conflictDetector;
  final ConflictResolutionService conflictService;

  bool _isRunning = false;

  SyncService(
    this.localDataSource,
    this.notesLocalDataSource,
    this.remote,
    this.metricsService,
    this.eventBus,
    this.historyRepository,
    this.conflictDetector,
    this.conflictService, {
    this.retryPolicy = const RetryPolicy(),
  });

  // =========================================================
  // MAIN SYNC ENTRY (UNCHANGED AS REQUESTED)
  // =========================================================

  Future<void> processQueue() async {
    if (_isRunning) {
      AppLogger.log("⛔ Sync already running");
      return;
    }

    _isRunning = true;
    AppLogger.log("🚀 SYNC STARTED");
    eventBus.emit(SyncEvent.started());

    try {
      final operations = await localDataSource.getOperations();
      AppLogger.log("📦 Total operations in queue: ${operations.length}");

      if (operations.isEmpty) {
        AppLogger.log("📭 No operations found");
        eventBus.emit(SyncEvent.empty());
        return;
      }

      final pending = operations.where((e) => e.isInProgress != true).toList();

      AppLogger.log("⏳ Pending operations: ${pending.length}");

      for (final op in pending) {
        try {
          await _processSingleOperation(op);
        } catch (e) {
          AppLogger.error("Operation failed: ${op.id}", e);
        }
      }

      AppLogger.success("🏁 SYNC COMPLETED");
      eventBus.emit(SyncEvent.completed());
    } finally {
      _isRunning = false;
    }
  }

  // =========================================================
  // PULL REMOTE → LOCAL (FIXED)
  // =========================================================

  Future<void> pullRemoteChanges() async {
    try {
      AppLogger.log("⬇️ PULL STARTED");

      final remoteNotes = await remote.fetchNotes();

      for (final data in remoteNotes) {
        final id = (data["id"] ?? "").toString();
        if (id.isEmpty) continue;

        final local = await notesLocalDataSource.getNoteById(id);

        // ======================================================
        // ❗ DELETE SAFETY FIX (IMPORTANT)
        // ======================================================
        if (local != null && local.isDeleted) {
          AppLogger.log("🗑️ Skipping deleted note: $id");
          continue;
        }

        // ======================================================
        // CONFLICT CHECK
        // ======================================================
        if (local != null) {
          final conflict = conflictDetector.detect(
            noteId: id,
            localData: {
              "id": local.id,
              "title": local.title,
              "body": local.body,
              "updatedAt": local.lastModifiedAt.toIso8601String(),
              "isModified": local.syncStatus != SyncStatus.synced.name,
            },
            remoteData: data,
          );

          if (conflict != null) {
            AppLogger.warning("🚨 CONFLICT DETECTED: $id");

            eventBus.emit(
              SyncEvent.conflictDetected(id: id, conflict: conflict),
            );

            continue;
          }
        }

        // ======================================================
        // NORMAL SYNC
        // ======================================================
        final model = NoteModel(
          id: id,
          title: (data["title"] ?? "").toString(),
          body: (data["body"] ?? "").toString(),
          createdAt:
              DateTime.tryParse(data["createdAt"] ?? "") ??
              DateTime.now().toUtc(),
          lastModifiedAt:
              DateTime.tryParse(data["updatedAt"] ?? "") ??
              DateTime.now().toUtc(),
          lastSyncedAt: DateTime.now().toUtc(),
          isDeleted: false,
          syncStatus: SyncStatus.synced.name,
        );

        await notesLocalDataSource.saveNote(model);
      }

      AppLogger.success("⬇️ PULL COMPLETED");
    } catch (e) {
      AppLogger.error("Pull failed", e);
    }
  }

  // =========================================================
  // PUSH OPERATION (UNCHANGED LOGIC)
  // =========================================================

  Future<void> _processSingleOperation(SyncOperationModel op) async {
    await localDataSource.addOperation(op.copyWith(isInProgress: true));

    eventBus.emit(SyncEvent.operationStarted(op.id));

    try {
      switch (op.type) {
        case "create":
          await remote.createNote({
            "id": op.noteId,
            "title": op.title,
            "body": op.body,
            "updatedAt": DateTime.now().toUtc().toIso8601String(),
          });
          break;

        case "update":
          await remote.updateNote(op.noteId, {
            "title": op.title,
            "body": op.body,
            "updatedAt": DateTime.now().toUtc().toIso8601String(),
          });
          break;

        case "delete":
          await remote.deleteNote(op.noteId);
          break;
      }

      await localDataSource.removeOperation(op.id);

      await historyRepository.addHistoryFromOperation(
        op,
        status: SyncStatus.synced,
      );

      metricsService.recordSuccess();
      eventBus.emit(SyncEvent.operationSuccess(op.id));
    } catch (e) {
      metricsService.recordFailure();
      await _handleFailure(op, SyncFailureType.network);
    }
  }

  // =========================================================
  // FAILURE + RECOVERY (UNCHANGED)
  // =========================================================

  Future<void> _handleFailure(
    SyncOperationModel op,
    SyncFailureType type,
  ) async {
    final retry = shouldRetryOperation(type, op.retryCount, retryPolicy);

    if (!retry) {
      await localDataSource.addOperation(
        op.copyWith(status: "failed", isInProgress: false),
      );
      return;
    }

    final delay = calculateDelay(retryPolicy, op.retryCount);

    await Future.delayed(delay);

    await localDataSource.addOperation(
      op.copyWith(
        status: "pending",
        retryCount: op.retryCount + 1,
        isInProgress: false,
        lastTriedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> recoverStuckOperations() async {
    final ops = await localDataSource.getOperations();

    for (final op in ops.where((e) => e.isInProgress == true)) {
      await localDataSource.addOperation(
        op.copyWith(status: "pending", isInProgress: false),
      );
    }
  }
}
