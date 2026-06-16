import 'package:hive_ce/hive.dart';

part 'sync_operation_model.g.dart';

@HiveType(typeId: 10)
class SyncOperationModel extends HiveObject {
  @HiveField(0)
  final String id;

  /// Note ID
  @HiveField(1)
  final String noteId;

  /// create / update / delete
  @HiveField(2)
  final String type;

  /// Local operation timestamp
  @HiveField(3)
  final DateTime timestamp;

  /// pending / synced / failed / conflict
  @HiveField(4)
  final String status;

  @HiveField(5)
  final int retryCount;

  @HiveField(6)
  final DateTime? lastTriedAt;

  @HiveField(7)
  final bool isInProgress;

  /// Step 7: Note title
  @HiveField(8)
  final String title;

  /// Step 7: Note body
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

  /// Convenient serialization for conflict detection
  Map<String, dynamic> toMap() {
    return {
      'id': noteId,
      'title': title,
      'body': body,
      'updatedAt': timestamp.toIso8601String(),
    };
  }
}
