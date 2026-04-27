import 'package:flutter/material.dart';

class RiskBadge extends StatelessWidget {
  final String level; // 'low', 'medium', ou 'high'

  const RiskBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    // Définition des couleurs et du texte selon le niveau de risque
    Color bgColor;
    Color textColor;
    String label;

    switch (level.toLowerCase()) {
      case 'high':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        label = "Risque Élevé";
        break;
      case 'medium':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade800;
        label = "Risque Moyen";
        break;
      case 'low':
      default:
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        label = "Risque Faible";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} // <--- TRÈS IMPORTANT : Ne pas oublier cette accolade de fin !