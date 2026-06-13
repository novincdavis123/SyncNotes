import '../../models/note_model.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getNotes();

  Future<NoteModel?> getNoteById(String id);

  Future<void> saveNote(NoteModel note);

  Future<void> deleteNote(String id);

  Future<void> clear();
}
