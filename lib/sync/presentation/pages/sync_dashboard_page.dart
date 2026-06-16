import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:syncnotes/sync/monitoring/sync_metrics_service.dart';
import 'package:syncnotes/sync/monitoring/sync_status_service.dart';
import 'package:syncnotes/sync/history/sync_history_model.dart';
import 'package:syncnotes/sync/history/sync_history_repository.dart';
import 'package:syncnotes/sync/queue/sync_queue_analyzer.dart';
import 'package:syncnotes/sync/queue/sync_queue_statistics.dart';
import 'package:syncnotes/core/enums/sync_status.dart';

class SyncDashboardPage extends StatefulWidget {
  const SyncDashboardPage({super.key});

  @override
  State<SyncDashboardPage> createState() => _SyncDashboardPageState();
}

class _SyncDashboardPageState extends State<SyncDashboardPage> {
  late SyncMetricsService metrics;
  late SyncStatusService statusService;
  late SyncHistoryRepository historyRepo;
  late SyncQueueAnalyzer queueAnalyzer;

  @override
  void initState() {
    super.initState();

    metrics = context.read<SyncMetricsService>();
    statusService = context.read<SyncStatusService>();
    historyRepo = context.read<SyncHistoryRepository>();
    queueAnalyzer = context.read<SyncQueueAnalyzer>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sync Dashboard"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildMetricsGrid(),
            const SizedBox(height: 16),
            _buildQueueAnalysis(),
            const SizedBox(height: 16),
            _buildHistorySummary(),
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // STATUS CARD
  // =============================================================
  Widget _buildStatusCard() {
    final status = statusService.currentStatus.toString().split('.').last;

    return Card(
      child: ListTile(
        leading: Icon(
          status == "syncing"
              ? Icons.sync
              : status == "offline"
              ? Icons.cloud_off
              : Icons.cloud_done,
          color: Colors.blue,
        ),
        title: const Text("Current Sync Status"),
        subtitle: Text(status.toUpperCase()),
      ),
    );
  }

  // =============================================================
  // METRICS GRID
  // =============================================================
  Widget _buildMetricsGrid() {
    final stats = metrics.getStats();

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _metricCard("Success", stats.success.toString(), Colors.green),
        _metricCard("Failed", stats.failed.toString(), Colors.red),
        _metricCard("Retries", stats.retryCount.toString(), Colors.orange),
        _metricCard("Total", stats.total.toString(), Colors.blue),
      ],
    );
  }

  Widget _metricCard(String title, String value, Color color) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // QUEUE ANALYSIS
  // =============================================================
  Widget _buildQueueAnalysis() {
    return FutureBuilder<SyncQueueStatistics>(
      future: queueAnalyzer.analyze(),
      builder: (context, snapshot) {
        final analysis = snapshot.data ?? SyncQueueStatistics.initial();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Queue Analysis",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text("Pending: ${analysis.pending}"),
                Text("In Progress: ${analysis.inProgress}"),
                Text("Conflicts: ${analysis.conflicts}"),
                Text("Failed: ${analysis.failed}"),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================================================
  // HISTORY SUMMARY (FIXED - NO BROKEN METHOD CALLS)
  // =============================================================
  Widget _buildHistorySummary() {
    return FutureBuilder<List<SyncHistoryModel>>(
      future: historyRepo.getAllHistory(),
      builder: (context, snapshot) {
        final history = snapshot.data ?? [];

        final total = history.length;
        final success = history
            .where((e) => e.status == SyncStatus.synced)
            .length;
        final failed = history
            .where((e) => e.status == SyncStatus.failed)
            .length;
        final conflicts = history.where((e) => e.hadConflict).length;
        final retried = history.where((e) => e.retryCount > 0).length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sync History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text("Total Syncs: $total"),
                Text("Successful: $success"),
                Text("Failed: $failed"),
                Text("Conflicts: $conflicts"),
                Text("Retried: $retried"),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================================================
  // ACTIONS
  // =============================================================
  Widget _buildActions() {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Force Sync"),
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text("Clear Metrics"),
          onPressed: () {
            metrics.reset();
            setState(() {});
          },
        ),
      ],
    );
  }
}
