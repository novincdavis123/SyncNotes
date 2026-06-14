import '../entities/sync_operation.dart';

abstract class SyncRepository {
  Future<void> addOperation(SyncOperation operation);

  Future<void> sync();

  Future<List<SyncOperation>> getPendingOperations();

  Future<void> clearSyncedOperations();
}
