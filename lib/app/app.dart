import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:syncnotes/di/injection.dart';
import 'package:syncnotes/features/conflict/presentation/conflict_screen.dart';
import 'package:syncnotes/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:syncnotes/features/notes/presentation/bloc/notes_event.dart';
import 'package:syncnotes/features/sync/events/sync_event.dart';

import '../features/notes/presentation/pages/notes_page.dart';
import '../core/theme/app_theme.dart';

import 'package:syncnotes/features/sync/events/sync_event_bus.dart';
import 'package:syncnotes/app/app_logger.dart';

// 👉 IMPORTANT: used for navigation from background services
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SyncNotesApp extends StatefulWidget {
  const SyncNotesApp({super.key});

  @override
  State<SyncNotesApp> createState() => _SyncNotesAppState();
}

class _SyncNotesAppState extends State<SyncNotesApp> {
  late final StreamSubscription _eventSub;

  @override
  void initState() {
    super.initState();

    final bus = sl<SyncEventBus>();

    // 🚨 GLOBAL EVENT LISTENER (IMPORTANT FOR CONFLICT SCREEN)
    _eventSub = bus.stream.listen((event) {
      if (event is SyncEvent && event.type == SyncEventType.conflictDetected) {
        AppLogger.warning("🚨 Conflict event received in UI layer");

        final context = navigatorKey.currentContext;

        if (context != null) {
          final conflict = event.meta?['conflict'];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConflictScreen(conflict: conflict),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _eventSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotesBloc>(
          create: (_) => sl<NotesBloc>()..add(const LoadNotesEvent()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sync Notes',
        theme: AppTheme.light,
        themeMode: ThemeMode.light,

        navigatorKey: navigatorKey, // 🔥 IMPORTANT FIX

        initialRoute: '/',
        routes: {'/': (_) => const NotesPage()},
      ),
    );
  }
}
