import 'package:syncnotes/app/app_logger.dart';

class SyncMetricsService {
  int _totalSynced = 0;
  int _totalFailed = 0;
  int _totalRetried = 0;

  void recordSuccess() => _totalSynced++;
  void recordFailure() => _totalFailed++;
  void recordRetry() => _totalRetried++;

  int get totalSynced => _totalSynced;
  int get totalFailed => _totalFailed;
  int get totalRetried => _totalRetried;

  int get totalProcessed => _totalSynced + _totalFailed;

  double get successRate {
    if (totalProcessed == 0) return 0.0;
    return (_totalSynced / totalProcessed) * 100;
  }

  /// ✅ FIX: UI expects this
  SyncMetricsSnapshot getStats() {
    return SyncMetricsSnapshot(
      success: _totalSynced,
      failed: _totalFailed,
      retryCount: _totalRetried,
      total: totalProcessed,
      successRate: successRate,
    );
  }

  void reset() {
    _totalSynced = 0;
    _totalFailed = 0;
    _totalRetried = 0;
  }

  void printStatistics() {
    AppLogger.log('''
📊 ===========================
        SYNC METRICS
===========================
✅ Synced      : $_totalSynced
❌ Failed      : $_totalFailed
🔄 Retried     : $_totalRetried
📦 Processed   : $totalProcessed
📈 SuccessRate : ${successRate.toStringAsFixed(1)}%
===========================
''');
  }
}

/// ✅ FIXED DTO FOR UI
class SyncMetricsSnapshot {
  final int success;
  final int failed;
  final int retryCount;
  final int total;
  final double successRate;

  SyncMetricsSnapshot({
    required this.success,
    required this.failed,
    required this.retryCount,
    required this.total,
    required this.successRate,
  });
}
