import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/alert_service.dart'; 
import 'Navbar.dart';
import 'AlertCard.dart';
import 'AIMonitoring.dart';
import '../pages/UploadContract.dart'; // ✅ Import correct

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color posteBlue = const Color(0xFF001A70);
  Key _refreshKey = UniqueKey();

  Future<void> _handleRefresh() async {
    setState(() {
      _refreshKey = UniqueKey();
    });
    await Future.wait([
      ApiService.getAllContracts(),
      AlertService.getAlerts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Supervision DAS ERP", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: posteBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      
      drawer: const Navbar(), 

      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: posteBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            key: _refreshKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(), // Appelle le header bleu avec le cercle
              const SizedBox(height: 20),
              _buildSectionTitle("PERFORMANCE SYSTÈME IA"),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AIMonitoring(),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle("ALERTES DE SUPERVISION CRITIQUES"),
              _buildAlertsSection(),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: posteBlue,
        onPressed: () async {
          // ✅ Correction du nom de la classe : UploadContract
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const UploadContract())
          );
          _handleRefresh();
        },
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text("Nouvel Audit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: posteBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30), 
          bottomRight: Radius.circular(30)
        ),
      ),
      child: Row( // Ajout d'un Row pour mettre le texte ET le cercle
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tableau de Bord BI", style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 8),
              Text("16 Contrats", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),
          // ✅ Le cercle vert de ta photo
          SizedBox(
            height: 60, width: 60,
            child: CircularProgressIndicator(
              value: 0.85, 
              strokeWidth: 6, 
              color: Colors.greenAccent, 
              backgroundColor: Colors.white.withOpacity(0.1)
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }

  Widget _buildAlertsSection() {
    return FutureBuilder<List<dynamic>>(
      future: AlertService.getAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Aucun risque détecté", style: TextStyle(color: Colors.grey)),
          );
        }
        return Column(
          children: snapshot.data!.take(3).map((item) => AlertCard(
            message: item['message']?.toString() ?? "Alerte Risque",
            typeAlerte: item['type_alerte']?.toString() ?? "INFO",
            dateAlerte: DateTime.now(),
            statut: 'non_lu',
          )).toList(),
        );
      },
    );
  }
}