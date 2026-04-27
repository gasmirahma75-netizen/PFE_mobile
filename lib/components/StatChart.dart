import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatChart extends StatelessWidget {
  const StatChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Couleurs officielles de La Poste Tunisienne
    const Color posteBlue = Color(0xFF001A70);
    const Color posteYellow = Color(0xFFFFC20E);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 40, 
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold);
                  switch (value.toInt()) {
                    case 0: return const Text('Fin', style: style);
                    case 1: return const Text('RH', style: style);
                    case 2: return const Text('IT', style: style);
                    case 3: return const Text('Log', style: style);
                    case 4: return const Text('Jur', style: style);
                    default: return const Text('');
                  }
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroup(0, 12, posteBlue),   // Finance
            _makeGroup(1, 19, posteYellow), // RH
            _makeGroup(2, 35, posteBlue),   // IT (Le plus haut sur ton web)
            _makeGroup(3, 15, posteYellow), // Logistique
            _makeGroup(4, 8, posteBlue),    // Juridique
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }
}