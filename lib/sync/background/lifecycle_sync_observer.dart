import 'package:flutter/widgets.dart';
import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/core/network/connectivity_service.dart';
import 'package:syncnotes/sync/sync_engine.dart';

/// ------------------------------------------------------------
/// LifecycleSyncObserver
/// ------------------------------------------------------------
/// Handles app lifecycle events to trigger smart sync:
/// - App resumed → trigger sync if online
/// - App paused → optional lightweight flush hook
/// - Ensures no duplicate sync execution
/// ------------------------------------------------------------

class LifecycleSyncObserver with WidgetsBindingObserver {
  final SyncEngine syncEngine;
  final ConnectivityService connectivityService;

  bool _isResumed = false;
  bool _isSyncing = false;

  LifecycleSyncObserver(this.syncEngine, this.connectivityService);

  // ============================================================
  // INIT
  // ============================================================

  void init() {
    WidgetsBinding.instance.addObserver(this);

    AppLogger.log("📱 LifecycleSyncObserver attached");
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    AppLogger.log("📱 LifecycleSyncObserver detached");
  }

  // ============================================================
  // LIFECYCLE HANDLER
  // ============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onResumed();
        break;

      case AppLifecycleState.paused:
        _onPaused();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  // ============================================================
  // RESUMED → TRIGGER SYNC
  // ============================================================

  Future<void> _onResumed() async {
    if (_isResumed) return;

    _isResumed = true;

    try {
      final isOnline = await connectivityService.isConnected();

      if (!isOnline) {
        AppLogger.log("📴 App resumed but offline → sync skipped");
        return;
      }

      if (_isSyncing) return;

      _isSyncing = true;

      AppLogger.log("🔄 App resumed → triggering sync");

      await syncEngine.syncNow();

      AppLogger.success("✅ Resume sync completed");
    } catch (e) {
      AppLogger.error("❌ Resume sync failed", e);
    } finally {
      _isSyncing = false;
      _isResumed = false;
    }
  }

  // ============================================================
  // PAUSED → OPTIONAL HOOK
  // ============================================================

  void _onPaused() {
    AppLogger.log("⏸ App paused");

    // Optional: could flush local cache or queue snapshot here
  }
}
