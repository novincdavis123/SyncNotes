import 'package:flutter/material.dart';
import 'package:syncnotes/sync_manager/queue/sync_queue_analyzer.dart';
import 'package:syncnotes/sync_manager/queue/sync_queue_statistics.dart';

class RetryCard extends StatelessWidget {
  final SyncQueueAnalyzer analyzer;
  final VoidCallback? onViewDetails;
  final VoidCallback? onRetryAll;

  const RetryCard({
    super.key,
    required this.analyzer,
    this.onViewDetails,
    this.onRetryAll,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SyncQueueStatistics>(
      future: analyzer.analyze(),
      builder: (context, snapshot) {
        final analysis = snapshot.data ?? SyncQueueStatistics.initial();

        final retryCount = analysis.retryCount;
        final failed = analysis.failed;
        final pending = analysis.pending;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                const Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Retry Analysis",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // METRICS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric("Retries", retryCount, Colors.orange),
                    _metric("Failed", failed, Colors.red),
                    _metric("Pending", pending, Colors.blue),
                  ],
                ),

                const SizedBox(height: 16),

                // RISK INDICATOR
                _buildRiskIndicator(retryCount, failed),

                const SizedBox(height: 16),

                // ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text("Details"),
                        onPressed: onViewDetails,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.replay),
                        label: const Text("Retry All"),
                        onPressed: onRetryAll,
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
  // RISK INDICATOR
  // =============================================================

  Widget _buildRiskIndicator(int retries, int failed) {
    final riskScore = retries + (failed * 2);

    Color color;
    String label;

    if (riskScore == 0) {
      color = Colors.green;
      label = "Healthy Queue";
    } else if (riskScore < 5) {
      color = Colors.orange;
      label = "Moderate Retry Load";
    } else {
      color = Colors.red;
      label = "High Failure Risk";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
