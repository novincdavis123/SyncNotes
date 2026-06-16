import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';
import 'sync_history_model.dart';

class SyncHistoryRepository {
  final SyncLocalDataSource localDataSource;

  SyncHistoryRepository(this.localDataSource);

  // ============================================================
  // ADD HISTORY FROM OPERATION (FIXED)
  // ============================================================

  Future<void> addHistoryFromOperation(
    SyncOperationModel operation, {
    String? errorMessage,
    bool hadConflict = false,
  }) async {
    final history = SyncHistoryModel(
      id: operation.id,
      noteId: operation.noteId,
      type: operation.type,

      // ✅ FIXED: SAFE ENUM HANDLING (NO STRING MAGIC)
      status: _parseStatus(operation.status),

      startedAt: DateTime.now().toUtc(),
      completedAt: DateTime.now().toUtc(),
      retryCount: operation.retryCount,
      errorMessage: errorMessage,
      hadConflict: hadConflict,
    );

    await localDataSource.addHistory(history);
  }

  // ============================================================
  // SAFE STATUS PARSER
  // ============================================================

  SyncStatus _parseStatus(dynamic status) {
    if (status is SyncStatus) return status;

    final String value = status.toString();

    return SyncStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SyncStatus.pending,
    );
  }

  // ============================================================
  // GET ALL HISTORY
  // ============================================================

  Future<List<SyncHistoryModel>> getAllHistory() async {
    final history = await localDataSource.getAllHistory();

    history.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return history;
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Future<Map<String, int>> getHistorySummary() async {
    final history = await localDataSource.getAllHistory();

    return {
      "total": history.length,
      "success": history.where((e) => e.status == SyncStatus.synced).length,
      "failed": history.where((e) => e.status == SyncStatus.failed).length,
      "conflict": history.where((e) => e.hadConflict).length,
      "retried": history.where((e) => e.retryCount > 0).length,
    };
  }

  // ============================================================
  // CLEAR
  // ============================================================

  Future<void> clearAll() async {
    await localDataSource.clearHistory();
  }
}
