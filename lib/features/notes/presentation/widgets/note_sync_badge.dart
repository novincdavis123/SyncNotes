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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_label(syncStatus)),
      backgroundColor: _color(syncStatus).withOpacity(0.15),
      labelStyle: TextStyle(
        color: _color(syncStatus),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
