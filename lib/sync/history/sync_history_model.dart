import 'package:syncnotes/core/enums/sync_status.dart';

/// ------------------------------------------------------------
/// SyncHistoryModel (Clean + Dashboard Ready)
/// ------------------------------------------------------------
class SyncHistoryModel {
  final String id;
  final String noteId;

  /// create, update, delete
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

  // ------------------------------------------------------------
  // DERIVED PROPERTIES
  // ------------------------------------------------------------

  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }

  bool get isCompleted => completedAt != null;

  bool get isFailed => status == SyncStatus.failed;

  bool get isSuccess => status == SyncStatus.synced;

  bool get isPending => status == SyncStatus.pending;

  // ------------------------------------------------------------
  // COPY WITH
  // ------------------------------------------------------------

  SyncHistoryModel copyWith({
    String? type,
    SyncStatus? status,
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
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      hadConflict: hadConflict ?? this.hadConflict,
    );
  }

  // ------------------------------------------------------------
  // JSON
  // ------------------------------------------------------------

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
      id: json["id"],
      noteId: json["noteId"],
      type: json["type"] ?? "unknown",
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json["status"],
        orElse: () => SyncStatus.pending,
      ),
      startedAt: DateTime.parse(json["startedAt"]),
      completedAt: json["completedAt"] != null
          ? DateTime.parse(json["completedAt"])
          : null,
      retryCount: json["retryCount"] ?? 0,
      errorMessage: json["errorMessage"],
      hadConflict: json["hadConflict"] ?? false,
    );
  }

  @override
  String toString() {
    return '''
SyncHistoryModel(
  id: $id,
  noteId: $noteId,
  type: $type,
  status: $status,
  retryCount: $retryCount,
  conflict: $hadConflict
)
''';
  }
}
