import 'package:syncnotes/features/conflict/data/models/conflict_model.dart';

enum SyncEventType {
  started,
  empty,

  operationStarted,
  operationSuccess,
  operationFailed,

  retryScheduled,

  conflictDetected,

  /// 🔥 NEW: force UI refresh after conflict resolution
  syncRefresh,

  completed,

  permanentFailure,
  error,
}

/// ============================================================
/// 🧠 PRODUCTION-GRADE SYNC EVENT MODEL
/// ============================================================

class SyncEvent {
  final SyncEventType type;

  /// Related operation id (optional)
  final String? operationId;

  /// Human-readable message
  final String message;

  /// Timestamp
  final DateTime timestamp;

  /// Extra debug / analytics payload
  final Map<String, dynamic>? meta;

  const SyncEvent({
    required this.type,
    this.operationId,
    required this.message,
    this.meta,
    required this.timestamp,
  });

  // ============================================================
  // CORE EVENTS
  // ============================================================

  factory SyncEvent.started() => SyncEvent(
    type: SyncEventType.started,
    message: 'Sync started',
    timestamp: DateTime.now(),
  );

  factory SyncEvent.completed() => SyncEvent(
    type: SyncEventType.completed,
    message: 'Sync completed successfully',
    timestamp: DateTime.now(),
  );

  factory SyncEvent.empty() => SyncEvent(
    type: SyncEventType.empty,
    message: 'No pending operations',
    timestamp: DateTime.now(),
  );

  factory SyncEvent.error(String message) => SyncEvent(
    type: SyncEventType.error,
    message: message,
    timestamp: DateTime.now(),
  );

  // ============================================================
  // OPERATION EVENTS
  // ============================================================

  factory SyncEvent.operationStarted(String id) => SyncEvent(
    type: SyncEventType.operationStarted,
    operationId: id,
    message: 'Operation started',
    timestamp: DateTime.now(),
  );

  factory SyncEvent.operationSuccess(String id) => SyncEvent(
    type: SyncEventType.operationSuccess,
    operationId: id,
    message: 'Operation synced successfully',
    timestamp: DateTime.now(),
  );

  factory SyncEvent.operationFailed(String id, String reason) => SyncEvent(
    type: SyncEventType.operationFailed,
    operationId: id,
    message: reason,
    timestamp: DateTime.now(),
  );

  factory SyncEvent.permanentFailure(String id, String reason) => SyncEvent(
    type: SyncEventType.permanentFailure,
    operationId: id,
    message: reason,
    timestamp: DateTime.now(),
  );

  // ============================================================
  // RETRY EVENTS
  // ============================================================

  factory SyncEvent.retryScheduled({
    required String id,
    required int attempt,
    required Duration delay,
  }) {
    return SyncEvent(
      type: SyncEventType.retryScheduled,
      operationId: id,
      message: 'Retry #$attempt in ${delay.inSeconds}s',
      timestamp: DateTime.now(),
      meta: {'attempt': attempt, 'delaySeconds': delay.inSeconds},
    );
  }

  // ============================================================
  // CONFLICT EVENT
  // ============================================================

  factory SyncEvent.conflictDetected({
    required String id,
    required ConflictModel conflict,
  }) {
    return SyncEvent(
      type: SyncEventType.conflictDetected,
      operationId: id,
      message: 'Conflict detected',
      timestamp: DateTime.now(),
      meta: {'conflict': conflict},
    );
  }

  // ============================================================
  // 🔥 NEW: FORCE UI REFRESH EVENT (IMPORTANT FIX)
  // ============================================================

  factory SyncEvent.syncRefresh() => SyncEvent(
    type: SyncEventType.syncRefresh,
    message: 'Force UI refresh after conflict resolution',
    timestamp: DateTime.now(),
  );

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'SyncEvent('
        'type: $type, '
        'operationId: $operationId, '
        'message: $message, '
        'meta: $meta'
        ')';
  }
}
