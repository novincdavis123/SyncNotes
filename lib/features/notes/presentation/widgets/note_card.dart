import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/note_entity.dart';
import 'note_sync_badge.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const NoteCard({super.key, required this.note, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 8),
              Text(
                note.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                "Last updated • ${DateFormatter.format(note.lastModifiedAt)}",
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
