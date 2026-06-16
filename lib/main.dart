import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:syncnotes/app/app.dart';
import 'package:syncnotes/app/app_bloc_observer.dart';
import 'package:syncnotes/app/app_logger.dart';

import 'package:syncnotes/di/injection.dart';

import 'package:syncnotes/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:syncnotes/features/notes/presentation/bloc/notes_event.dart';

import 'package:syncnotes/sync/monitoring/sync_metrics_service.dart';
import 'package:syncnotes/sync/monitoring/sync_queue_monitor.dart';

import 'package:syncnotes/sync/sync_engine.dart' as engine;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // INIT DEPENDENCIES
  // ============================================================
  await initDependencies();

  // ============================================================
  // START SYNC ENGINE (ONLY ONCE - SAFE)
  // ============================================================
  final syncEngine = sl<engine.SyncEngine>();
  syncEngine.initialize();

  // ============================================================
  // DEBUG QUEUE STATUS
  // ============================================================
  final status = await sl<SyncQueueMonitor>().getStatus();

  AppLogger.log(
    '📦 Queue Status → Pending: ${status.pending}, '
    'In Progress: ${status.inProgress}, '
    'Failed: ${status.failed}',
  );

  // ============================================================
  // DEBUG METRICS
  // ============================================================
  final metrics = sl<SyncMetricsService>();

  AppLogger.log(
    '📊 Sync Metrics → Success: ${metrics.totalSynced}, '
    'Failed: ${metrics.totalFailed}, '
    'Retried: ${metrics.totalRetried}, '
    'Success Rate: ${metrics.successRate.toStringAsFixed(1)}%',
  );

  // ============================================================
  // BLOC OBSERVER
  // ============================================================
  Bloc.observer = AppBlocObserver();

  // ============================================================
  // RUN APP
  // ============================================================
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
