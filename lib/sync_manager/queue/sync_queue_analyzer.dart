import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';
import 'sync_queue_statistics.dart';

/// ------------------------------------------------------------
/// SyncQueueAnalyzer (Step 9 FINAL CLEAN VERSION)
/// ------------------------------------------------------------
class SyncQueueAnalyzer {
  final SyncLocalDataSource localDataSource;

  SyncQueueAnalyzer(this.localDataSource);

  /// ------------------------------------------------------------
  /// MAIN ANALYSIS (UI SAFE)
  /// ------------------------------------------------------------
  Future<SyncQueueStatistics> analyze() async {
    final operations = await localDataSource.getOperations();

    final total = operations.length;

    int success = 0;
    int failed = 0;
    int pending = 0;
    int inProgress = 0;
    int conflicts = 0;
    int retryCount = 0;

    for (final op in operations) {
      switch (op.status) {
        case 'pending':
          pending++;
          break;

        case 'success':
          success++;
          break;

        case 'failed':
          failed++;
          break;

        case 'conflict':
          conflicts++;
          break;
      }

      if (op.isInProgress) {
        inProgress++;
      }

      retryCount += op.retryCount;
    }

    return SyncQueueStatistics(
      total: total,
      success: success,
      failed: failed,
      pending: pending,
      inProgress: inProgress,
      conflicts: conflicts,
      retryCount: retryCount,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  /// ------------------------------------------------------------
  /// COMPATIBILITY ALIAS (IMPORTANT FIX)
  /// ------------------------------------------------------------
  Future<SyncQueueStatistics> analyzeSyncQueue() => analyze();

  /// ------------------------------------------------------------
  /// QUICK HEALTH CHECK
  /// ------------------------------------------------------------
  Future<bool> isHealthy() async {
    final stats = await analyze();

    if (stats.failureRate > 0.3) return false;
    if (stats.inProgress > 10) return false;
    if (stats.pending > 50) return false;

    return true;
  }

  /// ------------------------------------------------------------
  /// BOTTLENECK DETECTION
  /// ------------------------------------------------------------
  Future<List<String>> detectBottlenecks() async {
    final stats = await analyze();

    final issues = <String>[];

    if (stats.pending > 20) {
      issues.add('High pending queue backlog');
    }

    if (stats.failureRate > 0.2) {
      issues.add('High failure rate detected');
    }

    if (stats.conflicts > 0) {
      issues.add('Unresolved conflicts present');
    }

    if (stats.inProgress > 5) {
      issues.add('Too many concurrent operations');
    }

    return issues;
  }

  /// ------------------------------------------------------------
  /// DEBUG REPORT
  /// ------------------------------------------------------------
  Future<String> generateReport() async {
    final stats = await analyze();
    final issues = await detectBottlenecks();

    return '''
========== SYNC QUEUE REPORT ==========
Total           : ${stats.total}
Success         : ${stats.success}
Failed          : ${stats.failed}
Pending         : ${stats.pending}
In Progress     : ${stats.inProgress}
Conflicts       : ${stats.conflicts}
Retry Count     : ${stats.retryCount}

Success Rate    : ${(stats.successRate * 100).toStringAsFixed(2)}%
Failure Rate    : ${(stats.failureRate * 100).toStringAsFixed(2)}%

Status          : ${stats.isHealthy ? "HEALTHY" : "UNSTABLE"}

Issues:
${issues.isEmpty ? "None" : issues.join("\n")}
======================================
''';
  }
}
