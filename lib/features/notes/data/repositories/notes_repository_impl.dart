import 'package:syncnotes/core/enums/sync_status.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasource/local/notes_local_datasource.dart';
import '../mapper/note_mapper.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  const NotesRepositoryImpl(this.localDataSource);

  @override
  Future<List<NoteEntity>> getNotes() async {
    final models = await localDataSource.getNotes();

    return models
        .where((note) => note.isDeleted == false)
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
    await localDataSource.saveNote(note.toModel());
  }

  @override
  Future<void> deleteNote(String id) async {
    final note = await localDataSource.getNoteById(id);

    if (note == null) return;

    final updated = note.copyWith(
      isDeleted: true,
      lastModifiedAt: DateTime.now().toUtc(),
      syncStatus: SyncStatus.pending.name,
    );

    await localDataSource.saveNote(updated);
  }
}
