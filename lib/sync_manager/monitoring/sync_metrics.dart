class SyncMetrics {
  final int totalProcessed;
  final int totalSucceeded;
  final int totalFailed;
  final int totalRetried;

  const SyncMetrics({
    required this.totalProcessed,
    required this.totalSucceeded,
    required this.totalFailed,
    required this.totalRetried,
  });

  double get successRate {
    if (totalProcessed == 0) {
      return 0;
    }

    return (totalSucceeded / totalProcessed) * 100;
  }

  double get failureRate {
    if (totalProcessed == 0) {
      return 0;
    }

    return (totalFailed / totalProcessed) * 100;
  }
}
