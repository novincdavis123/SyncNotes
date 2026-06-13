import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'di/injection.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';
import 'features/notes/presentation/bloc/notes_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection and local database
  await initDependencies();

  // Global Bloc observer for debugging
  Bloc.observer = AppBlocObserver();

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
