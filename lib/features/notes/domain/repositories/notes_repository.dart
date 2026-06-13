import '../entities/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getNotes();

  Future<NoteEntity?> getNoteById(String id);

  Future<void> saveNote(NoteEntity note);

  Future<void> deleteNote(String id);
}
