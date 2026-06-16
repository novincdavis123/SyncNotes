import 'dart:async';

import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/sync/sync_engine.dart';

class BackgroundSyncService {
  final SyncEngine syncEngine;

  Timer? _timer;

  bool _started = false;

  bool _running = false;

  /// Default interval for automatic background sync
  final Duration interval;

  BackgroundSyncService(
    this.syncEngine, {
    this.interval = const Duration(minutes: 2),
  });

  // ==========================================================
  // START
  // ==========================================================

  void start() {
    if (_started) return;

    _started = true;

    AppLogger.log(
      "🔄 Background Sync Service started "
      "(every ${interval.inMinutes} minutes)",
    );

    _timer = Timer.periodic(interval, (_) {
      _performSync();
    });
  }

  // ==========================================================
  // MANUAL TRIGGER
  // ==========================================================

  Future<void> triggerNow() async {
    await _performSync();
  }

  // ==========================================================
  // INTERNAL SYNC
  // ==========================================================

  Future<void> _performSync() async {
    if (_running) {
      AppLogger.log("⏭ Background sync skipped (already running)");
      return;
    }

    _running = true;

    try {
      AppLogger.log("📡 Background sync triggered");

      await syncEngine.syncNow();

      AppLogger.success("✅ Background sync completed");
    } catch (e) {
      AppLogger.error("❌ Background sync failed", e);
    } finally {
      _running = false;
    }
  }

  // ==========================================================
  // STOP
  // ==========================================================

  void stop() {
    _timer?.cancel();
    _timer = null;

    _started = false;

    AppLogger.log("🛑 Background Sync Service stopped");
  }

  // ==========================================================
  // RESTART
  // ==========================================================

  void restart() {
    stop();
    start();
  }

  // ==========================================================
  // GETTERS
  // ==========================================================

  bool get isStarted => _started;

  bool get isRunning => _running;
}
