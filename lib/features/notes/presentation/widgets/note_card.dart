import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/enums/sync_status.dart';

import '../../domain/entities/note_entity.dart';

import 'note_sync_badge.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  // NEW: callbacks for delete & edit
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
  });

  bool get hasConflict => note.syncStatus == SyncStatus.conflict.name;

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit"),
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: hasConflict ? 5 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasConflict
            ? const BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        // TAP → EDIT
        onTap: onEdit,

        // LONG PRESS → ACTIONS
        onLongPress: () => _showActions(context),

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  NoteSyncBadge(syncStatus: note.syncStatus),
                ],
              ),

              const SizedBox(height: 10),

              // BODY
              Text(
                note.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 12),

              // FOOTER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Last updated • ${DateFormatter.format(note.lastModifiedAt)}",
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  if (hasConflict)
                    const Icon(
                      Icons.sync_problem,
                      color: Colors.orange,
                      size: 18,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
