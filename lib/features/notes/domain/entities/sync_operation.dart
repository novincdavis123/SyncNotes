import 'sync_operation_type.dart';

class SyncOperation {
  final String id;
  final String noteId;
  final SyncOperationType type;
  final DateTime timestamp;
  final String status;

  // 🔥 PHASE 7 ADDITIONS
  final int retryCount;
  final DateTime? lastTriedAt;
  final bool isInProgress;

  SyncOperation({
    required this.id,
    required this.noteId,
    required this.type,
    required this.timestamp,
    required this.status,
    this.retryCount = 0,
    this.lastTriedAt,
    this.isInProgress = false,
  });
}
