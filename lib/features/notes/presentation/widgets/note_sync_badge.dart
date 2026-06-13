import 'package:flutter/material.dart';

import '../../../../core/enums/sync_status.dart';

class NoteSyncBadge extends StatelessWidget {
  final SyncStatus syncStatus;

  const NoteSyncBadge({super.key, required this.syncStatus});

  @override
  Widget build(BuildContext context) {
    switch (syncStatus) {
      case SyncStatus.synced:
        return const Chip(label: Text("Synced"));

      case SyncStatus.pending:
        return const Chip(label: Text("Pending"));

      case SyncStatus.conflict:
        return const Chip(label: Text("Conflict"));
    }
  }
}
