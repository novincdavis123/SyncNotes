import 'package:flutter/material.dart';
import 'package:syncnotes/sync_manager/monitoring/sync_metrics_service.dart';

class SyncMetricsCard extends StatelessWidget {
  final SyncMetricsSnapshot metrics;

  const SyncMetricsCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sync Metrics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: "Success",
                    value: metrics.success.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: "Failed",
                    value: metrics.failed.toString(),
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: "Retries",
                    value: metrics.retryCount.toString(),
                    icon: Icons.refresh,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: "Total",
                    value: metrics.total.toString(),
                    icon: Icons.storage,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const Divider(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Success Rate",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  "${metrics.successRate.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
