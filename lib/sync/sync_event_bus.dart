import 'dart:async';

import 'sync_event.dart';

class SyncEventBus {
  final StreamController<SyncEvent> _controller =
      StreamController<SyncEvent>.broadcast();

  /// Stream listened to by UI, debug panel, etc.
  Stream<SyncEvent> get stream => _controller.stream;

  /// Whether anyone is currently listening.
  bool get hasListener => _controller.hasListener;

  /// Emit a sync event safely.
  void emit(SyncEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  /// Dispose the event bus.
  Future<void> dispose() async {
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
