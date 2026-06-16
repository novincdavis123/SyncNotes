class SyncQueueStatus {
  final int pending;
  final int inProgress;
  final int failed;

  const SyncQueueStatus({
    required this.pending,
    required this.inProgress,
    required this.failed,
  });

  int get total => pending + inProgress + failed;

  bool get hasPending => pending > 0;

  bool get hasFailures => failed > 0;

  bool get isIdle => total == 0;
}
