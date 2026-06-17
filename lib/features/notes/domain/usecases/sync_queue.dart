import '../repositories/sync_repository.dart';

class SyncQueueUseCase {
  final SyncRepository repository;

  SyncQueueUseCase(this.repository);

  Future<void> call() async {
    await repository.sync();
  }
}
