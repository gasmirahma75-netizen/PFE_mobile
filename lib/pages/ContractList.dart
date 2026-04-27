import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/Navbar.dart';

class ContractListPage extends StatefulWidget {
  const ContractListPage({super.key});

  @override
  State<ContractListPage> createState() => _ContractListPageState();
}

class _ContractListPageState extends State<ContractListPage> {
  // ✅ Assure-toi que cette IP est bien celle de ton PC sur le réseau WiFi
  final String _apiUrl = "http://192.168.1.217:5000/api/contracts"; 

  Future<List<dynamic>> _fetchContracts() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint("Erreur Fetch: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const Navbar(), // ✅ Ta barre latérale
      appBar: AppBar(
        title: const Text("Historique des Contrats", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF001A70))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF001A70)),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchContracts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF001A70)));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  const Text("Aucun contrat trouvé dans la base.", 
                    style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // Inverser pour voir les plus récents en premier
          final contracts = snapshot.data!.reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final contract = contracts[index];
              return _buildContractTile(contract);
            },
          );
        },
      ),
    );
  }

  Widget _buildContractTile(Map contract) {
    // ✅ Protection anti-null pour le statut
    String status = contract['status']?.toString() ?? 'En attente';
    Color statusColor = status == 'Validé' ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.description, color: statusColor),
        ),
        title: Text(
          // ✅ Priorité à l'Objet du contrat (BI) sinon nom du fichier
          contract['objet']?.toString() ?? contract['nom_fichier']?.toString() ?? "Sans titre",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Direction: ${contract['direction'] ?? 'N/A'}", 
              style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(status, 
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          // ✅ Décodage sécurisé de ai_data
          dynamic decodedData;
          try {
            decodedData = contract['ai_data'] != null 
                ? jsonDecode(contract['ai_data']) 
                : {'message': 'Pas de données IA'};
          } catch (e) {
            decodedData = {'message': 'Erreur de lecture'};
          }

          Navigator.pushNamed(context, '/details', arguments: {
            'id': contract['id'],
            'data': decodedData
          });
        },
      ),
    );
  }
}