import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/core/enums/sync_status.dart';

import 'package:syncnotes/features/notes/data/datasource/local/notes_local_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';

import 'package:syncnotes/features/sync/data/services/fake_api_service.dart';

import 'package:syncnotes/sync/conflict/conflict_model.dart';
import 'package:syncnotes/sync/conflict/conflict_resolution_strategy.dart';

import 'package:syncnotes/sync/sync_event.dart';
import 'package:syncnotes/sync/sync_event_bus.dart';

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
    try {
      switch (strategy) {
        case ConflictResolutionStrategy.keepLocal:
          await keepLocal(conflict);
          break;

        case ConflictResolutionStrategy.keepServer:
          await keepServer(conflict);
          break;

        case ConflictResolutionStrategy.merge:
          await merge(conflict);
          break;
      }
    } catch (e) {
      AppLogger.error("Conflict resolution failed", e);

      eventBus.emit(SyncEvent.error("Failed to resolve conflict"));

      rethrow;
    }
  }

  // ============================================================
  // KEEP LOCAL
  // ============================================================

  Future<void> keepLocal(ConflictModel conflict) async {
    AppLogger.log("🟢 Keeping local version");

    final local = conflict.localNote;

    final updated = local.copyWith(
      syncStatus: SyncStatus.synced.name,
      lastModifiedAt: DateTime.now().toUtc(),
    );

    await notesLocalDataSource.saveNote(updated);

    await apiService.saveServerNote(
      noteId: updated.id,
      title: updated.title,
      body: updated.body,
    );

    await _removeConflictOperation(updated.id);

    eventBus.emit(SyncEvent.operationSuccess(updated.id));

    AppLogger.success("Local version applied");
  }

  // ============================================================
  // KEEP SERVER
  // ============================================================

  Future<void> keepServer(ConflictModel conflict) async {
    AppLogger.log("🔵 Keeping server version");

    final server = conflict.serverNote;

    final updated = server.copyWith(
      syncStatus: SyncStatus.synced.name,
      lastModifiedAt: DateTime.now().toUtc(),
    );

    await notesLocalDataSource.saveNote(updated);

    await _removeConflictOperation(updated.id);

    eventBus.emit(SyncEvent.operationSuccess(updated.id));

    AppLogger.success("Server version applied");
  }

  // ============================================================
  // MERGE
  // ============================================================

  Future<void> merge(ConflictModel conflict) async {
    AppLogger.log("🟣 Merging versions");

    final local = conflict.localNote;
    final server = conflict.serverNote;

    final mergedTitle = local.title.length >= server.title.length
        ? local.title
        : server.title;

    final mergedBody =
        '''
${local.body}

-------------------------

${server.body}
''';

    final mergedNote = local.copyWith(
      title: mergedTitle,
      body: mergedBody,
      syncStatus: SyncStatus.synced.name,
      lastModifiedAt: DateTime.now().toUtc(),
    );

    await notesLocalDataSource.saveNote(mergedNote);

    await apiService.saveServerNote(
      noteId: mergedNote.id,
      title: mergedNote.title,
      body: mergedNote.body,
    );

    await _removeConflictOperation(mergedNote.id);

    eventBus.emit(SyncEvent.operationSuccess(mergedNote.id));

    AppLogger.success("Merge completed");
  }

  // ============================================================
  // REMOVE CONFLICT OPERATION
  // ============================================================

  Future<void> _removeConflictOperation(String noteId) async {
    final operations = await syncLocalDataSource.getOperations();

    for (final operation in operations) {
      if (operation.noteId == noteId && operation.status == "conflict") {
        await syncLocalDataSource.removeOperation(operation.id);
      }
    }
  }
}
