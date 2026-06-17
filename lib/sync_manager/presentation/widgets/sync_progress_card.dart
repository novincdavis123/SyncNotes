import 'package:flutter/material.dart';

import 'package:syncnotes/sync_manager/monitoring/sync_status_service.dart';
import 'package:syncnotes/sync_manager/queue/sync_queue_analyzer.dart';
import 'package:syncnotes/sync_manager/queue/sync_queue_statistics.dart';

class SyncProgressCard extends StatelessWidget {
  final SyncStatusService statusService;
  final SyncQueueAnalyzer analyzer;

  const SyncProgressCard({
    super.key,
    required this.statusService,
    required this.analyzer,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SyncQueueStatistics>(
      future: analyzer.analyze(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
          );
        }

        final analysis = snapshot.data!;

        final total = analysis.total;
        final completed = analysis.success + analysis.failed;
        final progress = total == 0 ? 0.0 : completed / total;

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
                    const Icon(Icons.sync, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      "Sync Progress",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _statusBadge(status),
                  ],
                ),

                const SizedBox(height: 16),

                // PROGRESS BAR
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  color: _progressColor(progress),
                ),

                const SizedBox(height: 8),

                Text(
                  "$completed of $total operations processed",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 16),

                // METRICS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric("Pending", analysis.pending, Colors.orange),
                    _metric("Success", analysis.success, Colors.green),
                    _metric("Failed", analysis.failed, Colors.red),
                    _metric("Conflicts", analysis.conflicts, Colors.purple),
                  ],
                ),

                const SizedBox(height: 16),

                _buildStatusMessage(status),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= STATUS BADGE =================

  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "syncing":
        color = Colors.blue;
        break;
      case "idle":
        color = Colors.green;
        break;
      case "offline":
        color = Colors.red;
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

  // ================= PROGRESS COLOR =================

  Color _progressColor(double progress) {
    if (progress >= 0.9) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }

  // ================= STATUS MESSAGE =================

  Widget _buildStatusMessage(String status) {
    String message;
    Color color;

    switch (status) {
      case "syncing":
        message = "Sync in progress... keeping data consistent";
        color = Colors.blue;
        break;
      case "idle":
        message = "All changes are synced";
        color = Colors.green;
        break;
      case "offline":
        message = "No internet connection";
        color = Colors.red;
        break;
      default:
        message = "Unknown sync state";
        color = Colors.grey;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
