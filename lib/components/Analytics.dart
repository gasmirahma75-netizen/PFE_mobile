import 'package:flutter/material.dart';
import '../components/Navbar.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     drawer: const Navbar(),
      appBar: AppBar(title: const Text("Statistiques Avancées")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Volume d'audits par mois", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            // Simulation d'un graphique à barres
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar(40, "Jan"), _bar(80, "Fév"), _bar(60, "Mar"), _bar(100, "Avr"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(double height, String label) {
    return Column(
      children: [
        Container(width: 40, height: height, color: const Color(0xFF6366F1)),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}