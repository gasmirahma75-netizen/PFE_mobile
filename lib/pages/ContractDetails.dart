import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../components/RiskBadge.dart';

class ContractDetailsPage extends StatefulWidget {
  const ContractDetailsPage({super.key});

  @override
  State<ContractDetailsPage> createState() => _ContractDetailsPageState();
}

class _ContractDetailsPageState extends State<ContractDetailsPage> {
  final Color posteBlue = const Color(0xFF001A70);

  @override
  Widget build(BuildContext context) {
    // Récupération sécurisée de l'ID (gestion String ou Int)
    final dynamic rawArg = ModalRoute.of(context)!.settings.arguments;
    final int contractId = (rawArg is String) ? int.parse(rawArg) : rawArg as int;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Détails de l'Audit IA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: posteBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getContractById(contractId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("❌ Erreur : Contrat introuvable dans la base."));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(data),
                const SizedBox(height: 25),
                _buildExtractionSection("DONNÉES EXTRAITES (LayoutLM v3)", [
                  _buildDataRow("Direction", data['direction'] ?? "Non spécifiée"),
                  _buildDataRow("Prestataire", data['prestataire'] ?? "Inconnu"),
                  _buildDataRow("Objet", data['objet'] ?? "Contrat de maintenance"),
                  _buildDataRow("Montant Total", "${data['montant'] ?? '---'} DT"),
                  _buildDataRow("Période", "${data['date_debut'] ?? '??'} au ${data['date_fin'] ?? '??'}"),
                ]),
                const SizedBox(height: 25),
                _buildAnalysisSection(data),
                const SizedBox(height: 30),
                
                // BOUTON ACTION FINALE
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ouverture du PDF en cours...")),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    label: const Text("VISUALISER LE CONTRAT ORIGINAL"),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: posteBlue),
                      foregroundColor: posteBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo(Map<String, dynamic> data) {
    // On calcule le niveau de risque dynamiquement
    int score = data['risk_score'] ?? 0;
    String level = score >= 70 ? 'high' : (score >= 30 ? 'medium' : 'low');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFF0F2F5),
            radius: 25,
            child: Icon(Icons.description, color: Color(0xFF001A70)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['nom_fichier'] ?? "Document", 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
                Text("ID: #${data['id']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          RiskBadge(level: level),
        ],
      ),
    );
  }

  Widget _buildExtractionSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 12)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ALERTES & CLAUSES CRITIQUES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 12)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.gavel, size: 18, color: Colors.amber),
                  SizedBox(width: 8),
                  Text("Rapport d'Audit Automatique", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(),
              Text(
                data['alerts'] ?? "Aucune anomalie contractuelle détectée par l'IA.",
                style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}