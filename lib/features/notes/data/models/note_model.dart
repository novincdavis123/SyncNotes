import 'package:hive_ce/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime lastModifiedAt;

  @HiveField(5)
  final DateTime? lastSyncedAt;

  @HiveField(6)
  final bool isDeleted;

  /// 🔥 CHANGED: Enum → String
  @HiveField(7)
  final String syncStatus;

  NoteModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.lastModifiedAt,
    this.lastSyncedAt,
    required this.isDeleted,
    required this.syncStatus,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    DateTime? lastSyncedAt,
    bool? isDeleted,
    String? syncStatus,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
