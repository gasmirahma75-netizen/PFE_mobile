import 'package:flutter/material.dart';
import '../services/alert_service.dart';
import '../components/AlertCard.dart'; // ✅ Import corrigé (dossier components)

class AlertsListPage extends StatefulWidget {
  const AlertsListPage({super.key});

  @override
  State<AlertsListPage> createState() => _AlertsListPageState();
}

class _AlertsListPageState extends State<AlertsListPage> {
  // Couleur officielle de La Poste Tunisienne
  final Color posteBlue = const Color(0xFF001A70);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        // ✅ Flèche de retour vers le Dashboard
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
        title: const Text(
          "Suivi des Alertes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: posteBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: AlertService.getAlerts(), // Appel à ton backend Node.js
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: posteBlue),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Erreur de connexion au serveur"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    "Aucun risque détecté sur les contrats",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final alerts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final item = alerts[index];
              
              return AlertCard(
                // ✅ Le message contient le nom du contrat grâce au CONCAT du backend
                message: item['message'] ?? "Alerte de maintenance",
                typeAlerte: item['type_alerte'] ?? 'INFO',
                statut: item['statut'] ?? 'non_lu',
                dateAlerte: item['date_alerte'] != null 
                    ? DateTime.parse(item['date_alerte']) 
                    : DateTime.now(),
                
                // ✅ Action lors du clic sur l'alerte
                onTap: () async {
                  if (item['statut'] == 'non_lu') {
                    // 1. Marquer comme lu dans MySQL
                    await AlertService.markAsRead(item['id']);
                    
                    // 2. Message de confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Alerte marquée comme traitée"),
                        duration: Duration(seconds: 1),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // 3. Rafraîchir l'interface
                    setState(() {}); 
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}