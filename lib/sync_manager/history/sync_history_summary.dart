class SyncHistorySummary {
  final int total;
  final int success;
  final int failed;
  final int conflictsResolved;

  const SyncHistorySummary({
    required this.total,
    required this.success,
    required this.failed,
    required this.conflictsResolved,
  });

  factory SyncHistorySummary.empty() {
    return const SyncHistorySummary(
      total: 0,
      success: 0,
      failed: 0,
      conflictsResolved: 0,
    );
  }
}
