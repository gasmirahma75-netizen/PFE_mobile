import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import de ton service API
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

const Color posteBlue = Color(0xFF001A70);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IA Audit Poste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: posteBlue,
        colorScheme: ColorScheme.fromSeed(seedColor: posteBlue),
      ),
      // Définition de la page de démarrage
      home: const LoginPage(),
    );
  }
}

// --- 1. PAGE DE CONNEXION ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showError("Veuillez remplir tous les champs");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Appel au service avec l'IP 192.168.1.21:8000
      final data = await ApiService.login(
        _emailCtrl.text.trim().toLowerCase(),
        _passCtrl.text.trim(),
      );

      if (data != null && data['success'] == true) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      } else {
        _showError("Email ou mot de passe incorrect");
      }
    } catch (e) {
      _showError("Impossible de joindre le serveur (Vérifiez l'IP)");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), backgroundColor: Colors.red),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Image.asset('assets/logo_poste.png', height: 120, 
                errorBuilder: (c, e, s) => const Icon(Icons.account_balance, size: 80, color: posteBlue)),
              const SizedBox(height: 20),
              const Text("Audit Contrats IA", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: posteBlue)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mot de passe", prefixIcon: Icon(Icons.lock)),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(backgroundColor: posteBlue),
                        child: const Text("SE CONNECTER", style: TextStyle(color: Colors.white)),
                      ),
                    ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage())),
                child: const Text("Pas encore de compte ? S'inscrire",
                    style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. DASHBOARD (ACCUEIL) ---
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supervision DAS ERP"),
        backgroundColor: posteBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_customize, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            const Text("Bienvenue Rahma - PFE 2026", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AuditPage())),
        label: const Text("Nouvel Audit", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: posteBlue,
      ),
    );
  }
}

// --- 3. PAGE D'AUDIT (SÉLECTION DOCUMENT) ---
class AuditPage extends StatefulWidget {
  const AuditPage({super.key});

  @override
  State<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends State<AuditPage> {
  bool _isAnalyzing = false;

  Future<void> _analyze(String path) async {
    setState(() => _isAnalyzing = true);
    try {
      final data = await ApiService.uploadContract(File(path));
      if (data != null) {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => CorrectionPage(data: data)));
      } else {
        _showSnackBar("Erreur d'analyse IA", Colors.orange);
      }
    } catch (e) {
      _showSnackBar("Serveur injoignable", Colors.red);
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _showSnackBar(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Source du document")),
      body: _isAnalyzing
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 20), Text("IA en cours d'analyse... ")]))
          : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceBtn(Icons.picture_as_pdf, "PDF", Colors.red, () async {
                    FilePickerResult? r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                    if (r != null) _analyze(r.files.single.path!);
                  }),
                  _buildSourceBtn(Icons.camera_alt, "CAMÉRA", Colors.green, () async {
                    final XFile? p = await ImagePicker().pickImage(source: ImageSource.camera);
                    if (p != null) _analyze(p.path);
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildSourceBtn(IconData i, String t, Color c, VoidCallback a) => InkWell(
        onTap: a,
        child: Container(
          width: 140, height: 140,
          decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: c)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 40, color: c), const SizedBox(height: 10), Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold))]),
        ),
      );
}

// --- 4. PAGE DE CORRECTION / VALIDATION ---
class CorrectionPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const CorrectionPage({super.key, required this.data});

  @override
  State<CorrectionPage> createState() => _CorrectionPageState();
}

class _CorrectionPageState extends State<CorrectionPage> {
  late TextEditingController cObjet, cDirection, cMontant;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // On pré-remplit avec les données extraites par l'IA
    cObjet = TextEditingController(text: widget.data['objet']?.toString() ?? "");
    cDirection = TextEditingController(text: widget.data['direction']?.toString() ?? "");
    cMontant = TextEditingController(text: widget.data['montant']?.toString() ?? "");
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    bool ok = await ApiService.saveContract({
      "objet": cObjet.text,
      "direction": cDirection.text,
      "montant": cMontant.text
    });
    
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Contrat enregistré en base de données !"), backgroundColor: Colors.green));
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Erreur lors de l'enregistrement"), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Validation IA"), backgroundColor: posteBlue, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Vérifiez les informations extraites :", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: cObjet, decoration: const InputDecoration(labelText: "Objet du contrat", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: cDirection, decoration: const InputDecoration(labelText: "Direction concernée", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: cMontant, decoration: const InputDecoration(labelText: "Montant (TND)", border: OutlineInputBorder())),
              const SizedBox(height: 30),
              _isSaving 
                ? const CircularProgressIndicator() 
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save, 
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text("CONFIRMER ET ENREGISTRER")
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 5. PAGE D'INSCRIPTION ---
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: const Center(child: Text("Service d'inscription bientôt disponible")),
    );
  }
}