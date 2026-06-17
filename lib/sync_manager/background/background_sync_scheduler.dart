import 'dart:async';

import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/features/sync/engine/sync_engine.dart';

/// ------------------------------------------------------------
/// BackgroundSyncScheduler
/// ------------------------------------------------------------
/// Responsible for:
/// - Periodic sync scheduling (production-safe)
/// - Preventing overlapping sync jobs
/// - Adaptive retry scheduling hook (future-ready)
/// ------------------------------------------------------------

class BackgroundSyncScheduler {
  final SyncEngine syncEngine;

  Timer? _timer;

  bool _isRunning = false;
  bool _isStarted = false;

  /// Default interval for periodic sync
  final Duration interval;

  BackgroundSyncScheduler(
    this.syncEngine, {
    this.interval = const Duration(minutes: 2),
  });

  // ============================================================
  // START SCHEDULER
  // ============================================================

  void start() {
    if (_isStarted) return;

    _isStarted = true;

    AppLogger.log(
      "🕒 BackgroundSyncScheduler started "
      "(interval: ${interval.inMinutes} min)",
    );

    _timer = Timer.periodic(interval, (_) {
      _runSync();
    });
  }

  // ============================================================
  // MANUAL TRIGGER
  // ============================================================

  Future<void> triggerNow() async {
    await _runSync();
  }

  // ============================================================
  // CORE SYNC EXECUTION
  // ============================================================

  Future<void> _runSync() async {
    if (_isRunning) {
      AppLogger.log("⏭ Sync skipped (already running)");
      return;
    }

    _isRunning = true;

    try {
      AppLogger.log("🚀 Scheduler triggered sync");

      await syncEngine.syncNow();

      AppLogger.success("✅ Scheduler sync completed");
    } catch (e) {
      AppLogger.error("❌ Scheduler sync failed", e);
    } finally {
      _isRunning = false;
    }
  }

  // ============================================================
  // STOP SCHEDULER
  // ============================================================

  void stop() {
    _timer?.cancel();
    _timer = null;

    _isStarted = false;
    _isRunning = false;

    AppLogger.log("🛑 BackgroundSyncScheduler stopped");
  }

  // ============================================================
  // RESTART SCHEDULER
  // ============================================================

  void restart() {
    stop();
    start();
  }

  // ============================================================
  // STATE
  // ============================================================

  bool get isRunning => _isRunning;

  bool get isStarted => _isStarted;
}
