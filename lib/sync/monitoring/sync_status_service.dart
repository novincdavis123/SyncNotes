import 'dart:async';

import 'package:syncnotes/core/enums/sync_status_state.dart';

class SyncStatusService {
  final StreamController<SyncStatusState> _controller =
      StreamController<SyncStatusState>.broadcast();

  SyncStatusState _currentStatus = SyncStatusState.idle;

  // ------------------------------------------------------------
  // CURRENT STATUS
  // ------------------------------------------------------------

  SyncStatusState get currentStatus => _currentStatus;

  // ------------------------------------------------------------
  // INITIAL STATUS
  // ------------------------------------------------------------

  SyncStatusState get initialStatus => SyncStatusState.idle;

  // ------------------------------------------------------------
  // STATUS STREAM
  // ------------------------------------------------------------

  Stream<SyncStatusState> get statusStream => _controller.stream;

  // ------------------------------------------------------------
  // UPDATE STATUS
  // ------------------------------------------------------------

  void updateStatus(SyncStatusState status) {
    if (_currentStatus == status) {
      return;
    }

    _currentStatus = status;

    if (!_controller.isClosed) {
      _controller.add(status);
    }
  }

  // ------------------------------------------------------------
  // RESET STATUS
  // ------------------------------------------------------------

  void reset() {
    updateStatus(SyncStatusState.idle);
  }

  // ------------------------------------------------------------
  // CLEANUP
  // ------------------------------------------------------------

  void dispose() {
    _controller.close();
  }
}
