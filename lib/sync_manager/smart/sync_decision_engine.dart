import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:syncnotes/sync_manager/monitoring/sync_queue_monitor.dart';

class SyncDecisionEngine {
  final SyncQueueMonitor queueMonitor;
  final Connectivity connectivity;

  DateTime? _lastSyncTime;

  SyncDecisionEngine(this.queueMonitor, this.connectivity);

  // ============================================================
  // MAIN DECISION API
  // ============================================================

  Future<SyncDecision> shouldSync() async {
    final connectivityResult = await connectivity.checkConnectivity();

    final hasNetwork = connectivityResult != ConnectivityResult.none;

    if (!hasNetwork) {
      return SyncDecision.noNetwork();
    }

    final queueStatus = await queueMonitor.getStatus();

    if (queueStatus.pending == 0 && queueStatus.failed == 0) {
      return SyncDecision.noWork();
    }

    // prevent aggressive syncing
    if (_isTooSoonAfterLastSync()) {
      return SyncDecision.cooldown();
    }

    // high priority case
    if (queueStatus.failed > 0) {
      return SyncDecision.forceSync();
    }

    return SyncDecision.proceed();
  }

  // ============================================================
  // COOLDOWN LOGIC
  // ============================================================

  bool _isTooSoonAfterLastSync() {
    if (_lastSyncTime == null) return false;

    final diff = DateTime.now().difference(_lastSyncTime!);

    return diff.inSeconds < 15;
  }

  void markSynced() {
    _lastSyncTime = DateTime.now();
  }
}

// ============================================================
// DECISION MODEL
// ============================================================

enum SyncDecisionType { proceed, noNetwork, noWork, cooldown, forceSync }

class SyncDecision {
  final SyncDecisionType type;
  final String reason;

  SyncDecision(this.type, this.reason);

  factory SyncDecision.proceed() =>
      SyncDecision(SyncDecisionType.proceed, "Proceed with sync");

  factory SyncDecision.noNetwork() =>
      SyncDecision(SyncDecisionType.noNetwork, "No internet connection");

  factory SyncDecision.noWork() =>
      SyncDecision(SyncDecisionType.noWork, "Nothing to sync");

  factory SyncDecision.cooldown() =>
      SyncDecision(SyncDecisionType.cooldown, "Sync cooldown active");

  factory SyncDecision.forceSync() =>
      SyncDecision(SyncDecisionType.forceSync, "High priority sync required");
}
