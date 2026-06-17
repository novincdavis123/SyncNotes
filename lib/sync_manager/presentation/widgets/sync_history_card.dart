import 'package:flutter/material.dart';
import 'package:syncnotes/sync_manager/history/sync_history_repository.dart';

class SyncHistoryCard extends StatelessWidget {
  final SyncHistoryRepository repository;
  final VoidCallback? onViewFullHistory;
  final VoidCallback? onClearHistory;

  const SyncHistoryCard({
    super.key,
    required this.repository,
    this.onViewFullHistory,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: repository.getHistorySummary(),
      builder: (context, snapshot) {
        final summary =
            snapshot.data ??
            {"total": 0, "success": 0, "failed": 0, "conflicts": 0};

        final int total = summary["total"] ?? 0;
        final int success = summary["success"] ?? 0;
        final int failed = summary["failed"] ?? 0;
        final int conflicts = summary["conflicts"] ?? 0;

        final double successRate = total == 0 ? 0 : success / total;

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
                    const Icon(Icons.history, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      "Sync History",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _buildBadge(successRate),
                  ],
                ),

                const SizedBox(height: 16),

                // METRICS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric("Total", total, Colors.black),
                    _metric("Success", success, Colors.green),
                    _metric("Failed", failed, Colors.red),
                    _metric("Conflicts", conflicts, Colors.orange),
                  ],
                ),

                const SizedBox(height: 16),

                // SUCCESS RATE BAR
                LinearProgressIndicator(
                  value: successRate,
                  backgroundColor: Colors.grey.shade200,
                  color: _getRateColor(successRate),
                  minHeight: 6,
                ),

                const SizedBox(height: 8),

                Text(
                  "Success Rate: ${(successRate * 100).toStringAsFixed(1)}%",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 16),

                // ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text("View History"),
                        onPressed: onViewFullHistory,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text("Clear"),
                        onPressed: onClearHistory,
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

  // =============================================================
  // BADGE
  // =============================================================

  Widget _buildBadge(double rate) {
    Color color;

    if (rate >= 0.9) {
      color = Colors.green;
    } else if (rate >= 0.6) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        "${(rate * 100).toStringAsFixed(0)}%",
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =============================================================
  // METRIC TILE
  // =============================================================

  Widget _metric(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
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

  // =============================================================
  // COLOR LOGIC
  // =============================================================

  Color _getRateColor(double rate) {
    if (rate >= 0.9) return Colors.green;
    if (rate >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
