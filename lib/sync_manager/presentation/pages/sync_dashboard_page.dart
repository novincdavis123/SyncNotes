import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:syncnotes/sync_manager/history/sync_history_model.dart';
import 'package:syncnotes/sync_manager/history/sync_history_repository.dart';

import 'package:syncnotes/sync_manager/monitoring/sync_metrics_service.dart';
import 'package:syncnotes/sync_manager/monitoring/sync_status_service.dart';
import 'package:syncnotes/sync_manager/presentation/widgets/sync_history_tile.dart';
import 'package:syncnotes/sync_manager/presentation/widgets/sync_metrics_card.dart';
import 'package:syncnotes/sync_manager/presentation/widgets/sync_status_chip.dart';

import 'package:syncnotes/sync_manager/queue/sync_queue_analyzer.dart';
import 'package:syncnotes/sync_manager/queue/sync_queue_statistics.dart';

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

  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (initialized) return;

    metrics = context.read<SyncMetricsService>();
    statusService = context.read<SyncStatusService>();
    historyRepo = context.read<SyncHistoryRepository>();
    queueAnalyzer = context.read<SyncQueueAnalyzer>();

    initialized = true;
  }

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final stats = metrics.getStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sync Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: const Text("Current Status"),
                  trailing: SyncStatusChip(status: statusService.currentStatus),
                ),
              ),

              const SizedBox(height: 16),

              SyncMetricsCard(metrics: stats),

              const SizedBox(height: 16),

              FutureBuilder<SyncQueueStatistics>(
                future: queueAnalyzer.analyze(),
                builder: (_, snapshot) {
                  final analysis =
                      snapshot.data ?? SyncQueueStatistics.initial();

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Queue Analysis",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Pending : ${analysis.pending}"),
                          Text("In Progress : ${analysis.inProgress}"),
                          Text("Failed : ${analysis.failed}"),
                          Text("Conflicts : ${analysis.conflicts}"),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              FutureBuilder<Map<String, int>>(
                future: historyRepo.getHistorySummary(),
                builder: (_, snapshot) {
                  final summary = snapshot.data ?? {};

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "History Summary",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Total : ${summary["total"] ?? 0}"),
                          Text("Success : ${summary["success"] ?? 0}"),
                          Text("Failed : ${summary["failed"] ?? 0}"),
                          Text("Conflict : ${summary["conflict"] ?? 0}"),
                          Text("Retried : ${summary["retried"] ?? 0}"),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              FutureBuilder<List<SyncHistoryModel>>(
                future: historyRepo.getRecentHistory(limit: 5),
                builder: (_, snapshot) {
                  final history = snapshot.data ?? [];

                  if (history.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("No Sync History"),
                      ),
                    );
                  }

                  return Card(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            "Recent Activity",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ...history.map((e) => SyncHistoryTile(history: e)),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: refresh,
                icon: const Icon(Icons.sync),
                label: const Text("Refresh Dashboard"),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: () {
                  metrics.reset();
                  setState(() {});
                },
                icon: const Icon(Icons.delete),
                label: const Text("Clear Metrics"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
