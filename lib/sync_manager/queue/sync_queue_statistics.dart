/// ------------------------------------------------------------
/// SyncQueueStatistics (Step 9 FINAL)
/// ------------------------------------------------------------
/// Clean UI-friendly + analyzer-friendly sync metrics model
/// ------------------------------------------------------------

class SyncQueueStatistics {
  /// Total operations in queue
  final int total;

  /// Successful sync operations
  final int success;

  /// Failed sync operations
  final int failed;

  /// Retry attempts triggered
  final int retryCount;

  /// Pending operations
  final int pending;

  /// Active syncing operations
  final int inProgress;

  /// Conflicted operations
  final int conflicts;

  /// Last update time
  final DateTime updatedAt;

  const SyncQueueStatistics({
    required this.total,
    required this.success,
    required this.failed,
    required this.retryCount,
    required this.pending,
    required this.inProgress,
    required this.conflicts,
    required this.updatedAt,
  });

  /// ------------------------------------------------------------
  /// INITIAL STATE
  /// ------------------------------------------------------------

  factory SyncQueueStatistics.initial() {
    return SyncQueueStatistics(
      total: 0,
      success: 0,
      failed: 0,
      retryCount: 0,
      pending: 0,
      inProgress: 0,
      conflicts: 0,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  /// ------------------------------------------------------------
  /// DERIVED METRICS
  /// ------------------------------------------------------------

  double get successRate {
    if (total == 0) return 0;
    return success / total;
  }

  double get failureRate {
    if (total == 0) return 0;
    return failed / total;
  }

  bool get hasConflicts => conflicts > 0;

  bool get isHealthy => failureRate < 0.2;

  /// ------------------------------------------------------------
  /// COPY WITH
  /// ------------------------------------------------------------

  SyncQueueStatistics copyWith({
    int? total,
    int? success,
    int? failed,
    int? retryCount,
    int? pending,
    int? inProgress,
    int? conflicts,
    DateTime? updatedAt,
  }) {
    return SyncQueueStatistics(
      total: total ?? this.total,
      success: success ?? this.success,
      failed: failed ?? this.failed,
      retryCount: retryCount ?? this.retryCount,
      pending: pending ?? this.pending,
      inProgress: inProgress ?? this.inProgress,
      conflicts: conflicts ?? this.conflicts,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// ------------------------------------------------------------
  /// DEBUG PRINT
  /// ------------------------------------------------------------

  @override
  String toString() {
    return '''
SyncQueueStatistics(
  total: $total,
  success: $success,
  failed: $failed,
  retry: $retryCount,
  pending: $pending,
  inProgress: $inProgress,
  conflicts: $conflicts,
  updatedAt: $updatedAt
)
''';
  }
}
