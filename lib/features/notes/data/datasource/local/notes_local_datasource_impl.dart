import 'package:hive_ce/hive.dart';
import 'package:syncnotes/app/app_logger.dart';

import '../../models/note_model.dart';
import 'notes_local_datasource.dart';

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final Box<NoteModel> box;

  NotesLocalDataSourceImpl(this.box);

  @override
  Future<List<NoteModel>> getNotes() async {
    AppLogger.log("Box size: ${box.length}");
    AppLogger.log("Box values: ${box.values.toList()}");
    return box.values.toList();
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    try {
      return box.values.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    await box.put(note.id, note);
  }

  @override
  Future<void> deleteNote(String id) async {
    await box.delete(id);
  }

  @override
  Future<void> clear() async {
    await box.clear();
  }
}
