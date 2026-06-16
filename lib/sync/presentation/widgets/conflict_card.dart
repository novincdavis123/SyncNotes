import 'package:flutter/material.dart';

import 'package:syncnotes/sync/queue/sync_queue_analyzer.dart';
import 'package:syncnotes/sync/queue/sync_queue_statistics.dart';

class ConflictCard extends StatelessWidget {
  final SyncQueueAnalyzer analyzer;
  final VoidCallback? onViewConflicts;
  final VoidCallback? onResolveAll;

  const ConflictCard({
    super.key,
    required this.analyzer,
    this.onViewConflicts,
    this.onResolveAll,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SyncQueueStatistics>(
      future: analyzer.analyze(),
      builder: (context, snapshot) {
        final analysis = snapshot.data ?? SyncQueueStatistics.initial();

        final int conflicts = analysis.conflicts;
        final int pending = analysis.pending;
        final int failed = analysis.failed;

        final bool hasConflicts = conflicts > 0;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: hasConflicts ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Conflict Status",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _statusBadge(hasConflicts),
                  ],
                ),

                const SizedBox(height: 16),

                // METRICS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric("Conflicts", conflicts, Colors.red),
                    _metric("Pending", pending, Colors.orange),
                    _metric("Failed", failed, Colors.grey),
                  ],
                ),

                const SizedBox(height: 16),

                // INFO MESSAGE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasConflicts
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasConflicts ? Colors.red : Colors.green,
                    ),
                  ),
                  child: Text(
                    hasConflicts
                        ? "Conflicts detected. Manual resolution required."
                        : "No conflicts detected. All syncs are clean.",
                    style: TextStyle(
                      color: hasConflicts ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text("View"),
                        onPressed: onViewConflicts,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.merge),
                        label: const Text("Resolve All"),
                        onPressed: hasConflicts ? onResolveAll : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= STATUS BADGE =================

  Widget _statusBadge(bool hasConflicts) {
    final color = hasConflicts ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        hasConflicts ? "ISSUES" : "CLEAN",
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= METRIC =================

  Widget _metric(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
