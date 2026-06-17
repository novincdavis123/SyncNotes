import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:syncnotes/app/app.dart';
import 'package:syncnotes/app/app_bloc_observer.dart';
import 'package:syncnotes/di/injection.dart';

import 'package:syncnotes/features/sync/engine/sync_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies();

  Bloc.observer = AppBlocObserver();

  final syncEngine = sl<SyncEngine>();

  // 🚀 Initialize sync engine (includes connectivity + sync loop)
  syncEngine.initialize();

  runApp(const SyncNotesApp());
}
