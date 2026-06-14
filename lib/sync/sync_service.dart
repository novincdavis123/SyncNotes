import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/features/notes/data/datasource/local/sync_local_datasource.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';

import 'package:syncnotes/sync/retry/retry_policy.dart';
import 'package:syncnotes/sync/retry/default_retry_policy.dart';
import 'package:syncnotes/sync/retry/retry_utils.dart';
import 'package:syncnotes/sync/retry/retry_decision.dart';
import 'package:syncnotes/sync/retry/sync_failure_type.dart';

import 'package:syncnotes/features/sync/data/services/fake_api_service.dart';

class SyncService {
  final SyncLocalDataSource localDataSource;
  final FakeApiService apiService;
  final RetryPolicy retryPolicy;

  bool _isRunning = false;

  // 🔥 concurrency control
  int _activeTasks = 0;
  final int _maxConcurrentTasks = 3;

  SyncService(
    this.localDataSource,
    this.apiService, {
    this.retryPolicy = defaultRetryPolicy,
  });

  // ------------------------------------------------------------
  // QUEUE PROCESSOR (BATCH + PRIORITY)
  // ------------------------------------------------------------

  Future<void> processQueue() async {
    AppLogger.log('🚀 Sync queue started');

    if (_isRunning) return;

    _isRunning = true;

    try {
      final operations = await localDataSource.getOperations();

      AppLogger.log('📦 Found ${operations.length} operations');

      final sorted = _sortOperations(operations);

      final batch = sorted.take(10).toList();

      AppLogger.log('⚡ Processing batch of ${batch.length}');

      for (final op in batch) {
        await _processSingleOperation(op);
      }

      AppLogger.success('🎉 Queue processed successfully');
    } catch (e) {
      AppLogger.error('Queue processing failed', e);
    } finally {
      _isRunning = false;
    }
  }

  // ------------------------------------------------------------
  // PRIORITY SORTING
  // ------------------------------------------------------------

  List<SyncOperationModel> _sortOperations(List<SyncOperationModel> ops) {
    final sorted = List<SyncOperationModel>.from(ops);

    sorted.sort((a, b) {
      // pending first
      if (a.status != b.status) {
        if (a.status == 'pending') return -1;
        if (b.status == 'pending') return 1;
      }

      // lower retry first
      if (a.retryCount != b.retryCount) {
        return a.retryCount.compareTo(b.retryCount);
      }

      // oldest first
      return a.timestamp.compareTo(b.timestamp);
    });

    return sorted;
  }

  // ------------------------------------------------------------
  // CONCURRENCY CONTROL WRAPPER
  // ------------------------------------------------------------

  Future<void> _processSingleOperation(SyncOperationModel op) async {
    if (_activeTasks >= _maxConcurrentTasks) {
      AppLogger.log('⏸️ Skipping ${op.id} (concurrency limit)');
      return;
    }

    _activeTasks++;

    try {
      await _processInternal(op);
    } finally {
      _activeTasks--;
    }
  }

  // ------------------------------------------------------------
  // CORE PROCESSING LOGIC
  // ------------------------------------------------------------

  Future<void> _processInternal(SyncOperationModel op) async {
    try {
      AppLogger.log('🔒 Locking op ${op.id}');

      final locked = op.copyWith(isInProgress: true);
      await localDataSource.addOperation(locked);

      final success = await apiService.pushToServer(op);

      if (success) {
        AppLogger.success('✅ Synced ${op.id}');
        await localDataSource.removeOperation(op.id);
        return;
      }

      AppLogger.error('❌ Server rejected ${op.id}');
      await _handleFailure(op, SyncFailureType.server);
    } catch (e) {
      AppLogger.error('💥 Network error for ${op.id}', e);
      await _handleFailure(op, SyncFailureType.network);
    } finally {
      AppLogger.log('🔓 Unlocking op ${op.id}');

      final reset = op.copyWith(isInProgress: false);
      await localDataSource.addOperation(reset);
    }
  }

  // ------------------------------------------------------------
  // FAILURE + RETRY ENGINE (UNCHANGED LOGIC)
  // ------------------------------------------------------------

  Future<void> _handleFailure(
    SyncOperationModel op,
    SyncFailureType type,
  ) async {
    final shouldRetry = shouldRetryOperation(type, op.retryCount, retryPolicy);

    if (!shouldRetry) {
      AppLogger.error('💀 Permanently failed ${op.id}');

      final failed = op.copyWith(status: 'failed', isInProgress: false);

      await localDataSource.addOperation(failed);
      return;
    }

    final delay = calculateDelay(retryPolicy, op.retryCount);

    AppLogger.log(
      '⏳ Retrying ${op.id} after ${delay.inSeconds}s (attempt ${op.retryCount + 1})',
    );

    await Future.delayed(delay);

    final updated = SyncOperationModel(
      id: op.id,
      noteId: op.noteId,
      type: op.type,
      timestamp: op.timestamp,
      status: 'pending',
      retryCount: op.retryCount + 1,
      lastTriedAt: DateTime.now().toUtc(),
      isInProgress: false,
    );

    await localDataSource.addOperation(updated);
  }

  // ------------------------------------------------------------
  // RECOVERY ENGINE
  // ------------------------------------------------------------

  Future<void> recoverStuckOperations() async {
    AppLogger.log('🔄 Recovery started');

    try {
      final operations = await localDataSource.getOperations();

      int recoveredCount = 0;

      for (final op in operations) {
        if (op.isInProgress) {
          recoveredCount++;

          final recovered = op.copyWith(isInProgress: false, status: 'pending');

          await localDataSource.addOperation(recovered);
        }
      }

      AppLogger.success('♻️ Recovered $recoveredCount stuck operations');
    } catch (e) {
      AppLogger.error('Recovery failed', e);
    }
  }
}
