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

  @HiveField(4)
  final String status;

  @HiveField(5)
  final int retryCount;

  @HiveField(6)
  final DateTime? lastTriedAt;

  @HiveField(7)
  final bool isInProgress;

  SyncOperationModel({
    required this.id,
    required this.noteId,
    required this.type,
    required this.timestamp,
    required this.status,
    this.retryCount = 0,
    this.lastTriedAt,
    required this.isInProgress,
  });

  SyncOperationModel copyWith({
    String? status,
    int? retryCount,
    DateTime? lastTriedAt,
    bool? isInProgress,
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
    );
  }
}
