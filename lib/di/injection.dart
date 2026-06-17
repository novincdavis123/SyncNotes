import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/adapters.dart';

import 'package:syncnotes/core/network/connectivity_service.dart';
import 'package:syncnotes/core/network/connectivity_service_impl.dart';
import 'package:syncnotes/core/network/fake_api_service.dart';

import 'package:syncnotes/features/notes/data/models/note_model.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';

import 'package:syncnotes/features/notes/data/datasource/local/notes_local_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/local/notes_local_datasource_impl.dart';

import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource_impl.dart';

import 'package:syncnotes/features/notes/data/datasource/remote/notes_remote_datasource.dart';
import 'package:syncnotes/features/notes/data/datasource/remote/notes_remote_datasource_impl.dart';

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

import 'package:syncnotes/features/sync/engine/sync_engine.dart';
import 'package:syncnotes/features/sync/service/sync_service.dart';
import 'package:syncnotes/features/sync/events/sync_event_bus.dart';

import 'package:syncnotes/sync_manager/monitoring/sync_status_service.dart';
import 'package:syncnotes/sync_manager/monitoring/sync_queue_monitor.dart';
import 'package:syncnotes/sync_manager/monitoring/sync_health_checker.dart';
import 'package:syncnotes/sync_manager/monitoring/sync_metrics_service.dart';

import 'package:syncnotes/features/conflict/data/conflict_detector.dart';
import 'package:syncnotes/features/conflict/data/conflict_resolution_service.dart';
import 'package:syncnotes/sync_manager/history/sync_history_repository.dart';
import 'package:syncnotes/sync_manager/queue/sync_queue_analyzer.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ============================================================
  // HIVE INIT
  // ============================================================

  await Hive.initFlutter();

  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(SyncOperationModelAdapter());

  final notesBox = await Hive.openBox<NoteModel>('notes_box');
  final syncBox = await Hive.openBox<SyncOperationModel>('sync_queue_box');
  final historyBox = await Hive.openBox('sync_history_box');

  sl.registerLazySingleton(() => notesBox);
  sl.registerLazySingleton(() => syncBox);
  sl.registerLazySingleton(() => historyBox);

  // ============================================================
  // LOCAL DATASOURCES
  // ============================================================

  sl.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<SyncLocalDataSource>(
    () => SyncLocalDataSourceImpl(operationBox: sl(), historyBox: sl()),
  );

  // ============================================================
  // CORE SERVICES
  // ============================================================

  sl.registerLazySingleton(() => Connectivity());

  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(sl()),
  );

  // Fake server (ONLY SOURCE OF TRUTH for remote simulation)
  sl.registerLazySingleton<FakeApiService>(() => FakeApiService());

  sl.registerLazySingleton<SyncEventBus>(() => SyncEventBus());

  // ============================================================
  // REMOTE DATA SOURCE
  // ============================================================

  sl.registerLazySingleton<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(sl<FakeApiService>()),
  );

  // ============================================================
  // MONITORING
  // ============================================================

  sl.registerLazySingleton(() => SyncStatusService());
  sl.registerLazySingleton(() => SyncMetricsService());

  sl.registerLazySingleton(() => SyncQueueMonitor(sl()));
  sl.registerLazySingleton(() => SyncHealthChecker(sl()));

  sl.registerLazySingleton(() => SyncHistoryRepository(sl()));
  sl.registerLazySingleton(() => SyncQueueAnalyzer(sl()));

  // ============================================================
  // CONFLICT SYSTEM
  // ============================================================

  sl.registerLazySingleton(() => ConflictDetector());

  sl.registerLazySingleton(
    () => ConflictResolutionService(
      notesLocalDataSource: sl<NotesLocalDataSource>(),
      syncLocalDataSource: sl<SyncLocalDataSource>(),
      apiService: sl<FakeApiService>(), // ✅ FIX ADDED
      eventBus: sl<SyncEventBus>(),
    ),
  );

  // ============================================================
  // SYNC CORE
  // ============================================================

  sl.registerLazySingleton<SyncService>(
    () => SyncService(
      sl<SyncLocalDataSource>(),
      sl<NotesLocalDataSource>(),
      sl<NotesRemoteDataSource>(),
      sl<SyncMetricsService>(),
      sl<SyncEventBus>(),
      sl<SyncHistoryRepository>(),
      sl<ConflictDetector>(), // ✅ ADD
      sl<ConflictResolutionService>(), // ✅ ADD
    ),
  );

  sl.registerLazySingleton<SyncEngine>(() => SyncEngine(sl(), sl(), sl()));

  // ============================================================
  // REPOSITORIES
  // ============================================================

  sl.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(sl(), sl()),
  );

  // ============================================================
  // USE CASES
  // ============================================================

  sl.registerLazySingleton(() => GetNotesUseCase(sl()));
  sl.registerLazySingleton(() => GetNoteByIdUseCase(sl()));
  sl.registerLazySingleton(() => SaveNoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNoteUseCase(sl()));
  sl.registerLazySingleton(() => AddSyncOperation(sl()));

  // ============================================================
  // BLOCS / CUBITS
  // ============================================================

  sl.registerFactory(
    () => NotesBloc(
      getNotesUseCase: sl(),
      saveNoteUseCase: sl(),
      deleteNoteUseCase: sl(),
    ),
  );

  sl.registerFactory(() => NoteEditorCubit(saveNoteUseCase: sl()));
  sl.registerFactory(() => DeleteNoteCubit(deleteNoteUseCase: sl()));
}
