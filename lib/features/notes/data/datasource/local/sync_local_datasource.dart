import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';
import 'package:syncnotes/sync/history/sync_history_model.dart';

/// ============================================================
/// SyncLocalDataSource (FINAL CLEAN CONTRACT)
/// ============================================================
abstract class SyncLocalDataSource {
  // ============================================================
  // OPERATIONS (QUEUE)
  // ============================================================

  Future<void> addOperation(SyncOperationModel model);

  Future<List<SyncOperationModel>> getOperations();

  Future<void> removeOperation(String id);

  // ============================================================
  // HISTORY
  // ============================================================

  Future<void> addHistory(SyncHistoryModel model);

  Future<List<SyncHistoryModel>> getAllHistory();

  Future<void> deleteHistory(String id);

  Future<void> clearHistory();

  // ============================================================
  // CLEANUP
  // ============================================================

  Future<void> cleanupOldFailedOperations();
}
