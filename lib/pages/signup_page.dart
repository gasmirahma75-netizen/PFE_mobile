import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'Agent de maintenance';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                // --- LOGO LA POSTE ---
                Image.asset(
                  'assets/logo_poste.png', // Assurez-vous d'avoir le logo dans vos assets
                  height: 80,
                ),
                const SizedBox(height: 30),
                const Text(
                  "Inscription",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001D6E), // Bleu marine
                  ),
                ),
                const Text(
                  "Créez un nouveau compte utilisateur",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // --- LES CHAMPS ---
                _buildFieldTitle("Nom Complet"),
                _buildTextField("nom complet"),

                _buildFieldTitle("Email professionnel"),
                _buildTextField("nom compet@poste.com"),

                _buildFieldTitle("Mot de passe"),
                _buildTextField("••••••", isPassword: true),

                _buildFieldTitle("Confirmer le mot de passe"),
                _buildTextField("••••••", isPassword: true),

                _buildFieldTitle("Rôle de l'agent"),
                _buildRoleDropdown(),

                const SizedBox(height: 40),

                // --- BOUTONS ---
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Colors.black12),
                        ),
                        child: const Text("Annuler", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Logique d'inscription ici
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF001D6E),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("S'inscrire", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour le titre au-dessus des champs
  Widget _buildFieldTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
      ),
    );
  }

  // Widget pour le design des champs de texte
  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return TextFormField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3F6F9), // Fond gris très léger
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF001D6E)),
        ),
      ),
    );
  }

  // Widget pour le menu déroulant du rôle
  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF3F6F9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
      items: ['Agent de maintenance', 'Administrateur', 'Audit'].map((role) {
        return DropdownMenuItem(value: role, child: Text(role));
      }).toList(),
      onChanged: (val) => setState(() => _selectedRole = val!),
    );
  }
}