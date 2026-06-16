import 'package:flutter/material.dart';

import 'package:syncnotes/sync/conflict/conflict_model.dart';
import 'package:syncnotes/sync/conflict/conflict_resolution_strategy.dart';

class ConflictResolutionPage extends StatelessWidget {
  final ConflictModel conflict;

  const ConflictResolutionPage({super.key, required this.conflict});

  @override
  Widget build(BuildContext context) {
    final local = conflict.localData;
    final remote = conflict.remoteData;

    return Scaffold(
      appBar: AppBar(title: const Text("Resolve Conflict"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: Colors.orange,
            ),

            const SizedBox(height: 16),

            const Text(
              "Conflict Detected",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Both the local and server versions were modified.\nChoose how you want to resolve this conflict.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView(
                          children: [
                            const Text(
                              "LOCAL VERSION",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),

                            const Divider(),

                            Text(
                              local["title"]?.toString() ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(local["body"]?.toString() ?? ""),

                            const SizedBox(height: 20),

                            const Text(
                              "Updated At",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            Text(local["updatedAt"]?.toString() ?? ""),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView(
                          children: [
                            const Text(
                              "SERVER VERSION",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),

                            const Divider(),

                            Text(
                              remote["title"]?.toString() ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(remote["body"]?.toString() ?? ""),

                            const SizedBox(height: 20),

                            const Text(
                              "Updated At",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            Text(remote["updatedAt"]?.toString() ?? ""),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.phone_android),
                    label: const Text("Keep Local"),
                    onPressed: () {
                      Navigator.pop(
                        context,
                        ConflictResolutionStrategy.keepLocal,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cloud),
                    label: const Text("Keep Server"),
                    onPressed: () {
                      Navigator.pop(
                        context,
                        ConflictResolutionStrategy.keepServer,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.merge),
                label: const Text("Merge Versions"),
                onPressed: () {
                  Navigator.pop(context, ConflictResolutionStrategy.merge);
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
