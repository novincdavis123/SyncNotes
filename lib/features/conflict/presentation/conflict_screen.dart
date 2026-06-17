import 'package:flutter/material.dart';

import 'package:syncnotes/features/conflict/data/models/conflict_model.dart';
import 'package:syncnotes/features/conflict/data/conflict_resolution_service.dart';
import 'package:syncnotes/features/conflict/domain/enums/conflict_resolution_strategy.dart';
import 'package:syncnotes/di/injection.dart';

class ConflictScreen extends StatefulWidget {
  final ConflictModel conflict;

  const ConflictScreen({super.key, required this.conflict});

  @override
  State<ConflictScreen> createState() => _ConflictScreenState();
}

class _ConflictScreenState extends State<ConflictScreen> {
  bool _isProcessing = false;

  Future<void> _resolve(ConflictResolutionStrategy strategy) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final resolver = sl<ConflictResolutionService>();

    await resolver.resolveConflict(
      conflict: widget.conflict,
      strategy: strategy,
    );

    if (!mounted) return;

    Navigator.pop(context, strategy); // 🔥 IMPORTANT: return result
  }

  @override
  Widget build(BuildContext context) {
    final conflict = widget.conflict;

    return Scaffold(
      appBar: AppBar(title: const Text("Conflict Detected")),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("LOCAL"),
                      _card(
                        title: conflict.localNote.title,
                        body: conflict.localNote.body,
                        color: Colors.green,
                      ),

                      const SizedBox(height: 16),

                      _sectionTitle("SERVER"),
                      _card(
                        title: conflict.serverNote.title,
                        body: conflict.serverNote.body,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // ACTIONS
              // =========================
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () =>
                                _resolve(ConflictResolutionStrategy.keepLocal),
                      child: const Text("Keep Local"),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () =>
                                _resolve(ConflictResolutionStrategy.keepServer),
                      child: const Text("Keep Server"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _resolve(ConflictResolutionStrategy.merge),
                  child: const Text("Merge"),
                ),
              ),

              if (_isProcessing)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _card({
    required String title,
    required String body,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Text(body),
        ],
      ),
    );
  }
}
