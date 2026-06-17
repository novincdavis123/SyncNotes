import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/di/injection.dart';
import 'package:syncnotes/features/notes/data/datasource/local/notes_local_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';
import 'package:syncnotes/features/notes/data/mapper/note_mapper.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';
import 'package:syncnotes/features/notes/domain/entities/note_entity.dart';
import 'package:syncnotes/features/notes/domain/entities/sync_operation_type.dart';
import 'package:syncnotes/features/notes/domain/repositories/notes_repository.dart';
import 'package:syncnotes/features/sync/engine/sync_engine.dart';
import 'package:uuid/uuid.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;
  final SyncLocalDataSource syncLocalDataSource;

  const NotesRepositoryImpl(this.localDataSource, this.syncLocalDataSource);

  // =========================================================
  // CORE CRUD
  // =========================================================

  @override
  Future<List<NoteEntity>> getNotes() async {
    final models = await localDataSource.getNotes();

    return models
        .where((note) => !note.isDeleted)
        .map((e) => e.toEntity())
        .toList();
  }

  @override
  Future<NoteEntity?> getNoteById(String id) async {
    final model = await localDataSource.getNoteById(id);

    if (model == null) return null;

    return model.toEntity();
  }

  @override
  Future<void> saveNote(NoteEntity note) async {
    AppLogger.sync("Adding operation for note: ${note.id}");

    final existing = await localDataSource.getNoteById(note.id);

    // ✅ RESET CONFLICT STATE ON NEW USER EDIT
    final updatedNote = note.copyWith(conflictResolution: null);

    await localDataSource.saveNote(updatedNote.toModel());

    await _addSync(
      note: updatedNote,
      type: existing == null
          ? SyncOperationType.create
          : SyncOperationType.update,
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    final noteModel = await localDataSource.getNoteById(id);

    if (noteModel == null) return;

    final updated = noteModel.copyWith(
      isDeleted: true,
      lastModifiedAt: DateTime.now().toUtc(),
      syncStatus: SyncStatus.pending.name,
    );

    await localDataSource.saveNote(updated);

    await _addSync(note: updated.toEntity(), type: SyncOperationType.delete);
  }

  // =========================================================
  // SYNC QUEUE CREATION
  // =========================================================

  Future<void> _addSync({
    required NoteEntity note,
    required SyncOperationType type,
  }) async {
    await syncLocalDataSource.addOperation(
      SyncOperationModel(
        id: const Uuid().v4(),
        noteId: note.id,
        type: type.name,
        timestamp: DateTime.now().toUtc(),
        status: SyncStatus.pending.name,
        retryCount: 0,
        lastTriedAt: null,
        isInProgress: false,
        title: note.title,
        body: note.body,
      ),
    );

    AppLogger.sync("Queue updated");

    sl<SyncEngine>().markDirty();
  }

  // =========================================================
  // 🔥 NEW METHODS (FIXED IMPLEMENTATIONS)
  // =========================================================

  @override
  Future<void> removePendingOperationsForNote(String noteId) async {
    final ops = await syncLocalDataSource.getOperations();

    for (final op in ops) {
      if (op.noteId == noteId) {
        await syncLocalDataSource.deleteOperation(op.id);
      }
    }

    AppLogger.log("🧹 Removed pending ops for: $noteId");
  }

  @override
  Future<void> markSyncDirty() async {
    sl<SyncEngine>().markDirty();
  }

  @override
  Future<void> refreshFromServer() async {
    AppLogger.log("🔄 Refresh from server triggered");

    // optional: you can hook remote fetch here later
    sl<SyncEngine>().syncNow();
  }

  @override
  Future<bool> isSyncSafe(String noteId) async {
    final ops = await syncLocalDataSource.getOperations();

    final hasPendingOps = ops.any((op) => op.noteId == noteId);

    final note = await localDataSource.getNoteById(noteId);

    if (note == null) return true;

    return !hasPendingOps && !note.isDeleted;
  }
}
