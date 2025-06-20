import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onAnalyze;
  final VoidCallback onCrop;

  const ActionButtons({
    super.key,
    required this.onAnalyze,
    required this.onCrop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(onPressed: onAnalyze, child: const Text('Analyze')),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onCrop, child: const Text('Crop')),
      ],
    );
  }
}
