import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';
import 'package:syncnotes/sync_manager/history/sync_history_model.dart';

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

  /// 🔥 NEW: used by repository / cleanup / retry logic
  Future<void> deleteOperation(String id);

  /// 🔥 NEW: remove all operations for a note (important for delete + conflict recovery)
  Future<void> removeOperationsForNote(String noteId);

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
