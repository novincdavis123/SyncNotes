import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';
import 'package:syncnotes/sync/history/sync_history_model.dart';
import 'package:syncnotes/core/enums/sync_status.dart';

/// ------------------------------------------------------------
/// SyncHistoryService (Step 9)
/// ------------------------------------------------------------
/// Stores and manages sync execution history
/// Used for analytics, debugging, and timeline tracking
/// ------------------------------------------------------------

class SyncHistoryService {
  final List<SyncHistoryModel> _history = [];

  /// ------------------------------------------------------------
  /// ADD HISTORY ENTRY (START)
  /// ------------------------------------------------------------

  SyncHistoryModel startOperation({required SyncOperationModel operation}) {
    final entry = SyncHistoryModel(
      id: operation.id,
      noteId: operation.noteId,
      type: operation.type,
      status: SyncStatus.pending,
      startedAt: DateTime.now().toUtc(),
      retryCount: operation.retryCount,
    );

    _history.add(entry);

    AppLogger.log("📊 History started for ${operation.id}");

    return entry;
  }

  /// ------------------------------------------------------------
  /// MARK SUCCESS
  /// ------------------------------------------------------------

  void markSuccess(String operationId) {
    final index = _history.indexWhere((e) => e.id == operationId);

    if (index == -1) return;

    _history[index] = _history[index].copyWith(
      status: SyncStatus.synced,
      completedAt: DateTime.now().toUtc(),
    );

    AppLogger.success("📊 History success: $operationId");
  }

  /// ------------------------------------------------------------
  /// MARK FAILURE
  /// ------------------------------------------------------------

  void markFailure(String operationId, {String? error}) {
    final index = _history.indexWhere((e) => e.id == operationId);

    if (index == -1) return;

    _history[index] = _history[index].copyWith(
      status: SyncStatus.failed,
      completedAt: DateTime.now().toUtc(),
      errorMessage: error,
    );

    AppLogger.error("📊 History failed: $operationId");
  }

  /// ------------------------------------------------------------
  /// MARK CONFLICT
  /// ------------------------------------------------------------

  void markConflict(String operationId) {
    final index = _history.indexWhere((e) => e.id == operationId);

    if (index == -1) return;

    _history[index] = _history[index].copyWith(
      status: SyncStatus.conflict,
      hadConflict: true,
    );

    AppLogger.log("⚠️ History conflict: $operationId");
  }

  /// ------------------------------------------------------------
  /// UPDATE RETRY COUNT
  /// ------------------------------------------------------------

  void incrementRetry(String operationId) {
    final index = _history.indexWhere((e) => e.id == operationId);

    if (index == -1) return;

    final current = _history[index];

    _history[index] = current.copyWith(retryCount: current.retryCount + 1);
  }

  /// ------------------------------------------------------------
  /// GET HISTORY
  /// ------------------------------------------------------------

  List<SyncHistoryModel> getAll() {
    return List.unmodifiable(_history);
  }

  List<SyncHistoryModel> getByNoteId(String noteId) {
    return _history.where((e) => e.noteId == noteId).toList();
  }

  List<SyncHistoryModel> getFailures() {
    return _history.where((e) => e.status == SyncStatus.failed).toList();
  }

  List<SyncHistoryModel> getConflicts() {
    return _history.where((e) => e.hadConflict).toList();
  }

  /// ------------------------------------------------------------
  /// ANALYTICS HELPERS
  /// ------------------------------------------------------------

  int get totalOperations => _history.length;

  int get successCount =>
      _history.where((e) => e.status == SyncStatus.synced).length;

  int get failureCount =>
      _history.where((e) => e.status == SyncStatus.failed).length;

  int get conflictCount => _history.where((e) => e.hadConflict).length;

  double get successRate {
    if (_history.isEmpty) return 0;
    return successCount / _history.length;
  }

  /// ------------------------------------------------------------
  /// CLEAR HISTORY
  /// ------------------------------------------------------------

  void clear() {
    _history.clear();
    AppLogger.log("🧹 Sync history cleared");
  }
}
