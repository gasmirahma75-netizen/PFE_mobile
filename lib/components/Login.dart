import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('saved_user_email');
    if (savedEmail != null) {
      setState(() => _emailController.text = savedEmail);
    }
  }

 

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnackBar("Veuillez remplir tous les champs", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim().toLowerCase(),
          "password": _passwordController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        
        // 1. SAUVEGARDE DU TOKEN JWT[cite: 1, 2]
        if (data['token'] != null) {
          await prefs.setString('jwt_token', data['token']);
        print("✅ Authentification réussie, Token enregistré"); // C'est ce message que vous cherchez
    }
        
        // 2. SAUVEGARDE DES INFOS UTILISATEUR[cite: 2]
        await prefs.setString('saved_user_email', _emailController.text.trim());
        String userName = data['user']?['nom_complet'] ?? "Utilisateur";
        await prefs.setString('user_name', userName);

        print("✅ Authentification réussie, Token enregistré.");

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
        
      } else {
        _showSnackBar(data['message'] ?? "Erreur d'authentification", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Erreur de connexion au serveur", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m, style: const TextStyle(color: Colors.white)), 
        backgroundColor: c, 
        duration: const Duration(seconds: 4)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color posteBlue = Color(0xFF003366);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo_poste.png', 
                  height: 100, 
                  errorBuilder: (ctx, err, st) => const Icon(Icons.account_balance, size: 80, color: posteBlue)
                ),
                const SizedBox(height: 20),
                const Text(
                  "Audit Contrats IA", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: posteBlue)
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController, 
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email", 
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  )
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController, 
                  obscureText: true, 
                  decoration: const InputDecoration(
                    labelText: "Mot de passe", 
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  )
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity, 
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: posteBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("SE CONNECTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) =>  SignUpPage())
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Pas encore de compte ? ",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "S'inscrire",
                          style: TextStyle(color: posteBlue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}