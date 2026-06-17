import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOnline;

  const OfflineBanner({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    if (isOnline) return const SizedBox();

    return Container(
      width: double.infinity,
      color: Colors.red,
      padding: const EdgeInsets.all(8),
      child: const Text(
        "You are offline — changes will sync automatically",
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
