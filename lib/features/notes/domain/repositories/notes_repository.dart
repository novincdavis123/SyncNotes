import '../entities/note_entity.dart';

abstract class NotesRepository {
  // =========================
  // CORE CRUD
  // =========================
  Future<List<NoteEntity>> getNotes();

  Future<NoteEntity?> getNoteById(String id);

  Future<void> saveNote(NoteEntity note);

  Future<void> deleteNote(String id);

  // =========================
  // 🔥 SYNC SUPPORT
  // =========================

  /// Remove pending sync operations for a deleted/updated note
  Future<void> removePendingOperationsForNote(String noteId);

  /// Mark system dirty so SyncEngine triggers safely
  Future<void> markSyncDirty();

  /// Force refresh from server (used after conflicts)
  Future<void> refreshFromServer();

  // =========================
  // 🔥 CONFLICT SAFETY
  // =========================

  /// Check if note is safe for sync (not deleted / not stale)
  Future<bool> isSyncSafe(String noteId);
}
