import 'package:flutter/material.dart';

import '../features/notes/presentation/pages/notes_page.dart';
import '../core/theme/app_theme.dart';

class SyncNotesApp extends StatelessWidget {
  const SyncNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sync Notes',
      theme: AppTheme.light,
      home: const NotesPage(),
    );
  }
}
