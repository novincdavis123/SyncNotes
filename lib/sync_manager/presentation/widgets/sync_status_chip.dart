import 'package:flutter/material.dart';
import 'package:syncnotes/core/enums/sync_status.dart';

class SyncStatusChip extends StatelessWidget {
  final SyncStatus status;

  const SyncStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(_icon, size: 18, color: Colors.white),
      label: Text(
        _label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: _color,
    );
  }

  String get _label {
    switch (status) {
      case SyncStatus.pending:
        return "Pending";

      case SyncStatus.syncing:
        return "Syncing";

      case SyncStatus.synced:
        return "Synced";

      case SyncStatus.failed:
        return "Failed";

      case SyncStatus.offline:
        return "Offline";

      case SyncStatus.conflict:
        return "Conflict";
    }
  }

  IconData get _icon {
    switch (status) {
      case SyncStatus.pending:
        return Icons.schedule;

      case SyncStatus.syncing:
        return Icons.sync;

      case SyncStatus.synced:
        return Icons.check_circle;

      case SyncStatus.failed:
        return Icons.error;

      case SyncStatus.offline:
        return Icons.cloud_off;

      case SyncStatus.conflict:
        return Icons.warning_amber_rounded;
    }
  }

  Color get _color {
    switch (status) {
      case SyncStatus.pending:
        return Colors.orange;

      case SyncStatus.syncing:
        return Colors.blue;

      case SyncStatus.synced:
        return Colors.green;

      case SyncStatus.failed:
        return Colors.red;

      case SyncStatus.offline:
        return Colors.grey;

      case SyncStatus.conflict:
        return Colors.deepOrange;
    }
  }
}
