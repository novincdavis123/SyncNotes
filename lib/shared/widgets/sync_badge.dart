import 'package:flutter/material.dart';

class SyncBadge extends StatelessWidget {
  final String status;

  const SyncBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case "synced":
        color = Colors.green;
        break;
      case "pending":
        color = Colors.orange;
        break;
      case "conflict":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
