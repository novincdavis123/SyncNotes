import 'package:syncnotes/sync/monitoring/sync_health.dart';
import 'package:syncnotes/sync/monitoring/sync_queue_monitor.dart';
import 'package:syncnotes/sync/monitoring/sync_queue_status.dart';

class SyncHealthChecker {
  final SyncQueueMonitor queueMonitor;

  const SyncHealthChecker(this.queueMonitor);

  Future<SyncHealth> checkHealth() async {
    final status = await queueMonitor.getStatus();

    return _evaluate(status);
  }

  SyncHealth _evaluate(SyncQueueStatus status) {
    if (status.failed >= 10) {
      return SyncHealth.critical;
    }

    if (status.inProgress >= 5) {
      return SyncHealth.critical;
    }

    if (status.pending >= 20) {
      return SyncHealth.warning;
    }

    if (status.failed > 0) {
      return SyncHealth.warning;
    }

    return SyncHealth.healthy;
  }
}
