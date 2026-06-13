import 'package:syncnotes/core/enums/sync_status.dart';

import '../../domain/entities/note_entity.dart';
import '../models/note_model.dart';

extension NoteModelMapper on NoteModel {
  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
      lastSyncedAt: lastSyncedAt,
      isDeleted: isDeleted,
      syncStatus: SyncStatus.values.byName(syncStatus),
    );
  }
}

extension NoteEntityMapper on NoteEntity {
  NoteModel toModel() {
    return NoteModel(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
      lastSyncedAt: lastSyncedAt,
      isDeleted: isDeleted,
      syncStatus: syncStatus.name,
    );
  }
}
