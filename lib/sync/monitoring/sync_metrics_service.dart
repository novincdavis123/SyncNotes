import 'package:syncnotes/app/app_logger.dart';

/// =============================================================
/// Sync Metrics Service
/// =============================================================
class SyncMetricsService {
  int _totalSynced = 0;
  int _totalFailed = 0;
  int _totalRetried = 0;

  // =============================================================
  // RECORD METRICS
  // =============================================================

  void recordSuccess() {
    _totalSynced++;
  }

  void recordFailure() {
    _totalFailed++;
  }

  void recordRetry() {
    _totalRetried++;
  }

  // =============================================================
  // GETTERS
  // =============================================================

  int get totalSynced => _totalSynced;

  int get totalFailed => _totalFailed;

  int get totalRetried => _totalRetried;

  int get totalProcessed => _totalSynced + _totalFailed;

  double get successRate {
    if (totalProcessed == 0) {
      return 0;
    }

    return (_totalSynced / totalProcessed) * 100;
  }

  // =============================================================
  // SNAPSHOT FOR UI
  // =============================================================

  SyncMetricsSnapshot getStats() {
    return SyncMetricsSnapshot(
      success: _totalSynced,
      failed: _totalFailed,
      retryCount: _totalRetried,
      total: totalProcessed,
      successRate: successRate,
    );
  }

  // =============================================================
  // RESET
  // =============================================================

  void reset() {
    _totalSynced = 0;
    _totalFailed = 0;
    _totalRetried = 0;
  }

  // =============================================================
  // DEBUG LOG
  // =============================================================

  void printStatistics() {
    AppLogger.log('''
==================================================
                 SYNC METRICS
==================================================
Successful Syncs : $_totalSynced
Failed Syncs     : $_totalFailed
Retry Attempts   : $_totalRetried
Total Processed  : $totalProcessed
Success Rate     : ${successRate.toStringAsFixed(1)}%
==================================================
''');
  }
}

/// =============================================================
/// Immutable Snapshot used by Dashboard UI
/// =============================================================
class SyncMetricsSnapshot {
  final int success;
  final int failed;
  final int retryCount;
  final int total;
  final double successRate;

  const SyncMetricsSnapshot({
    required this.success,
    required this.failed,
    required this.retryCount,
    required this.total,
    required this.successRate,
  });

  bool get hasFailures => failed > 0;

  bool get hasRetries => retryCount > 0;

  bool get isHealthy => failed == 0;

  @override
  String toString() {
    return '''
SyncMetricsSnapshot(
  success: $success,
  failed: $failed,
  retryCount: $retryCount,
  total: $total,
  successRate: ${successRate.toStringAsFixed(1)}%
)
''';
  }
}
