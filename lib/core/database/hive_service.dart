import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../features/notes/data/models/note_model.dart';

class HiveService {
  static Future<void> initialize() async {
    // Initializes Hive with proper Flutter directory support
    await Hive.initFlutter();

    // Register adapter
    Hive.registerAdapter(NoteModelAdapter());

    // Open required boxes
    await Hive.openBox<NoteModel>('notes_box');
  }
}
