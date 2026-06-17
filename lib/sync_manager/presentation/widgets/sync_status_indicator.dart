import 'package:flutter/material.dart';

import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/di/injection.dart';
import 'package:syncnotes/sync_manager/monitoring/sync_status_service.dart';

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final syncStatusService = sl<SyncStatusService>();

    return StreamBuilder<SyncStatus>(
      stream: syncStatusService.statusStream,
      initialData: syncStatusService.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.pending;

        final color = _colorForStatus(status);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: Row(
              key: ValueKey(status),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconForStatus(status), size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  _labelForStatus(status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ICONS
  // ============================================================

  IconData _iconForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return Icons.pause_circle_outline;

      case SyncStatus.syncing:
        return Icons.sync;

      case SyncStatus.synced:
        return Icons.check_circle_outline;

      case SyncStatus.offline:
        return Icons.cloud_off_outlined;

      case SyncStatus.failed:
        return Icons.error_outline;

      case SyncStatus.conflict:
        return Icons.warning_amber_outlined;
    }
  }

  // ============================================================
  // LABELS
  // ============================================================

  String _labelForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return 'Pending';

      case SyncStatus.syncing:
        return 'Syncing...';

      case SyncStatus.synced:
        return 'Synced';

      case SyncStatus.offline:
        return 'Offline';

      case SyncStatus.failed:
        return 'Sync Failed';

      case SyncStatus.conflict:
        return 'Conflict';
    }
  }

  // ============================================================
  // COLORS
  // ============================================================

  Color _colorForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return Colors.grey;

      case SyncStatus.syncing:
        return Colors.blue;

      case SyncStatus.synced:
        return Colors.green;

      case SyncStatus.offline:
        return Colors.orange;

      case SyncStatus.failed:
        return Colors.red;

      case SyncStatus.conflict:
        return Colors.purple;
    }
  }
}
