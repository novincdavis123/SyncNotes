import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';
import 'package:syncnotes/features/notes/data/mapper/sync_mapper.dart';
import 'package:syncnotes/features/notes/domain/entities/sync_operation.dart';
import 'package:syncnotes/features/notes/domain/repositories/sync_repository.dart';
import 'package:syncnotes/sync/sync_service.dart';
import 'package:syncnotes/core/enums/sync_status.dart';

class SyncRepositoryImpl implements SyncRepository {
  final SyncLocalDataSource localDataSource;
  final SyncService syncService;

  SyncRepositoryImpl(this.localDataSource, this.syncService);

  @override
  Future<void> addOperation(SyncOperation operation) async {
    await localDataSource.addOperation(operation.toModel());
  }

  @override
  Future<void> sync() async {
    await syncService.processQueue();
  }

  @override
  Future<List<SyncOperation>> getPendingOperations() async {
    final operations = await localDataSource.getOperations();

    return operations
        .where((op) => op.status == SyncStatus.pending.name)
        .map((op) => op.toEntity())
        .toList();
  }

  @override
  Future<void> clearSyncedOperations() async {
    final operations = await localDataSource.getOperations();

    for (final op in operations) {
      if (op.status == SyncStatus.synced.name) {
        await localDataSource.removeOperation(op.id);
      }
    }
  }
}
