import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final String message;
  final String typeAlerte;
  final String statut;
  final DateTime dateAlerte;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.message,
    required this.typeAlerte,
    required this.statut,
    required this.dateAlerte,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Logique de détermination des couleurs et icônes
    Color mainColor;
    IconData alertIcon;
    Color textColor;

    // Mapping des types envoyés par le Backend (index.js)
    switch (typeAlerte) {
      case 'DANGER':
      case 'CRITIQUE':
        mainColor = Colors.red;
        textColor = Colors.red.shade900;
        alertIcon = Icons.report_gmailerrorred_rounded;
        break;
      case 'WARNING':
        mainColor = Colors.orange;
        textColor = Colors.orange.shade900;
        alertIcon = Icons.priority_high_rounded;
        break;
      case 'SUCCESS':
        mainColor = Colors.green;
        textColor = Colors.green.shade900;
        alertIcon = Icons.check_circle_outline_rounded;
        break;
      default:
        mainColor = Colors.blue;
        textColor = Colors.blue.shade900;
        alertIcon = Icons.info_outline_rounded;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // Bordure colorée subtile
        side: BorderSide(color: mainColor.withOpacity(0.3), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(alertIcon, color: mainColor, size: 26),
          ),
          title: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text(
                  "Le ${dateAlerte.day}/${dateAlerte.month}/${dateAlerte.year}",
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(width: 15),
                // Petit badge de statut
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    statut.toUpperCase(),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ),
      ),
    );
  }
}