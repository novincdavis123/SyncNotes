import 'package:hive_ce/hive.dart';
import 'package:syncnotes/app/app_logger.dart';

import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';
import 'package:syncnotes/sync_manager/history/sync_history_model.dart';

import 'sync_local_datasource.dart';

class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  final Box<SyncOperationModel> operationBox;
  final Box historyBox;

  SyncLocalDataSourceImpl({
    required this.operationBox,
    required this.historyBox,
  });

  // ============================================================
  // OPERATIONS (QUEUE)
  // ============================================================

  @override
  Future<void> addOperation(SyncOperationModel model) async {
    AppLogger.sync("Saved operation: ${model.id}");
    await operationBox.put(model.id, model);
  }

  @override
  Future<List<SyncOperationModel>> getOperations() async {
    return operationBox.values.toList();
  }

  @override
  Future<void> removeOperation(String id) async {
    await operationBox.delete(id);
  }

  // 🔥 NEW REQUIRED METHOD
  @override
  Future<void> deleteOperation(String id) async {
    await operationBox.delete(id);
  }

  // 🔥 NEW REQUIRED METHOD
  @override
  Future<void> removeOperationsForNote(String noteId) async {
    final keysToDelete = <String>[];

    for (final op in operationBox.values) {
      if (op.noteId == noteId) {
        keysToDelete.add(op.id);
      }
    }

    for (final key in keysToDelete) {
      await operationBox.delete(key);
    }
  }

  // ============================================================
  // HISTORY
  // ============================================================

  @override
  Future<void> addHistory(SyncHistoryModel model) async {
    AppLogger.sync("Saved history: ${model.id}");
    await historyBox.put(model.id, model.toJson());
  }

  @override
  Future<List<SyncHistoryModel>> getAllHistory() async {
    final list = historyBox.values
        .map((e) => SyncHistoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list;
  }

  @override
  Future<void> deleteHistory(String id) async {
    await historyBox.delete(id);
  }

  @override
  Future<void> clearHistory() async {
    await historyBox.clear();
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  Future<void> cleanupOldFailedOperations() async {
    final ops = operationBox.values.toList();

    for (final op in ops) {
      final isFailed = op.status.toString().toLowerCase().contains("failed");

      if (isFailed) {
        final age = DateTime.now().difference(op.timestamp);

        if (age.inDays > 7) {
          await operationBox.delete(op.id);
        }
      }
    }
  }
}
