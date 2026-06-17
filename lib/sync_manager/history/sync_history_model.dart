import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';

/// ============================================================
/// Sync History Model
/// ============================================================

class SyncHistoryModel {
  final String id;

  final String noteId;

  /// create / update / delete
  final String type;

  final SyncStatus status;

  final DateTime startedAt;

  final DateTime? completedAt;

  final int retryCount;

  final String? errorMessage;

  final bool hadConflict;

  const SyncHistoryModel({
    required this.id,
    required this.noteId,
    required this.type,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.retryCount = 0,
    this.errorMessage,
    this.hadConflict = false,
  });

  // ============================================================
  // FACTORY FROM SYNC OPERATION
  // ============================================================

  factory SyncHistoryModel.fromOperation(
    SyncOperationModel operation, {
    required SyncStatus status,
    String? errorMessage,
    bool hadConflict = false,
  }) {
    final now = DateTime.now().toUtc();

    return SyncHistoryModel(
      id: operation.id,
      noteId: operation.noteId,
      type: operation.type,
      status: status,
      startedAt: now,
      completedAt: now,
      retryCount: operation.retryCount,
      errorMessage: errorMessage,
      hadConflict: hadConflict,
    );
  }

  // ============================================================
  // DERIVED PROPERTIES
  // ============================================================

  Duration? get duration {
    if (completedAt == null) return null;

    return completedAt!.difference(startedAt);
  }

  bool get isCompleted => completedAt != null;

  bool get isSuccess => status == SyncStatus.synced;

  bool get isFailed => status == SyncStatus.failed;

  bool get isPending => status == SyncStatus.pending;

  bool get isConflict => status == SyncStatus.conflict;

  bool get isSyncing => status == SyncStatus.syncing;

  bool get isOffline => status == SyncStatus.offline;

  bool get hasRetry => retryCount > 0;

  bool get hasError => errorMessage != null;

  bool get isTerminalState =>
      status == SyncStatus.synced ||
      status == SyncStatus.failed ||
      status == SyncStatus.conflict;

  // ============================================================
  // COPY
  // ============================================================

  SyncHistoryModel copyWith({
    String? type,
    SyncStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? retryCount,
    String? errorMessage,
    bool? hadConflict,
  }) {
    return SyncHistoryModel(
      id: id,
      noteId: noteId,
      type: type ?? this.type,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      hadConflict: hadConflict ?? this.hadConflict,
    );
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "noteId": noteId,
      "type": type,
      "status": status.name,
      "startedAt": startedAt.toIso8601String(),
      "completedAt": completedAt?.toIso8601String(),
      "retryCount": retryCount,
      "errorMessage": errorMessage,
      "hadConflict": hadConflict,
    };
  }

  factory SyncHistoryModel.fromJson(Map<String, dynamic> json) {
    return SyncHistoryModel(
      id: json["id"] as String,
      noteId: json["noteId"] as String,
      type: json["type"] as String? ?? "unknown",
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json["status"],
        orElse: () => SyncStatus.pending,
      ),
      startedAt: DateTime.parse(json["startedAt"] as String),
      completedAt: json["completedAt"] != null
          ? DateTime.parse(json["completedAt"] as String)
          : null,
      retryCount: json["retryCount"] as int? ?? 0,
      errorMessage: json["errorMessage"] as String?,
      hadConflict: json["hadConflict"] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return '''
SyncHistoryModel(
  id: $id,
  noteId: $noteId,
  type: $type,
  status: ${status.name},
  retryCount: $retryCount,
  conflict: $hadConflict,
)
''';
  }
}
