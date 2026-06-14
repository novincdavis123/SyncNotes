import 'package:hive_ce/hive.dart';
import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';
import 'sync_local_datasource.dart';

class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  final Box<SyncOperationModel> box;

  SyncLocalDataSourceImpl(this.box);

  @override
  Future<void> addOperation(SyncOperationModel model) async {
    AppLogger.sync("Saved to box: ${model.id}");
    await box.put(model.id, model);
  }

  @override
  Future<List<SyncOperationModel>> getOperations() async {
    return box.values.toList();
  }

  @override
  Future<void> removeOperation(String id) async {
    await box.delete(id);
  }

  Future<void> cleanupOldFailedOperations() async {
    final ops = box.values.toList();

    for (final op in ops) {
      if (op.status == 'failed') {
        final age = DateTime.now().difference(op.timestamp);

        // remove failed ops older than 7 days
        if (age.inDays > 7) {
          await box.delete(op.id);
        }
      }
    }
  }
}
