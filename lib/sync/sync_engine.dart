import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/core/enums/sync_status_state.dart';
import 'package:syncnotes/core/network/connectivity_service.dart';

import 'package:syncnotes/sync/monitoring/sync_status_service.dart';
import 'package:syncnotes/sync/sync_service.dart';

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

  bool _syncScheduled = false;

  SyncMode _mode = SyncMode.normal;

  int _recentFailures = 0;
  int _recentSuccesses = 0;

  SyncEngine(
    this.syncService,
    this.connectivityService,
    this.syncStatusService,
  );

  // ============================================================
  // INIT
  // ============================================================

  void initialize() {
    if (_isInitialized || _disposed) return;

    _isInitialized = true;

    syncStatusService.updateStatus(SyncStatusState.idle);

    WidgetsBinding.instance.addObserver(this);

    _recoverSafeState();
    _listenConnectivity();
    _startAdaptiveLoop();

    _scheduleSync(reason: "initial");
  }

  // ============================================================
  // PUBLIC API
  // ============================================================

  Future<void> syncNow() async {
    if (_disposed) return;

    AppLogger.log("⚡ Manual sync triggered");

    await _triggerSync(reason: "manual");
  }

  void markDirty() {
    if (_disposed) return;

    _isDirty = true;
    _scheduleSync(reason: "markDirty");
  }

  // ============================================================
  // ADAPTIVE MODE
  // ============================================================

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
    if (_recentFailures >= 3) {
      _mode = SyncMode.slow;
      AppLogger.log('🐢 Mode → SLOW');
      return;
    }

    if (_recentSuccesses >= 5) {
      _mode = SyncMode.fast;
      AppLogger.log('🚀 Mode → FAST');
      return;
    }

    _mode = SyncMode.normal;
  }

  // ============================================================
  // ADAPTIVE LOOP (FIXED)
  // ============================================================

  void _startAdaptiveLoop() {
    _adaptiveTimer?.cancel();

    _adaptiveTimer = Timer.periodic(_adaptiveInterval, (_) {
      if (_disposed) return;

      if (_isDirty && !_isRunning) {
        _triggerSync(reason: "adaptive_loop");
      }
    });
  }

  // ============================================================
  // DEBOUNCE SYNC
  // ============================================================

  void _scheduleSync({required String reason}) {
    if (_disposed) return;
    if (_syncScheduled) return;

    _syncScheduled = true;

    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(seconds: 3), () {
      _syncScheduled = false;
      _triggerSync(reason: reason);
    });
  }

  // ============================================================
  // CONNECTIVITY
  // ============================================================

  void _listenConnectivity() {
    _connectivitySubscription?.cancel();

    _connectivitySubscription = connectivityService.connectivityStream.listen((
      connected,
    ) {
      if (_disposed) return;

      if (connected) {
        AppLogger.log('📶 Online → sync queued');
        _scheduleSync(reason: "connectivity");
      } else {
        AppLogger.log('📴 Offline');
        syncStatusService.updateStatus(SyncStatusState.offline);
      }
    });
  }

  // ============================================================
  // CORE SYNC
  // ============================================================

  Future<void> _triggerSync({required String reason}) async {
    if (_disposed || _isRunning) return;

    final now = DateTime.now();

    if (_lastSyncTime != null && now.difference(_lastSyncTime!) < _cooldown) {
      AppLogger.log('⏱ Cooldown active');
      return;
    }

    if (!_isDirty) {
      AppLogger.log('🧠 Clean state - skipping');
      return;
    }

    _isRunning = true;

    try {
      final connected = await connectivityService.isConnected();

      if (!connected) {
        syncStatusService.updateStatus(SyncStatusState.offline);
        return;
      }

      syncStatusService.updateStatus(SyncStatusState.syncing);

      AppLogger.log('🚀 Sync [$reason | mode: $_mode]');

      await syncService.processQueue();

      _isDirty = false;
      _lastSyncTime = DateTime.now();

      _recentSuccesses++;
      _recentFailures = 0;

      _evaluateMode();

      syncStatusService.updateStatus(SyncStatusState.success);

      await Future.delayed(const Duration(seconds: 1));

      syncStatusService.updateStatus(SyncStatusState.idle);
    } catch (e) {
      AppLogger.error('Sync failed', e);

      _recentFailures++;
      _recentSuccesses = 0;

      _evaluateMode();

      syncStatusService.updateStatus(SyncStatusState.error);
    } finally {
      _isRunning = false;
    }
  }

  // ============================================================
  // RECOVERY
  // ============================================================

  Future<void> _recoverSafeState() async {
    try {
      AppLogger.log('♻️ Recovery started');

      await syncService.recoverStuckOperations();

      syncStatusService.updateStatus(SyncStatusState.idle);
    } catch (e) {
      AppLogger.error('Recovery failed', e);
      syncStatusService.updateStatus(SyncStatusState.error);
    }
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;

    if (state == AppLifecycleState.resumed) {
      AppLogger.log('📱 Resume → sync check');
      _scheduleSync(reason: "resume");
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    _disposed = true;

    _adaptiveTimer?.cancel();
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    _isInitialized = false;
    _isRunning = false;

    syncStatusService.updateStatus(SyncStatusState.idle);

    AppLogger.log('🛑 SyncEngine disposed');
  }
}
