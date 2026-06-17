import '../../../../core/enums/sync_status.dart';

class NoteEntity {
  final String id;
  final String title;
  final String body;

  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final DateTime? lastSyncedAt;

  final bool isDeleted;

  final SyncStatus syncStatus;

  // 🔥 NEW: conflict state (local metadata only)
  final String? conflictResolution;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.lastModifiedAt,
    this.lastSyncedAt,
    required this.isDeleted,
    required this.syncStatus,
    this.conflictResolution,
  });

  NoteEntity copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    DateTime? lastSyncedAt,
    bool? isDeleted,
    SyncStatus? syncStatus,

    // 🔥 NEW FIELD
    String? conflictResolution,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,

      // 🔥 NEW FIELD
      conflictResolution: conflictResolution ?? this.conflictResolution,
    );
  }
}
