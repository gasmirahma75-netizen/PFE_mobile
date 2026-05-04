import 'package:flutter/material.dart';
import 'dart:io';

// --- SERVICES ---
import 'services/api_service.dart';

// --- COMPONENTS ---
import 'components/Navbar.dart';

// --- PAGES ---
import 'pages/signup_page.dart';
import 'pages/gerer_contract.dart';
import 'pages/user_management_page.dart';
import 'pages/UploadContract.dart'; // Import crucial pour la numérisation
import 'pages/correction_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      // Point d'entrée : Page de connexion
      home: const LoginPage(),
      
      // Définition des routes nommées pour une navigation propre
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/upload': (context) => const UploadContract(), // Route vers le scanner PDF
        '/gestion_contrats': (context) => GererContractPage(),
        '/gestion_users': (context) => const UserManagementPage(),
      },
    );
  }
}

// ==========================================
// 1. PAGE DE CONNEXION
// ==========================================
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
      _showSnackBar("Veuillez remplir tous les champs", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await ApiService.login(
        _emailCtrl.text.trim().toLowerCase(),
        _passCtrl.text.trim(),
      );

      if (data != null && data['success'] == true) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard'); // Navigation vers Dashboard
      } else {
        _showSnackBar("Email ou mot de passe incorrect", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Serveur injoignable (Vérifiez l'IP du backend)", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), backgroundColor: c),
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
              // Logo de la Poste Tunisienne
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
                onTap: () => Navigator.pushNamed(context, '/signup'),
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

// ==========================================
// 2. DASHBOARD (SUPERVISION)
// ==========================================
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
      drawer: const Navbar(), // Utilisation de votre composant Navbar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_customize, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            const Text("Bienvenue sur la plateforme d'audit", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const Text("PFE - La Poste Tunisienne 2026", 
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
      // Bouton flottant qui lance le nouveau scanner robuste[cite: 8]
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/upload'),
        label: const Text("Nouvel Audit", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: posteBlue,
      ),
    );
  }
}