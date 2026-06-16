import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/features/notes/data/datasource/local/notes_local_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';
import 'package:syncnotes/features/notes/data/mapper/note_mapper.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';
import 'package:syncnotes/features/notes/domain/entities/note_entity.dart';
import 'package:syncnotes/features/notes/domain/entities/sync_operation_type.dart';
import 'package:syncnotes/features/notes/domain/repositories/notes_repository.dart';
import 'package:uuid/uuid.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;
  final SyncLocalDataSource syncLocalDataSource;

  const NotesRepositoryImpl(this.localDataSource, this.syncLocalDataSource);

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

    if (model == null) {
      return null;
    }

    return model.toEntity();
  }

  @override
  Future<void> saveNote(NoteEntity note) async {
    AppLogger.sync("Adding operation for note: ${note.id}");

    await localDataSource.saveNote(note.toModel());

    await _addSync(note: note, type: SyncOperationType.create);
  }

  @override
  Future<void> deleteNote(String id) async {
    final noteModel = await localDataSource.getNoteById(id);

    if (noteModel == null) {
      return;
    }

    final updated = noteModel.copyWith(
      isDeleted: true,
      lastModifiedAt: DateTime.now().toUtc(),
      syncStatus: SyncStatus.pending.name,
    );

    await localDataSource.saveNote(updated);

    await _addSync(note: updated.toEntity(), type: SyncOperationType.delete);
  }

  // ============================================================
  // STEP 7 SYNC QUEUE CREATION
  // ============================================================

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

        // Step 7 fields
        title: note.title,
        body: note.body,
      ),
    );
  }
}
