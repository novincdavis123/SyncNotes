import 'package:flutter/material.dart';

import 'package:syncnotes/sync/queue/sync_queue_analyzer.dart';
import 'package:syncnotes/sync/queue/sync_queue_statistics.dart';
import 'package:syncnotes/sync/monitoring/sync_status_service.dart';

class QueueStatusCard extends StatelessWidget {
  final SyncQueueAnalyzer analyzer;
  final SyncStatusService statusService;

  const QueueStatusCard({
    super.key,
    required this.analyzer,
    required this.statusService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SyncQueueStatistics>(
      future: analyzer.analyze(),
      builder: (context, snapshot) {
        final analysis = snapshot.data ?? SyncQueueStatistics.initial();

        final status = statusService.currentStatus.toString().split('.').last;

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
                    const Icon(Icons.storage, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      "Queue Status",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(status),
                  ],
                ),

                const SizedBox(height: 16),

                // METRICS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric("Pending", analysis.pending, Colors.orange),
                    _metric("In Progress", analysis.inProgress, Colors.blue),
                    _metric("Failed", analysis.failed, Colors.red),
                    _metric("Conflicts", analysis.conflicts, Colors.purple),
                  ],
                ),

                const SizedBox(height: 16),

                // PROGRESS BAR
                LinearProgressIndicator(
                  value: _calculateProgress(analysis),
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.green,
                  minHeight: 6,
                ),

                const SizedBox(height: 8),

                Text(
                  "Success Rate: ${(analysis.successRate * 100).toStringAsFixed(1)}%",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= STATUS BADGE =================

  Widget _buildStatusBadge(String status) {
    Color color;

    switch (status) {
      case "syncing":
        color = Colors.blue;
        break;
      case "offline":
        color = Colors.red;
        break;
      case "idle":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
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

  // ================= PROGRESS =================

  double _calculateProgress(SyncQueueStatistics analysis) {
    final total = analysis.total;
    if (total == 0) return 0;

    final completed = analysis.success + analysis.failed;
    return completed / total;
  }
}
