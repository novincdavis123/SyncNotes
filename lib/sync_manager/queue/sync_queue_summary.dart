import 'package:syncnotes/sync_manager/queue/sync_queue_statistics.dart';

/// ------------------------------------------------------------
/// SyncQueueSummary (Step 9 FIXED)
/// ------------------------------------------------------------
/// UI-friendly derived model for dashboard widgets
/// ------------------------------------------------------------

class SyncQueueSummary {
  final int total;
  final int pending;
  final int success;
  final int failed;
  final int conflicts;
  final double successRate;
  final bool isHealthy;
  final String statusLabel;

  const SyncQueueSummary({
    required this.total,
    required this.pending,
    required this.success,
    required this.failed,
    required this.conflicts,
    required this.successRate,
    required this.isHealthy,
    required this.statusLabel,
  });

  /// ------------------------------------------------------------
  /// FROM STATISTICS (UPDATED FIELD MAPPING)
  /// ------------------------------------------------------------
  factory SyncQueueSummary.fromStats(SyncQueueStatistics stats) {
    final rate = stats.successRate;

    return SyncQueueSummary(
      total: stats.total,
      pending: stats.pending,
      success: stats.success,
      failed: stats.failed,
      conflicts: stats.conflicts,
      successRate: rate,
      isHealthy: stats.isHealthy,
      statusLabel: _resolveStatus(rate, stats),
    );
  }

  /// ------------------------------------------------------------
  /// STATUS RESOLUTION
  /// ------------------------------------------------------------
  static String _resolveStatus(double successRate, SyncQueueStatistics stats) {
    if (stats.conflicts > 0) {
      return "CONFLICTS";
    }

    if (stats.failureRate > 0.3) {
      return "UNSTABLE";
    }

    if (stats.pending > 20) {
      return "BACKLOG";
    }

    if (successRate > 0.9) {
      return "HEALTHY";
    }

    if (successRate > 0.7) {
      return "STABLE";
    }

    return "DEGRADED";
  }

  /// ------------------------------------------------------------
  /// UI HELPERS
  /// ------------------------------------------------------------
  bool get hasIssues => !isHealthy || conflicts > 0 || failed > 0;

  double get completionRatio {
    if (total == 0) return 0;
    return success / total;
  }

  @override
  String toString() {
    return '''
SyncQueueSummary(
  total: $total,
  pending: $pending,
  success: $success,
  failed: $failed,
  conflicts: $conflicts,
  successRate: ${(successRate * 100).toStringAsFixed(2)}%,
  status: $statusLabel
)
''';
  }
}
