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

      // ======================================================
      // THEME (READY FOR DARK MODE LATER)
      // ======================================================
      theme: AppTheme.light,
      themeMode: ThemeMode.light,

      // ======================================================
      // NAVIGATION (SCAFFOLD FOR FUTURE ROUTES)
      // ======================================================
      initialRoute: '/',
      routes: {'/': (_) => const NotesPage()},

      // ======================================================
      // OPTIONAL: GLOBAL NAV KEY (useful for sync-driven flows)
      // ======================================================
      navigatorKey: GlobalKey<NavigatorState>(),
    );
  }
}
