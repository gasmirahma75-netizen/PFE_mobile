import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CorrectionPage extends StatefulWidget {
  final Map<String, dynamic> data; // Contient les résultats de l'IA + nom_fichier

  const CorrectionPage({super.key, required this.data});

  @override
  State<CorrectionPage> createState() => _CorrectionPageState();
}

class _CorrectionPageState extends State<CorrectionPage> {
  // Contrôleurs pour l'édition des données extraites
  late TextEditingController controllerObjet;
  late TextEditingController controllerDirection;
  late TextEditingController controllerMontant;
  late TextEditingController controllerDateDebut;
  late TextEditingController controllerDateFin;

  bool _isSaving = false;
  final Color posteBlue = const Color(0xFF001A70);

  @override
  void initState() {
    super.initState();
    // Initialisation avec les données reçues de l'IA ou texte vide
    // On s'assure de convertir en String pour éviter les erreurs de type
    controllerObjet = TextEditingController(text: widget.data['objet']?.toString() ?? "");
    controllerDirection = TextEditingController(text: widget.data['direction']?.toString() ?? "");
    controllerMontant = TextEditingController(text: widget.data['montant']?.toString() ?? "");
    controllerDateDebut = TextEditingController(text: widget.data['date_debut']?.toString() ?? "");
    controllerDateFin = TextEditingController(text: widget.data['date_fin']?.toString() ?? "");
  }

  // --- LOGIQUE DE SAUVEGARDE FINALE ---
  Future<void> _confirmerEtEnregistrer() async {
    // Validation simple : l'objet et le montant ne doivent pas être vides
    if (controllerObjet.text.isEmpty || controllerMontant.text.isEmpty) {
      _showError("Veuillez remplir au moins l'objet et le montant.");
      return;
    }

    setState(() => _isSaving = true);

    // Préparation de l'objet JSON final pour la route /api/contracts
    Map<String, dynamic> finalData = {
      "objet": controllerObjet.text.trim(),
      "direction": controllerDirection.text.trim(),
      "montant": controllerMontant.text.trim(),
      "date_debut": controllerDateDebut.text.trim(),
      "date_fin": controllerDateFin.text.trim(),
      "status": "Validé", 
      // CRUCIAL : On récupère le nom exact généré par Multer côté serveur[cite: 1, 2]
      "nom_fichier": widget.data['nom_fichier'] ?? "contrat_inconnu.pdf", 
    };

    try {
      // Appel de votre service API pour l'insertion SQL[cite: 2]
      bool success = await ApiService.saveContract(finalData);

      if (success && mounted) {
        _showSuccessSnackBar("✅ Contrat enregistré avec succès !");
        
        // Retour à l'accueil (Dashboard) après succès
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        });
      } else {
        _showError("Erreur : Le serveur a refusé l'enregistrement.");
      }
    } catch (e) {
      _showError("Erreur réseau : Impossible de joindre le serveur.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- WIDGETS D'INTERFACE ---

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification IA", style: TextStyle(color: Colors.white)),
        backgroundColor: posteBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Veuillez confirmer les informations extraites :",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Fichier associé : ${widget.data['nom_fichier'] ?? 'Inconnu'}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            
            _buildInputField("Objet du Contrat", controllerObjet, Icons.description, TextInputType.text),
            _buildInputField("Prestataire / Direction", controllerDirection, Icons.business, TextInputType.text),
            _buildInputField("Montant Total (TND)", controllerMontant, Icons.attach_money, TextInputType.number),
            _buildInputField("Date de Début (JJ/MM/AAAA)", controllerDateDebut, Icons.calendar_today, TextInputType.datetime),
            _buildInputField("Date de Fin (JJ/MM/AAAA)", controllerDateFin, Icons.calendar_month, TextInputType.datetime),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _confirmerEtEnregistrer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "VALIDER ET ENREGISTRER",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: posteBlue),
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