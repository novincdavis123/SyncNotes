import '../../models/note_model.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getNotes();

  Future<NoteModel?> getNoteById(String id);

  /// CREATE / UPDATE LOCAL NOTE (user action)
  Future<void> saveNote(NoteModel note);

  /// DELETE LOCAL NOTE (user action)
  Future<void> deleteNote(String id);

  /// CLEAR ALL LOCAL DATA (debug/reset)
  Future<void> clear();

  // =========================================================
  // SYNC SUPPORT (IMPORTANT ADDITION)
  // =========================================================

  /// UPSERT FROM SERVER (remote → local sync)
  /// Used when pulling data from API
  Future<void> upsertRemoteNote(NoteModel note);
}
