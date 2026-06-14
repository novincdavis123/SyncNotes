import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:syncnotes/sync/sync_service.dart';

class SyncEngine with WidgetsBindingObserver {
  final SyncService syncService;

  Timer? _timer;
  bool _isRunning = false;
  bool _isInitialized = false;

  SyncEngine(this.syncService);

  // ------------------------------------------------------------
  // INITIALIZATION
  // ------------------------------------------------------------

  void initialize() {
    if (_isInitialized) return;

    _isInitialized = true;

    WidgetsBinding.instance.addObserver(this);

    // 🔥 recover any crashed sync state first
    _recoverSafeState();

    _startPeriodicSync();

    // immediate sync on launch
    _triggerSync();
  }

  // ------------------------------------------------------------
  // PERIODIC SYNC
  // ------------------------------------------------------------

  void _startPeriodicSync() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _triggerSync());
  }

  // ------------------------------------------------------------
  // SYNC TRIGGER
  // ------------------------------------------------------------

  Future<void> _triggerSync() async {
    if (_isRunning) return;

    _isRunning = true;

    try {
      await syncService.processQueue();
    } catch (e) {
      debugPrint("SyncEngine error: $e");
    } finally {
      _isRunning = false;
    }
  }

  // ------------------------------------------------------------
  // CRASH RECOVERY HOOK
  // ------------------------------------------------------------

  Future<void> _recoverSafeState() async {
    try {
      // IMPORTANT:
      // This assumes SyncService exposes recovery method
      await syncService.recoverStuckOperations();
    } catch (e) {
      debugPrint("SyncEngine recovery error: $e");
    }
  }

  // ------------------------------------------------------------
  // LIFECYCLE HANDLING
  // ------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _triggerSync();
        break;

      case AppLifecycleState.paused:
        // optional: stop heavy work if needed
        break;

      default:
        break;
    }
  }

  // ------------------------------------------------------------
  // CLEANUP
  // ------------------------------------------------------------

  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
  }
}
