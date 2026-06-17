import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:syncnotes/app/app.dart';
import 'package:syncnotes/app/app_bloc_observer.dart';

import 'package:syncnotes/di/injection.dart';

import 'package:syncnotes/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:syncnotes/features/notes/presentation/bloc/notes_event.dart';

import 'package:syncnotes/sync/sync_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initDependencies();

  // Start background sync engine
  sl<SyncEngine>().initialize();

  // Register Bloc observer
  Bloc.observer = AppBlocObserver();

  // Launch app
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<NotesBloc>(
          create: (_) => sl<NotesBloc>()..add(const LoadNotesEvent()),
        ),
      ],
      child: const SyncNotesApp(),
    ),
  );
}
