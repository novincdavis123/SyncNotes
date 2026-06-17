import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/core/network/fake_api_service.dart';

import 'package:syncnotes/features/notes/data/datasource/local/notes_local_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';

import 'package:syncnotes/features/conflict/data/models/conflict_model.dart';
import 'package:syncnotes/features/conflict/domain/enums/conflict_resolution_strategy.dart';

import 'package:syncnotes/features/sync/events/sync_event.dart';
import 'package:syncnotes/features/sync/events/sync_event_bus.dart';

class ConflictResolutionService {
  final NotesLocalDataSource notesLocalDataSource;
  final SyncLocalDataSource syncLocalDataSource;
  final FakeApiService apiService;
  final SyncEventBus eventBus;

  const ConflictResolutionService({
    required this.notesLocalDataSource,
    required this.syncLocalDataSource,
    required this.apiService,
    required this.eventBus,
  });

  // ============================================================
  // MAIN ENTRY
  // ============================================================

  Future<void> resolveConflict({
    required ConflictModel conflict,
    required ConflictResolutionStrategy strategy,
  }) async {
    AppLogger.log("⚔️ Conflict resolution started for: ${conflict.noteId}");
    AppLogger.log("📌 Strategy: $strategy");

    try {
      switch (strategy) {
        case ConflictResolutionStrategy.keepLocal:
          AppLogger.log("🟢 Selected: KEEP LOCAL");
          await _keepLocal(conflict);
          break;

        case ConflictResolutionStrategy.keepServer:
          AppLogger.log("🔵 Selected: KEEP SERVER");
          await _keepServer(conflict);
          break;

        case ConflictResolutionStrategy.merge:
          AppLogger.log("🟣 Selected: MERGE");
          await _merge(conflict);
          break;
      }

      AppLogger.success("✅ Conflict resolved: ${conflict.noteId}");
    } catch (e) {
      AppLogger.error("❌ Conflict resolution failed", e);

      eventBus.emit(
        SyncEvent.error("Conflict resolution failed: ${e.toString()}"),
      );

      rethrow;
    }
  }

  // ============================================================
  // KEEP LOCAL
  // ============================================================

  Future<void> _keepLocal(ConflictModel conflict) async {
    AppLogger.log("🟢 Applying LOCAL version");

    final local = conflict.localNote;

    AppLogger.log("📄 Local title: ${local.title}");
    AppLogger.log("📄 Local body length: ${local.body.length}");

    final updated = local.copyWith(
      syncStatus: SyncStatus.synced.name,
      lastModifiedAt: DateTime.now().toUtc(),
      conflictResolution: "localWins", // ✅ ADD THIS
    );

    await notesLocalDataSource.saveNote(updated);
    AppLogger.log("💾 Local saved to DB");

    await apiService.saveServerNote(
      noteId: updated.id,
      title: updated.title,
      body: updated.body,
    );

    AppLogger.log("☁️ Server overwritten with local version");

    await _removeConflictOperation(updated.id);

    eventBus.emit(SyncEvent.operationSuccess(updated.id));

    AppLogger.success("🟢 KEEP LOCAL completed");
  }

  // ============================================================
  // KEEP SERVER
  // ============================================================

  Future<void> _keepServer(ConflictModel conflict) async {
    AppLogger.log("🔵 Applying SERVER version");

    final server = conflict.serverNote;

    final updated = server.copyWith(
      syncStatus: SyncStatus.synced.name,
      lastModifiedAt: DateTime.now().toUtc(),
    );

    // =========================================================
    // 1. SAVE TO LOCAL DB
    // =========================================================
    await notesLocalDataSource.saveNote(updated);

    AppLogger.log("💾 Server version saved locally");

    // =========================================================
    // 2. CLEAN CONFLICT OPERATION
    // =========================================================
    await _removeConflictOperation(updated.id);

    // =========================================================
    // 3. NOTIFY SYNC SYSTEM
    // =========================================================
    eventBus.emit(SyncEvent.operationSuccess(updated.id));

    // =========================================================
    // 4. 🔥 CRITICAL FIX: FORCE UI REFRESH
    // =========================================================
    eventBus.emit(SyncEvent.syncRefresh());

    AppLogger.success("🔵 KEEP SERVER completed");
  }

  // ============================================================
  // MERGE
  // ============================================================

  Future<void> _merge(ConflictModel conflict) async {
    AppLogger.log("🟣 MERGE STARTED");

    final local = conflict.localNote;
    final server = conflict.serverNote;

    AppLogger.log("📄 Local length: ${local.body.length}");
    AppLogger.log("📄 Server length: ${server.body.length}");

    final mergedTitle = (local.title.length >= server.title.length)
        ? local.title
        : server.title;

    final mergedBody = [
      local.body,
      "-------------------------",
      server.body,
    ].join("\n");

    final mergedNote = local.copyWith(
      title: mergedTitle,
      body: mergedBody,
      syncStatus: SyncStatus.synced.name,
      lastModifiedAt: DateTime.now().toUtc(),
      conflictResolution: "merged", // ✅ ADD THIS
    );

    await notesLocalDataSource.saveNote(mergedNote);
    AppLogger.log("💾 Merged note saved locally");

    await apiService.saveServerNote(
      noteId: mergedNote.id,
      title: mergedNote.title,
      body: mergedNote.body,
    );

    AppLogger.log("☁️ Merged note pushed to server");

    await _removeConflictOperation(mergedNote.id);

    eventBus.emit(SyncEvent.operationSuccess(mergedNote.id));

    AppLogger.success("🟣 MERGE completed");
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  Future<void> _removeConflictOperation(String noteId) async {
    AppLogger.log("🧹 Cleaning conflict operations for: $noteId");

    final operations = await syncLocalDataSource.getOperations();

    for (final op in operations) {
      if (op.noteId == noteId && op.status == "conflict") {
        await syncLocalDataSource.removeOperation(op.id);
        AppLogger.log("🗑️ Removed conflict op: ${op.id}");
      }
    }

    AppLogger.success("🧹 Cleanup completed");
  }
}
