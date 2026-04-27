import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/api_service.dart'; // Obligatoire pour saveContract
class CorrectionPage extends StatefulWidget {
  final Map<String, dynamic> data; // Données extraites par l'IA

  const CorrectionPage({super.key, required this.data});

  @override
  State<CorrectionPage> createState() => _CorrectionPageState();
}

class _CorrectionPageState extends State<CorrectionPage> {
  // Contrôleurs pour l'édition des données
  late TextEditingController controllerObjet;
  late TextEditingController controllerDirection;
  late TextEditingController controllerMontant;
  late TextEditingController controllerDateDebut;
  late TextEditingController controllerDateFin;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialisation avec les données de l'IA ou texte vide
    controllerObjet = TextEditingController(text: widget.data['objet']?.toString() ?? "");
    controllerDirection = TextEditingController(text: widget.data['direction']?.toString() ?? "");
    controllerMontant = TextEditingController(text: widget.data['montant']?.toString() ?? "");
    controllerDateDebut = TextEditingController(text: widget.data['date_debut']?.toString() ?? "");
    controllerDateFin = TextEditingController(text: widget.data['date_fin']?.toString() ?? "");
  }

  // --- LOGIQUE DE SAUVEGARDE ---
  Future<void> _confirmerEtEnregistrer() async {
    setState(() => _isSaving = true);

    // Préparation des données finales corrigées par l'utilisateur
    Map<String, dynamic> finalData = {
      "objet": controllerObjet.text,
      "direction": controllerDirection.text,
      "montant": controllerMontant.text,
      "date_debut": controllerDateDebut.text,
      "date_fin": controllerDateFin.text,
    };

    try {
      // Appel de la méthode qui renvoie un bool (Correction de l'erreur statusCode)
      bool success = await ApiService.saveContract(finalData);

      if (success && mounted) {
        // ✅ SUCCÈS
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Contrat enregistré avec succès dans la base !"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        // Retour au Dashboard
        Navigator.of(context).pop(); 
      } else {
        // ❌ ÉCHEC SERVEUR
        _showError("Erreur lors de la sauvegarde (Vérifiez le serveur Node.js)");
      }
    } catch (e) {
      // ❌ ERREUR RÉSEAU
      _showError("Erreur de connexion : Impossible de joindre le serveur");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color posteBlue = Color(0xFF001A70);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Validation des données IA", style: TextStyle(color: Colors.white)),
        backgroundColor: posteBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vérifiez et corrigez les informations extraites :",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            _buildInputField("Objet du Contrat", controllerObjet, Icons.description),
            _buildInputField("Direction / Prestataire", controllerDirection, Icons.business),
            _buildInputField("Montant", controllerMontant, Icons.attach_money),
            _buildInputField("Date de Début", controllerDateDebut, Icons.calendar_today),
            _buildInputField("Date de Fin", controllerDateFin, Icons.calendar_month),

            const SizedBox(height: 30),

            // BOUTON DE SAUVEGARDE
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _confirmerEtEnregistrer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "CONFIRMER ET ENREGISTRER",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour générer les champs de saisie proprement
  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF001A70)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controllerObjet.dispose();
    controllerDirection.dispose();
    controllerMontant.dispose();
    controllerDateDebut.dispose();
    controllerDateFin.dispose();
    super.dispose();
  }
}