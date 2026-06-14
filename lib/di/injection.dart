import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/adapters.dart';

import 'package:syncnotes/features/notes/data/models/note_model.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';

import 'package:syncnotes/features/notes/data/datasource/local/notes_local_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/local/notes_local_datasource_impl.dart';

import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource_impl.dart';

import 'package:syncnotes/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:syncnotes/features/notes/domain/repositories/notes_repository.dart';

import 'package:syncnotes/features/notes/data/repositories/sync_repository_impl.dart';
import 'package:syncnotes/features/notes/domain/repositories/sync_repository.dart';

import 'package:syncnotes/features/notes/domain/usecases/get_notes.dart';
import 'package:syncnotes/features/notes/domain/usecases/get_note_by_id.dart';
import 'package:syncnotes/features/notes/domain/usecases/save_note.dart';
import 'package:syncnotes/features/notes/domain/usecases/delete_note.dart';

import 'package:syncnotes/features/notes/domain/usecases/add_sync_operation.dart';

import 'package:syncnotes/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:syncnotes/features/notes/presentation/bloc/note_editor_cubit.dart';
import 'package:syncnotes/features/notes/presentation/bloc/delete_note_cubit.dart';

import 'package:syncnotes/features/sync/data/services/fake_api_service.dart';

import 'package:syncnotes/sync/sync_service.dart';
import 'package:syncnotes/sync/sync_engine.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ===========================
  // Hive Initialization
  // ===========================

  await Hive.initFlutter();

  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(SyncOperationModelAdapter());

  // ===========================
  // Boxes
  // ===========================

  final notesBox = await Hive.openBox<NoteModel>('notes_box');
  final syncBox = await Hive.openBox<SyncOperationModel>('sync_queue_box');

  sl.registerLazySingleton<Box<NoteModel>>(() => notesBox);
  sl.registerLazySingleton<Box<SyncOperationModel>>(() => syncBox);

  // ===========================
  // Data Sources
  // ===========================

  sl.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<SyncLocalDataSource>(
    () => SyncLocalDataSourceImpl(sl()),
  );

  // ===========================
  // Services
  // ===========================

  sl.registerLazySingleton(() => FakeApiService());

  sl.registerLazySingleton<SyncService>(
    () => SyncService(sl<SyncLocalDataSource>(), sl<FakeApiService>()),
  );

  // ===========================
  // Repositories
  // ===========================

  sl.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(sl<SyncLocalDataSource>(), sl<SyncService>()),
  );

  // ===========================
  // Use Cases
  // ===========================

  sl.registerLazySingleton(() => GetNotesUseCase(sl()));
  sl.registerLazySingleton(() => GetNoteByIdUseCase(sl()));
  sl.registerLazySingleton(() => SaveNoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNoteUseCase(sl()));

  sl.registerLazySingleton(() => AddSyncOperation(sl()));

  // ===========================
  // Blocs / Cubits
  // ===========================

  sl.registerFactory(
    () => NotesBloc(
      getNotesUseCase: sl(),
      saveNoteUseCase: sl(),
      deleteNoteUseCase: sl(),
    ),
  );

  sl.registerFactory(() => NoteEditorCubit(saveNoteUseCase: sl()));
  sl.registerFactory(() => DeleteNoteCubit(deleteNoteUseCase: sl()));

  // ===========================
  // Sync Engine (IMPORTANT FIX)
  // ===========================

  sl.registerLazySingleton<SyncEngine>(() => SyncEngine(sl<SyncService>()));
}
