import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; //[cite: 3]
import 'package:pdf/pdf.dart'; 
import 'package:pdf/widgets.dart' as pw; 
import '../services/api_service.dart';
import 'correction_page.dart';

class UploadContract extends StatefulWidget {
  const UploadContract({super.key});

  @override
  State<UploadContract> createState() => _UploadContractState();
}

class _UploadContractState extends State<UploadContract> {
  final Color posteBlue = const Color(0xFF001A70);
  List<File> _selectedFiles = []; 
  bool _isUploading = false;

  // --- 1. SÉLECTION DE FICHIERS ---
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.paths.map((path) => File(path!)).toList();
        });
      }
    } catch (e) {
      _showSnackBar("Erreur de sélection", Colors.red);
    }
  }

  // --- 2. CAPTURE PHOTOS ---
  Future<void> _takePhotos() async {
    final ImagePicker picker = ImagePicker();
    List<File> tempFiles = [..._selectedFiles];
    bool continueScanning = true;

    while (continueScanning) {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 20, 
        maxWidth: 700,    
        maxHeight: 1000,  
      );
      if (photo != null) {
        tempFiles.add(File(photo.path));
        
        if (!mounted) break;
        bool? encore = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Page ajoutée"),
            content: Text("Voulez-vous photographier la page suivante ? (${tempFiles.length} pages)"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("TERMINER")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("OUI, SUIVANTE")),
            ],
          ),
        );
        if (encore != true) continueScanning = false;
      } else {
        continueScanning = false;
      }
    }

    if (tempFiles.isNotEmpty) {
      setState(() => _selectedFiles = tempFiles);
    }
  }

  // --- 3. GÉNÉRATION ET SAUVEGARDE DU PDF (VERSION SÉCURISÉE) ---
  Future<File?> _generateAndSavePdf(List<File> files) async {
    try {
      final pdf = pw.Document();

      for (var file in files) {
        if (await file.exists()) {
          // Lecture physique du fichier pour garantir que les bytes ne sont pas vides
          final Uint8List imageBytes = await file.readAsBytes(); 
          if (imageBytes.isNotEmpty) {
            final image = pw.MemoryImage(imageBytes);
            
            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (pw.Context context) => pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain, dpi: 72), // Insertion dans le PDF
                ),
              ),
            );
          }
        }
      }

      // Sauvegarde dans le dossier documents de l'application avec un nom unique (timestamp)
      final output = await getApplicationDocumentsDirectory();
      final String path = "${output.path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final File pdfFile = File(path);

      // Étape de sécurité : On enregistre les bytes et on flush pour forcer l'écriture Windows/Android
      await pdfFile.writeAsBytes(await pdf.save(), flush: true);

      // Vérification de la taille finale sur le disque
      int checkSize = await pdfFile.length();
      if (checkSize == 0) {
        debugPrint("❌ Erreur : Le fichier PDF généré est vide.");
        return null;
      }

      return pdfFile;
    } catch (e) {
      debugPrint("Erreur PDF : $e");
      return null;
    }
  }

  // --- 4. ENVOI ET ANALYSE IA ---
  Future<void> _startIAAudit() async {
    if (_selectedFiles.isEmpty) return;
    setState(() => _isUploading = true);

    try {
      File? fileToSend;
      
      // Si plusieurs images ou fichiers non-PDF, on génère un PDF unique
      if (_selectedFiles.length > 1 || !_selectedFiles.first.path.toLowerCase().endsWith('.pdf')) {
        fileToSend = await _generateAndSavePdf(_selectedFiles);
      } else {
        fileToSend = _selectedFiles.first;
      }

      if (fileToSend == null || await fileToSend.length() == 0) {
        _showSnackBar("Erreur : Impossible de générer un fichier valide.", Colors.red);
        return; 
      }

      debugPrint("📤 Envoi en cours... Taille : ${await fileToSend.length()} octets");

      final dataIA = await ApiService.uploadContract(fileToSend);

      if (dataIA != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CorrectionPage(data: dataIA)),
        );
      } else {
        _showSnackBar("L'IA n'a pas pu extraire de données.", Colors.orange);
      }
    } catch (e) {
      _showSnackBar("Erreur lors du traitement : $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          // Optionnel : _selectedFiles.clear(); // Nettoyage après succès[cite: 7]
        });
      }
    }
  }

  // --- UI HELPERS ---
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Numérisation IA", style: TextStyle(color: Colors.white)),
        backgroundColor: posteBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Capture multi-pages", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildSourceCard(Icons.camera_alt, "Prendre Photo", _takePhotos)),
                const SizedBox(width: 15),
                Expanded(child: _buildSourceCard(Icons.picture_as_pdf, "Choisir Fichier", _pickFiles)),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedFiles.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.description, color: Colors.blue),
                      title: Text("Page ${index + 1}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _selectedFiles.removeAt(index)),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_selectedFiles.isNotEmpty && !_isUploading) ? _startIAAudit : null,
                style: ElevatedButton.styleFrom(backgroundColor: posteBlue),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("FUSIONNER ET ANALYSER", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: posteBlue, size: 30), Text(label)],
        ),
      ),
    );
  }
}