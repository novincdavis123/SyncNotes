import 'package:flutter/material.dart';

class EmptyNotesWidget extends StatelessWidget {
  const EmptyNotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 70),
          SizedBox(height: 16),
          Text(
            "No Notes Yet",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text("Tap + to create your first note."),
        ],
      ),
    );
  }
}
