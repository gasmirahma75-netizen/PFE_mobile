

// 1. Packages officiels de Flutter et Dart
import 'package:flutter/material.dart';
import 'dart:convert'; // Utile si vous décodez des stats JSON directement ici
import '../constants.dart';
// 2. Vos composants d'interface (Screens)
// REMPLACEZ 'frontend_flutter' par le nom exact de votre projet dans pubspec.yaml
import 'package:frontend_flutter/pages/gerer_contract.dart';
import 'package:frontend_flutter/pages/user_management_page.dart'; 
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // --- VARIABLES DE MONITORING ---
  int totalContracts = 0;
  int totalUsers = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  // --- RÉCUPÉRATION DES STATISTIQUES ---
  Future<void> _fetchStats() async {
    setState(() => isLoading = true);
    try {
      // Utilisation de statsUrl défini dans constants.dart
      final response = await http.get(Uri.parse(ApiConfig.statsUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalContracts = data['total_contracts'] ?? 0;
          totalUsers = data['total_users'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Erreur stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color posteBlue = Color(0xFF001A70);
return Scaffold(
  appBar: AppBar(
    title: const Text("Tableau de Bord", style: TextStyle(color: Colors.white)),
    backgroundColor: posteBlue,
    iconTheme: const IconThemeData(color: Colors.white), // Indispensable pour voir l'icône du Drawer
    actions: [
      IconButton(
        onPressed: _fetchStats, 
        icon: const Icon(Icons.refresh, color: Colors.white)
      )
    ],
  ),
      // --- 1. NAVBAR (DRAWER) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: posteBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, color: posteBlue)),
                  SizedBox(height: 10),
                  Text("Rahma Guesmi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("PFE 2026 - La Poste", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: posteBlue),
              title: const Text("Tableau de bord"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: posteBlue),
              title: const Text("Gérer Utilisateurs"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManagementPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: posteBlue),
              title: const Text("Gérer Contrats"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => GererContractPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Déconnexion"),
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
            ),
          ],
        ),
      ),

      // --- 2. MONITORING (STATS) ---
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Suivi de l'Activité", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: posteBlue)),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildStatCard("Contrats Audités", totalContracts.toString(), Icons.analytics, Colors.blue),
                      _buildStatCard("Agents Actifs", totalUsers.toString(), Icons.group, Colors.orange),
                      _buildStatCard("Conformité", "85%", Icons.verified, Colors.green),
                      _buildStatCard("Alertes", "12", Icons.warning, Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/audit'), // Ou ton Navigator.push vers AuditPage
        label: const Text("Nouvel Audit", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: posteBlue,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}