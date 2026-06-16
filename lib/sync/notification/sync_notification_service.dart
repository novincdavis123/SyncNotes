import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/sync/sync_event.dart';

class SyncNotificationService {
  final Stream<SyncEvent> eventStream;
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  StreamSubscription? _subscription;

  SyncNotificationService({
    required this.eventStream,
    required this.messengerKey,
  });

  // ============================================================
  // START
  // ============================================================

  void start() {
    _subscription = eventStream.listen(_handleEvent);
    AppLogger.log("🔔 SyncNotificationService started");
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    AppLogger.log("🔕 SyncNotificationService disposed");
  }

  // ============================================================
  // EVENT HANDLER (EXHAUSTIVE FIXED)
  // ============================================================

  void _handleEvent(SyncEvent event) {
    switch (event.type) {
      // ---------------- CORE STATES ----------------
      case SyncEventType.started:
        _show("Sync started...", Colors.blue);
        break;

      case SyncEventType.completed:
        _show("Sync completed successfully", Colors.green);
        break;

      case SyncEventType.empty:
        _show("Nothing to sync", Colors.grey);
        break;

      case SyncEventType.error:
        _show(event.message, Colors.red);
        break;

      // ---------------- OPERATIONS ----------------
      case SyncEventType.operationStarted:
        _show("Operation started...", Colors.blueGrey);
        break;

      case SyncEventType.operationSuccess:
        _show("Item synced successfully", Colors.green);
        break;

      case SyncEventType.operationFailed:
        _show("Operation failed", Colors.red);
        break;

      // ---------------- RETRY ----------------
      case SyncEventType.retryScheduled:
        _show("Retry scheduled...", Colors.orange);
        break;

      // ---------------- CONFLICT ----------------
      case SyncEventType.conflictDetected:
        _show("Conflict detected", Colors.deepOrange);
        break;

      // ---------------- FINAL FAILURE ----------------
      case SyncEventType.permanentFailure:
        _show("Sync permanently failed", Colors.red);
        break;
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _show(String message, Color color) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
