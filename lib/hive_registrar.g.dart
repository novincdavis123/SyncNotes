import 'package:hive_ce/hive.dart';
import 'package:syncnotes/features/notes/data/models/note_model.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(NoteModelAdapter());
    registerAdapter(SyncOperationModelAdapter());
  }
}
