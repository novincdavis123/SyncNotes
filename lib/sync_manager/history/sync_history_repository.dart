import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';

import 'sync_history_model.dart';

class SyncHistoryRepository {
  final SyncLocalDataSource localDataSource;

  const SyncHistoryRepository(this.localDataSource);

  // ============================================================
  // ADD HISTORY
  // ============================================================

  Future<void> addHistory(SyncHistoryModel history) async {
    await localDataSource.addHistory(history);
  }

  // ============================================================
  // ADD HISTORY FROM OPERATION
  // ============================================================

  Future<void> addHistoryFromOperation(
    SyncOperationModel operation, {
    SyncStatus? status,
    String? errorMessage,
    bool hadConflict = false,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final history = SyncHistoryModel(
      id: operation.id,
      noteId: operation.noteId,
      type: operation.type,
      status: status ?? _parseStatus(operation.status),
      startedAt: startedAt ?? DateTime.now().toUtc(),
      completedAt: completedAt ?? DateTime.now().toUtc(),
      retryCount: operation.retryCount,
      errorMessage: errorMessage,
      hadConflict: hadConflict,
    );

    await addHistory(history);
  }

  // ============================================================
  // SAFE STATUS PARSER
  // ============================================================

  SyncStatus _parseStatus(dynamic status) {
    if (status is SyncStatus) {
      return status;
    }

    final value = status.toString().trim();

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

    history.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    return history;
  }

  // ============================================================
  // HISTORY SUMMARY
  // ============================================================

  Future<Map<String, int>> getHistorySummary() async {
    final history = await getAllHistory();

    return {
      "total": history.length,
      "success": history.where((e) => e.status == SyncStatus.synced).length,
      "failed": history.where((e) => e.status == SyncStatus.failed).length,
      "pending": history.where((e) => e.status == SyncStatus.pending).length,
      "syncing": history.where((e) => e.status == SyncStatus.syncing).length,
      "offline": history.where((e) => e.status == SyncStatus.offline).length,
      "conflict": history.where((e) => e.status == SyncStatus.conflict).length,
      "retried": history.where((e) => e.retryCount > 0).length,
    };
  }

  // ============================================================
  // RECENT HISTORY
  // ============================================================

  Future<List<SyncHistoryModel>> getRecentHistory({int limit = 20}) async {
    final history = await getAllHistory();

    if (history.length <= limit) {
      return history;
    }

    return history.take(limit).toList();
  }

  // ============================================================
  // CLEAR HISTORY
  // ============================================================

  Future<void> clearHistory() async {
    await localDataSource.clearHistory();
  }
}
