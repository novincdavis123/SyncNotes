import 'sync_operation_type.dart';

class SyncOperation {
  final String id;
  final String noteId;
  final SyncOperationType type;
  final DateTime timestamp;
  final String status;

  // ============================================================
  // STEP 7 RETRY & RECOVERY
  // ============================================================

  final int retryCount;
  final DateTime? lastTriedAt;
  final bool isInProgress;

  // ============================================================
  // STEP 7 CONFLICT RESOLUTION DATA
  // ============================================================

  final String title;
  final String body;

  const SyncOperation({
    required this.id,
    required this.noteId,
    required this.type,
    required this.timestamp,
    required this.status,
    this.retryCount = 0,
    this.lastTriedAt,
    this.isInProgress = false,
    this.title = '',
    this.body = '',
  });

  SyncOperation copyWith({
    String? status,
    int? retryCount,
    DateTime? lastTriedAt,
    bool? isInProgress,
    String? title,
    String? body,
  }) {
    return SyncOperation(
      id: id,
      noteId: noteId,
      type: type,
      timestamp: timestamp,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastTriedAt: lastTriedAt ?? this.lastTriedAt,
      isInProgress: isInProgress ?? this.isInProgress,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }
}
