import 'package:flutter/material.dart';

import 'package:syncnotes/core/enums/sync_status_state.dart';
import 'package:syncnotes/di/injection.dart';
import 'package:syncnotes/sync/monitoring/sync_status_service.dart';

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final syncStatusService = sl<SyncStatusService>();

    return StreamBuilder<SyncStatusState>(
      stream: syncStatusService.statusStream,
      initialData: syncStatusService.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatusState.idle;

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

  IconData _iconForStatus(SyncStatusState status) {
    switch (status) {
      case SyncStatusState.idle:
        return Icons.pause_circle_outline;

      case SyncStatusState.syncing:
        return Icons.sync;

      case SyncStatusState.success:
        return Icons.check_circle_outline;

      case SyncStatusState.offline:
        return Icons.cloud_off_outlined;

      case SyncStatusState.error:
        return Icons.error_outline;
    }
  }

  String _labelForStatus(SyncStatusState status) {
    switch (status) {
      case SyncStatusState.idle:
        return 'Idle';

      case SyncStatusState.syncing:
        return 'Syncing...';

      case SyncStatusState.success:
        return 'Synced';

      case SyncStatusState.offline:
        return 'Offline';

      case SyncStatusState.error:
        return 'Sync Failed';
    }
  }

  Color _colorForStatus(SyncStatusState status) {
    switch (status) {
      case SyncStatusState.idle:
        return Colors.grey;

      case SyncStatusState.syncing:
        return Colors.blue;

      case SyncStatusState.success:
        return Colors.green;

      case SyncStatusState.offline:
        return Colors.orange;

      case SyncStatusState.error:
        return Colors.red;
    }
  }
}
