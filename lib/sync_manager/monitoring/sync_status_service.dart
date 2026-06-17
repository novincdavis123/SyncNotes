import 'dart:async';

import 'package:syncnotes/core/enums/sync_status.dart';

class SyncStatusService {
  final StreamController<SyncStatus> _controller =
      StreamController<SyncStatus>.broadcast();

  SyncStatus _currentStatus = SyncStatus.pending;

  // ============================================================
  // CURRENT STATUS
  // ============================================================

  SyncStatus get currentStatus => _currentStatus;

  // ============================================================
  // INITIAL STATUS
  // ============================================================

  SyncStatus get initialStatus => SyncStatus.pending;

  // ============================================================
  // STATUS STREAM
  // ============================================================

  Stream<SyncStatus> get statusStream => _controller.stream;

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  void updateStatus(SyncStatus status) {
    if (_currentStatus == status) return;

    _currentStatus = status;

    if (!_controller.isClosed) {
      _controller.add(status);
    }
  }

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    updateStatus(SyncStatus.pending);
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  void dispose() {
    _controller.close();
  }
}
