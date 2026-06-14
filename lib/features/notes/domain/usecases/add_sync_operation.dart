import '../entities/sync_operation.dart';
import '../repositories/sync_repository.dart';

class AddSyncOperation {
  final SyncRepository repository;

  AddSyncOperation(this.repository);

  Future<void> call(SyncOperation operation) {
    return repository.addOperation(operation);
  }
}
