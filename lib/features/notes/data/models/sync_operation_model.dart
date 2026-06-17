import 'package:hive_ce/hive.dart';

part 'sync_operation_model.g.dart';

@HiveType(typeId: 10)
class SyncOperationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String noteId;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final DateTime timestamp;

  /// FIXED: use enum-safe string but future-proof
  @HiveField(4)
  final String status;

  @HiveField(5)
  final int retryCount;

  @HiveField(6)
  final DateTime? lastTriedAt;

  @HiveField(7)
  final bool isInProgress;

  @HiveField(8)
  final String title;

  @HiveField(9)
  final String body;

  SyncOperationModel({
    required this.id,
    required this.noteId,
    required this.type,
    required this.timestamp,
    required this.status,
    this.retryCount = 0,
    this.lastTriedAt,
    required this.isInProgress,
    required this.title,
    required this.body,
  });

  // =========================================================
  // COPY WITH (SAFE UPDATES)
  // =========================================================

  SyncOperationModel copyWith({
    String? status,
    int? retryCount,
    DateTime? lastTriedAt,
    bool? isInProgress,
    String? title,
    String? body,
  }) {
    return SyncOperationModel(
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

  // =========================================================
  // SAFE MAP (FIXED FOR CONFLICT + API)
  // =========================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id, // FIXED (was noteId)
      'noteId': noteId,
      'title': title,
      'body': body,
      'updatedAt': timestamp.toUtc().toIso8601String(),
    };
  }

  // =========================================================
  // HELPER (OPTIONAL BUT USEFUL)
  // =========================================================

  bool get isFailed => status == 'failed';
  bool get isConflict => status == 'conflict';
  bool get isPending => status == 'pending';
}
