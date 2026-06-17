import 'package:flutter/material.dart';

import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/sync_manager/history/sync_history_model.dart';

class SyncHistoryTile extends StatelessWidget {
  final SyncHistoryModel history;

  const SyncHistoryTile({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_iconForStatus(history.status), size: 20),
        ),

        title: Text(
          "${history.type.toUpperCase()} • ${history.noteId}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text("Status: ${history.status.name}"),

            if (history.retryCount > 0) Text("Retries: ${history.retryCount}"),

            if (history.hadConflict)
              const Text(
                "Conflict detected",
                style: TextStyle(color: Colors.orange),
              ),

            if (history.errorMessage != null &&
                history.errorMessage!.isNotEmpty)
              Text(
                history.errorMessage!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 4),

            Text(
              history.completedAt != null
                  ? history.completedAt!.toLocal().toString()
                  : history.startedAt.toLocal().toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Icons.check_circle;

      case SyncStatus.failed:
        return Icons.error;

      case SyncStatus.pending:
        return Icons.schedule;

      case SyncStatus.syncing:
        return Icons.sync;

      case SyncStatus.offline:
        return Icons.cloud_off;

      case SyncStatus.conflict:
        return Icons.warning_amber_rounded;
    }
  }
}
