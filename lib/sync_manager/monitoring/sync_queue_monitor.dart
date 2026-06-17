import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';

import 'sync_queue_status.dart';

class SyncQueueMonitor {
  final SyncLocalDataSource localDataSource;

  const SyncQueueMonitor(this.localDataSource);

  Future<SyncQueueStatus> getStatus() async {
    final operations = await localDataSource.getOperations();

    final pending = operations.where((e) => e.status == 'pending').length;

    final failed = operations.where((e) => e.status == 'failed').length;

    final inProgress = operations.where((e) => e.isInProgress).length;

    return SyncQueueStatus(
      pending: pending,
      inProgress: inProgress,
      failed: failed,
    );
  }
}
