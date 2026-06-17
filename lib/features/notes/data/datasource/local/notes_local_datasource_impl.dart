import 'package:hive_ce/hive.dart';
import 'package:syncnotes/app/app_logger.dart';

import '../../models/note_model.dart';
import 'notes_local_datasource.dart';

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final Box<NoteModel> box;

  NotesLocalDataSourceImpl(this.box);

  // =========================================================
  // GET ALL NOTES
  // =========================================================

  @override
  Future<List<NoteModel>> getNotes() async {
    AppLogger.log("📦 Box size: ${box.length}");
    AppLogger.log("📦 Box values: ${box.values.toList()}");

    return box.values.toList();
  }

  // =========================================================
  // GET BY ID
  // =========================================================

  @override
  Future<NoteModel?> getNoteById(String id) async {
    try {
      return box.get(id);
    } catch (_) {
      return null;
    }
  }

  // =========================================================
  // SAVE (CREATE / UPDATE LOCAL)
  // =========================================================

  @override
  Future<void> saveNote(NoteModel note) async {
    await box.put(note.id, note);
    AppLogger.log("💾 Saved local note: ${note.id}");
  }

  // =========================================================
  // DELETE LOCAL
  // =========================================================

  @override
  Future<void> deleteNote(String id) async {
    await box.delete(id);
    AppLogger.log("🗑️ Deleted local note: $id");
  }

  // =========================================================
  // CLEAR ALL
  // =========================================================

  @override
  Future<void> clear() async {
    await box.clear();
    AppLogger.log("🧹 Cleared notes box");
  }

  // =========================================================
  // IMPORTANT: REMOTE UPSERT SUPPORT (ADDED)
  // =========================================================

  @override
  Future<void> upsertRemoteNote(NoteModel note) async {
    final existing = box.get(note.id);

    if (existing == null) {
      await box.put(note.id, note);
      AppLogger.log("⬇️ Remote INSERT → local: ${note.id}");
      return;
    }

    final updated = existing.copyWith(
      title: note.title,
      body: note.body,
      lastModifiedAt: note.lastModifiedAt,
      lastSyncedAt: DateTime.now().toUtc(),
      syncStatus: note.syncStatus,
    );

    await box.put(note.id, updated);

    AppLogger.log("🔄 Remote UPDATE → local: ${note.id}");
  }
}
