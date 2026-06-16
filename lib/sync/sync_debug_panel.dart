import 'dart:async';

import 'package:flutter/material.dart';

import 'package:syncnotes/di/injection.dart';

import 'package:syncnotes/sync/monitoring/sync_metrics_service.dart';
import 'package:syncnotes/sync/monitoring/sync_queue_monitor.dart';
import 'package:syncnotes/sync/monitoring/sync_status_service.dart';
import 'package:syncnotes/sync/sync_event_bus.dart';
import 'package:syncnotes/sync/sync_event.dart';

class DebugPanel extends StatefulWidget {
  const DebugPanel({super.key});

  @override
  State<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends State<DebugPanel> {
  final SyncEventBus _eventBus = sl<SyncEventBus>();
  final SyncMetricsService _metrics = sl<SyncMetricsService>();
  final SyncQueueMonitor _queue = sl<SyncQueueMonitor>();
  final SyncStatusService _status = sl<SyncStatusService>();

  final List<SyncEvent> _events = [];
  StreamSubscription<SyncEvent>? _sub;

  @override
  void initState() {
    super.initState();

    _sub = _eventBus.stream.listen((event) {
      if (!mounted) return;

      setState(() {
        _events.insert(0, event);

        if (_events.length > 100) {
          _events.removeLast();
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _refreshStats() async {
    if (!mounted) return;
    setState(() {});
  }

  Color _colorForEvent(SyncEventType type) {
    switch (type) {
      case SyncEventType.started:
        return Colors.blue;

      case SyncEventType.operationStarted:
        return Colors.orange;

      case SyncEventType.operationSuccess:
        return Colors.green;

      case SyncEventType.operationFailed:
        return Colors.red;

      case SyncEventType.retryScheduled:
        return Colors.amber;

      case SyncEventType.completed:
        return Colors.green;

      case SyncEventType.error:
        return Colors.red;

      case SyncEventType.permanentFailure:
        return Colors.redAccent;

      case SyncEventType.empty:
        return Colors.grey;

      case SyncEventType.conflictDetected:
        return Colors.purple;
    }
  }

  IconData _iconForEvent(SyncEventType type) {
    switch (type) {
      case SyncEventType.started:
        return Icons.play_arrow;

      case SyncEventType.operationStarted:
        return Icons.sync;

      case SyncEventType.operationSuccess:
        return Icons.check_circle;

      case SyncEventType.operationFailed:
        return Icons.error;

      case SyncEventType.retryScheduled:
        return Icons.schedule;

      case SyncEventType.completed:
        return Icons.done_all;

      case SyncEventType.error:
        return Icons.warning;

      case SyncEventType.permanentFailure:
        return Icons.block;

      case SyncEventType.empty:
        return Icons.inbox;

      case SyncEventType.conflictDetected:
        return Icons.warning_amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Debug Panel'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshStats),
        ],
      ),
      body: Column(
        children: [
          // ======================================================
          // TOP STATS
          // ======================================================
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status: ${_status.currentStatus.name}"),
                const SizedBox(height: 8),

                FutureBuilder(
                  future: _queue.getStatus(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Queue → Loading...");
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Text("Queue → No data");
                    }

                    final queue = snapshot.data!;

                    return Text(
                      "Queue → Pending: ${queue.pending}, "
                      "InProgress: ${queue.inProgress}, "
                      "Failed: ${queue.failed}",
                    );
                  },
                ),

                const SizedBox(height: 8),

                Text(
                  "Success: ${_metrics.totalSynced}, "
                  "Failed: ${_metrics.totalFailed}, "
                  "Retry: ${_metrics.totalRetried}",
                ),

                Text(
                  "Success Rate: ${_metrics.successRate.toStringAsFixed(1)}%",
                ),
              ],
            ),
          ),

          const Divider(),

          // ======================================================
          // EVENT STREAM
          // ======================================================
          Expanded(
            child: _events.isEmpty
                ? const Center(child: Text("No events yet"))
                : ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];

                      return ListTile(
                        leading: Icon(
                          _iconForEvent(event.type),
                          color: _colorForEvent(event.type),
                        ),
                        title: Text(event.message),
                        subtitle: Text(
                          "${event.type.name} • ${event.timestamp.toIso8601String()}",
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: event.operationId != null
                            ? Text(
                                event.operationId!,
                                style: const TextStyle(fontSize: 10),
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
