import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../services/api_service.dart';

class ReviewContractPage extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final String rawText; // Le texte brut extrait par l'OCR pour l'apprentissage

  const ReviewContractPage({
    super.key, 
    required this.initialData, 
    required this.rawText
  });

  @override
  State<ReviewContractPage> createState() => _ReviewContractPageState();
}

class _ReviewContractPageState extends State<ReviewContractPage> {
  bool isEditing = false;
  bool isSaving = false;

  // Contrôleurs pour les champs de données
  late TextEditingController _numeroController;
  late TextEditingController _montantController;
  late TextEditingController _dateDebutController;
  late TextEditingController _dateFinController;
  
  String selectedDirection = "Informatique";
  final List<String> directions = ["Finance", "RH", "Informatique", "Logistique", "Juridique"];

  @override
  void initState() {
    super.initState();
    // Initialisation avec les données reçues de l'IA (FastAPI)
    _numeroController = TextEditingController(text: widget.initialData['numero'] ?? "");
    _montantController = TextEditingController(text: widget.initialData['montant']?.toString() ?? "");
    _dateDebutController = TextEditingController(text: widget.initialData['date_debut'] ?? "");
    _dateFinController = TextEditingController(text: widget.initialData['date_fin'] ?? "");
    
    if (directions.contains(widget.initialData['direction'])) {
      selectedDirection = widget.initialData['direction'];
    }
  }

  // --- FONCTION CLÉ : VALIDATION ET APPRENTISSAGE ---
  Future<void> _handleValidation() async {
    setState(() => isSaving = true);

    final Map<String, dynamic> finalData = {
      "numero": _numeroController.text,
      "montant": _montantController.text,
      "date_debut": _dateDebutController.text,
      "date_fin": _dateFinController.text,
      "direction": selectedDirection,
    };

    try {
      // 1. Sauvegarde dans la table 'contrats' (MySQL classique)
      await ApiService.post(ApiConfig.contractsUrl, finalData);

      // 2. Envoi du feedback pour l'apprentissage progressif (Table training_data)
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/contracts/feedback"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text_content": widget.rawText,
          "corrected_entities": finalData,
        }),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Contrat validé et IA mise à jour !"), backgroundColor: Colors.green),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur : $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color posteBlue = Color(0xFF001A70);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification IA", style: TextStyle(color: Colors.white)),
        backgroundColor: posteBlue,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check_circle : Icons.edit, color: Colors.white),
            onPressed: () => setState(() => isEditing = !isEditing),
          )
        ],
      ),
      body: isSaving 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  "Vérifiez les informations extraites par l'IA",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 20),
                _buildField("Numéro de Contrat", _numeroController, isEditing),
                _buildField("Montant (DT)", _montantController, isEditing),
                _buildField("Date Début", _dateDebutController, isEditing),
                _buildField("Date Fin", _dateFinController, isEditing),
                _buildDropdown("Direction Responsable", isEditing),
                const SizedBox(height: 30),
                
                if (!isEditing)
                  ElevatedButton(
                    onPressed: _handleValidation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    child: const Text("VALIDER ET ENREGISTRER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          filled: !enabled,
          fillColor: enabled ? Colors.transparent : Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedDirection,
        onChanged: enabled ? (val) => setState(() => selectedDirection = val!) : null,
        items: directions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}