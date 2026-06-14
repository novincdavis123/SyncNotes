import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';

abstract class SyncLocalDataSource {
  Future<void> addOperation(SyncOperationModel model);
  Future<List<SyncOperationModel>> getOperations();
  Future<void> removeOperation(String id);
}
