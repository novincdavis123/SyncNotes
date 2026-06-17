import 'package:flutter/material.dart';

import 'package:syncnotes/features/conflict/data/models/conflict_model.dart';

class ConflictCard extends StatelessWidget {
  final ConflictModel conflict;

  final VoidCallback? onResolve;
  final VoidCallback? onDismiss;

  const ConflictCard({
    super.key,
    required this.conflict,
    this.onResolve,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final local = conflict.localData;
    final remote = conflict.remoteData;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Conflict • ${conflict.noteId}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              "Local Version",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              local["title"]?.toString() ?? "",
              style: const TextStyle(fontSize: 15),
            ),

            Text(
              local["body"]?.toString() ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Divider(height: 24),

            const Text(
              "Server Version",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              remote["title"]?.toString() ?? "",
              style: const TextStyle(fontSize: 15),
            ),

            Text(
              remote["body"]?.toString() ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            Text(
              "Detected: ${conflict.detectedAt}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onResolve,
                    icon: const Icon(Icons.merge),
                    label: const Text("Resolve"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close),
                    label: const Text("Dismiss"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
