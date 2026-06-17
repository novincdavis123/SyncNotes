import 'package:flutter/material.dart';
import '../../../../core/enums/sync_status.dart';

class NoteSyncBadge extends StatelessWidget {
  final SyncStatus syncStatus;

  const NoteSyncBadge({super.key, required this.syncStatus});

  Color _color(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Colors.green;

      case SyncStatus.pending:
        return Colors.orange;

      case SyncStatus.failed:
        return Colors.red;

      case SyncStatus.conflict:
        return Colors.purple;

      case SyncStatus.syncing:
        return Colors.blue;

      case SyncStatus.offline:
        return Colors.grey;
    }
  }

  String _label(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return "Synced";

      case SyncStatus.pending:
        return "Pending";

      case SyncStatus.failed:
        return "Failed";

      case SyncStatus.conflict:
        return "Conflict";

      case SyncStatus.syncing:
        return "Syncing";

      case SyncStatus.offline:
        return "Offline";
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(syncStatus);

    return Chip(
      label: Text(_label(syncStatus)),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
