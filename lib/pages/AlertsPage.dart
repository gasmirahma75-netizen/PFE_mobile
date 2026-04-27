import 'package:flutter/material.dart';
import '../services/alert_service.dart';
import '../components/AlertCard.dart';

class AlertsListPage extends StatelessWidget {
  const AlertsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color posteBlue = Color(0xFF001A70);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
        title: const Text(
          "Toutes les Alertes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: posteBlue,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: AlertService.getAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: posteBlue));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement des alertes"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[400]),
                  const Text("Aucune alerte pour le moment"),
                ],
              ),
            );
          }

          final alerts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final item = alerts[index];
              
              // --- CORRECTION DES CLÉS JSON ---
              // On utilise .toString() et ?? pour éviter l'erreur "Null is not subtype of String"
              return AlertCard(
                message: item['message']?.toString() ?? "Alerte système",
                // On met 'INFO' par défaut car ta table n'a pas de colonne type_alerte
                typeAlerte: 'INFO', 
                statut: 'non_lu',
                // Ta colonne dans phpMyAdmin s'appelle 'date'
                dateAlerte: item['date'] != null 
                    ? DateTime.parse(item['date'].toString()) 
                    : DateTime.now(),
              );
            },
          );
        },
      ),
    );
  }
}