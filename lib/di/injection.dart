import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/adapters.dart';

import 'package:syncnotes/features/notes/presentation/bloc/delete_note_cubit.dart';
import 'package:syncnotes/features/notes/presentation/bloc/note_editor_cubit.dart';
import 'package:syncnotes/features/notes/presentation/bloc/notes_bloc.dart';

import '../features/notes/data/datasource/local/notes_local_datasource.dart';
import '../features/notes/data/datasource/local/notes_local_datasource_impl.dart';

import '../features/notes/data/repositories/notes_repository_impl.dart';
import '../features/notes/domain/repositories/notes_repository.dart';

import '../features/notes/domain/usecases/delete_note.dart';
import '../features/notes/domain/usecases/get_note_by_id.dart';
import '../features/notes/domain/usecases/get_notes.dart';
import '../features/notes/domain/usecases/save_note.dart';

import '../features/notes/data/models/note_model.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ===========================
  // Hive Initialization
  // ===========================

  await Hive.initFlutter();

  Hive.registerAdapter(NoteModelAdapter());

  final notesBox = await Hive.openBox<NoteModel>('notes_box');

  sl.registerLazySingleton<Box<NoteModel>>(() => notesBox);

  // ===========================
  // Data Sources
  // ===========================

  sl.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(sl()),
  );

  // ===========================
  // Repository
  // ===========================

  sl.registerLazySingleton<NotesRepository>(() => NotesRepositoryImpl(sl()));

  // ===========================
  // Use Cases
  // ===========================

  sl.registerLazySingleton(() => GetNotesUseCase(sl()));
  sl.registerLazySingleton(() => GetNoteByIdUseCase(sl()));
  sl.registerLazySingleton(() => SaveNoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNoteUseCase(sl()));

  // ===========================
  // Bloc
  // ===========================

  sl.registerFactory<NotesBloc>(
    () => NotesBloc(
      getNotesUseCase: sl(),
      saveNoteUseCase: sl(),
      deleteNoteUseCase: sl(),
    ),
  );

  sl.registerFactory(() => NoteEditorCubit(saveNoteUseCase: sl()));

  sl.registerFactory(() => DeleteNoteCubit(deleteNoteUseCase: sl()));
}
