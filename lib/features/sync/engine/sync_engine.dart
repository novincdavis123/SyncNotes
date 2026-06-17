import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/core/network/connectivity_service.dart';
import 'package:syncnotes/sync_manager/monitoring/sync_status_service.dart';
import 'package:syncnotes/features/sync/service/sync_service.dart';

enum SyncMode { fast, normal, slow, paused }

class SyncEngine with WidgetsBindingObserver {
  final SyncService syncService;
  final ConnectivityService connectivityService;
  final SyncStatusService syncStatusService;

  Timer? _adaptiveTimer;
  Timer? _debounceTimer;
  StreamSubscription<bool>? _connectivitySubscription;

  bool _isRunning = false;
  bool _isInitialized = false;
  bool _disposed = false;

  bool _isDirty = true;

  DateTime? _lastSyncTime;
  final Duration _cooldown = const Duration(seconds: 10);

  SyncMode _mode = SyncMode.normal;

  int _recentFailures = 0;
  int _recentSuccesses = 0;

  SyncEngine(
    this.syncService,
    this.connectivityService,
    this.syncStatusService,
  );

  // =========================================================
  // INIT
  // =========================================================

  void initialize() {
    if (_disposed || _isInitialized) return;

    _isInitialized = true;

    WidgetsBinding.instance.addObserver(this);

    AppLogger.log("🚀 SyncEngine initializing...");

    syncStatusService.updateStatus(SyncStatus.pending);

    _recoverSafeState();
    _listenConnectivity();
    _startAdaptiveLoop();

    _scheduleSync(reason: "initial");

    AppLogger.success("🚀 SyncEngine initialized");
  }

  // =========================================================
  // PUBLIC API
  // =========================================================

  Future<void> syncNow() async {
    if (_disposed) return;

    AppLogger.log("⚡ Manual sync triggered");

    await _triggerSync(reason: "manual");
  }

  void markDirty() {
    if (_disposed) return;

    AppLogger.log("🟡 Marked dirty");

    _isDirty = true;
    syncStatusService.updateStatus(SyncStatus.pending);

    _scheduleSync(reason: "markDirty");
  }

  // =========================================================
  // ADAPTIVE LOOP
  // =========================================================

  void _startAdaptiveLoop() {
    _adaptiveTimer?.cancel();

    AppLogger.log("🔁 Adaptive loop started (mode: $_mode)");

    _adaptiveTimer = Timer.periodic(_adaptiveInterval, (_) {
      if (_disposed || _isRunning) return;

      AppLogger.log("⏱ Adaptive tick | dirty=$_isDirty | mode=$_mode");

      if (_isDirty) {
        _triggerSync(reason: "adaptive_loop");
      }
    });
  }

  Duration get _adaptiveInterval {
    switch (_mode) {
      case SyncMode.fast:
        return const Duration(seconds: 15);
      case SyncMode.normal:
        return const Duration(seconds: 30);
      case SyncMode.slow:
        return const Duration(minutes: 2);
      case SyncMode.paused:
        return const Duration(minutes: 5);
    }
  }

  void _evaluateMode() {
    final oldMode = _mode;

    if (_recentFailures >= 3) {
      _mode = SyncMode.slow;
    } else if (_recentSuccesses >= 5) {
      _mode = SyncMode.fast;
    } else {
      _mode = SyncMode.normal;
    }

    if (oldMode != _mode) {
      AppLogger.log("📊 Mode changed: $oldMode → $_mode");
    }
  }

  // =========================================================
  // DEBOUNCE
  // =========================================================

  void _scheduleSync({required String reason}) {
    if (_disposed) return;

    AppLogger.log("⏳ Sync scheduled | reason=$reason");

    _debounceTimer?.cancel();

    _debounceTimer = Timer(
      const Duration(seconds: 3),
      () => _triggerSync(reason: reason),
    );
  }

  // =========================================================
  // CONNECTIVITY
  // =========================================================

  void _listenConnectivity() {
    _connectivitySubscription?.cancel();

    AppLogger.log("📡 Listening connectivity...");

    _connectivitySubscription = connectivityService.connectivityStream.listen((
      connected,
    ) {
      if (_disposed) return;

      AppLogger.log("📶 Connectivity changed: $connected");

      if (connected) {
        AppLogger.log("📶 Online");

        if (_isDirty) {
          _scheduleSync(reason: "connectivity");
        }
      } else {
        AppLogger.log("📴 Offline");
        syncStatusService.updateStatus(SyncStatus.offline);
      }
    });
  }

  // =========================================================
  // CORE SYNC
  // =========================================================

  Future<void> _triggerSync({required String reason}) async {
    if (_disposed || _isRunning) {
      AppLogger.log("⛔ Sync skipped (running/disposed)");
      return;
    }

    final now = DateTime.now();

    if (_lastSyncTime != null && now.difference(_lastSyncTime!) < _cooldown) {
      AppLogger.log("⏳ Cooldown active → rescheduling");
      _scheduleSync(reason: "cooldown");
      return;
    }

    if (!_isDirty) {
      AppLogger.log("🟢 No changes (clean state)");
      return;
    }

    _isRunning = true;

    try {
      final connected = await connectivityService.isConnected();

      if (!connected) {
        AppLogger.log("📴 Cannot sync (offline)");
        syncStatusService.updateStatus(SyncStatus.offline);
        return;
      }

      syncStatusService.updateStatus(SyncStatus.syncing);

      AppLogger.log("🚀 SYNC STARTED [$reason | mode=$_mode]");

      // =========================
      // PULL
      // =========================
      AppLogger.log("⬇️ Pull phase started");
      await syncService.pullRemoteChanges();
      AppLogger.log("⬇️ Pull phase completed");

      // =========================
      // PUSH
      // =========================
      AppLogger.log("⬆️ Push phase started");
      await syncService.processQueue();
      AppLogger.log("⬆️ Push phase completed");

      _isDirty = false;
      _lastSyncTime = DateTime.now();

      _recentSuccesses++;
      _recentFailures = 0;

      _evaluateMode();

      syncStatusService.updateStatus(SyncStatus.synced);

      AppLogger.success("✅ SYNC COMPLETED");
    } catch (e) {
      _recentFailures++;
      _recentSuccesses = 0;

      _evaluateMode();

      AppLogger.error("❌ Sync failed", e);

      syncStatusService.updateStatus(SyncStatus.failed);
    } finally {
      _isRunning = false;
    }
  }

  // =========================================================
  // RECOVERY
  // =========================================================

  Future<void> _recoverSafeState() async {
    try {
      AppLogger.log("♻️ Recovery started");
      await syncService.recoverStuckOperations();
      AppLogger.success("♻️ Recovery completed");
    } catch (e) {
      AppLogger.error("Recovery failed", e);
    }
  }

  // =========================================================
  // LIFECYCLE
  // =========================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;

    AppLogger.log("📱 Lifecycle: $state");

    if (state == AppLifecycleState.resumed) {
      AppLogger.log("📱 App resumed");

      if (_isDirty) {
        _scheduleSync(reason: "resume");
      }
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  void dispose() {
    _disposed = true;
    _isInitialized = false;

    _adaptiveTimer?.cancel();
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    syncStatusService.updateStatus(SyncStatus.pending);

    AppLogger.log("🛑 SyncEngine disposed");
  }
}
