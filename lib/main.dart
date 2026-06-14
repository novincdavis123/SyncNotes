import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'di/injection.dart';

import 'features/notes/presentation/bloc/notes_bloc.dart';
import 'features/notes/presentation/bloc/notes_event.dart';

import 'sync/sync_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===========================
  // Dependency Injection
  // ===========================
  await initDependencies();

  // ===========================
  // Bloc Observer (debug only)
  // ===========================
  Bloc.observer = AppBlocObserver();

  // ===========================
  // Sync Engine START (AFTER DI)
  // ===========================
  final engine = sl<SyncEngine>();
  engine.initialize();

  // ===========================
  // RUN APP
  // ===========================
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
