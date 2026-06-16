import '../../domain/entities/sync_operation.dart';
import '../../domain/entities/sync_operation_type.dart';
import '../models/sync_operation_model.dart';

extension SyncMapper on SyncOperationModel {
  SyncOperation toEntity() {
    return SyncOperation(
      id: id,
      noteId: noteId,
      type: _mapType(type),
      timestamp: timestamp,
      status: status,

      // Step 7 additions
      retryCount: retryCount,
      lastTriedAt: lastTriedAt,
      isInProgress: isInProgress,

      // Conflict resolution data
      title: title,
      body: body,
    );
  }

  SyncOperationType _mapType(String value) {
    return SyncOperationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SyncOperationType.create,
    );
  }
}

extension SyncEntityMapper on SyncOperation {
  SyncOperationModel toModel() {
    return SyncOperationModel(
      id: id,
      noteId: noteId,
      type: type.name,
      timestamp: timestamp,
      status: status,

      // Step 7 additions
      retryCount: retryCount,
      lastTriedAt: lastTriedAt,
      isInProgress: isInProgress,

      // Conflict resolution data
      title: title,
      body: body,
    );
  }
}
