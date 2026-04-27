import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'correction_page.dart';

class UploadContract extends StatefulWidget {
  const UploadContract({super.key});

  @override
  State<UploadContract> createState() => _UploadContractState();
}

class _UploadContractState extends State<UploadContract> {
  final Color posteBlue = const Color(0xFF001A70);
  File? _selectedFile;
  bool _isUploading = false;

  // --- 1. SÉLECTION DU FICHIER ---
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
        print("✅ Fichier sélectionné : ${_selectedFile!.path}");
      }
    } catch (e) {
      print("❌ Erreur sélection : $e");
    }
  }

  // --- 2. ENVOI ET EXTRACTION ---
  Future<void> _startIAAudit() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);
    print("📡 Lancement de l'analyse IA...");

    try {
      // ✅ CORRECTION ICI : On passe _selectedFile! directement
      // On ne met plus de crochets [] car ApiService attend un File, pas une List<File>
      final dataIA = await ApiService.uploadContract(_selectedFile!);

      if (dataIA != null) {
        if (!mounted) return;
        
        print("✨ Données extraites avec succès, navigation...");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CorrectionPage(data: dataIA),
          ),
        );
      } else {
        _showSnackBar("L'IA n'a pas pu extraire de données.", Colors.orange);
      }
    } catch (e) {
      print("❌ Erreur fatale : $e");
      _showSnackBar("Erreur de connexion au serveur.", Colors.red);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Numérisation IA", style: TextStyle(color: Colors.white)),
        backgroundColor: posteBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Analyse de Contrat par IA",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // ZONE DE SÉLECTION (DRAG & DROP VISUEL)
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: posteBlue.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 60, color: posteBlue),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFile == null 
                        ? "Cliquez pour choisir un PDF / Image" 
                        : "Fichier prêt ✅",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_selectedFile != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Fichier : ${_selectedFile!.path.split(Platform.pathSeparator).last}",
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),

            const Spacer(),

            // BOUTON D'ACTION
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: (_selectedFile != null && !_isUploading) ? _startIAAudit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: posteBlue,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "LANCER L'EXTRACTION IA",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}