import 'package:flutter/material.dart';
class ConfidenceIndicator extends StatelessWidget {
  final double value; // 0.0 à 100.0
  const ConfidenceIndicator({required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[300],
          color: value > 80 ? const Color(0xFF001A70) : Colors.orange,
        ),
        Text("Confiance: ${value.toInt()}%", style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}