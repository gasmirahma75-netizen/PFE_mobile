import 'package:flutter/material.dart';
import '../services/api_service.dart'; // change path if needed

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _selectedRole = 'agent';
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ApiService.register(
      nomComplet: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compte créé avec succès")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'inscription")),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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

                Image.asset(
                  'assets/logo_poste.png',
                  height: 80,
                ),

                const SizedBox(height: 30),

                const Text(
                  "Inscription",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001D6E),
                  ),
                ),

                const Text(
                  "Créez un nouveau compte utilisateur",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),

                const SizedBox(height: 40),

                _buildFieldTitle("Nom complet"),
                _buildTextField(
                  controller: _nameController,
                  hint: "rahmaguesmi",
                ),

                _buildFieldTitle("Email professionnel"),
                _buildTextField(
                  controller: _emailController,
                  hint: "rahmaguesmi@poste.com",
                  keyboardType: TextInputType.emailAddress,
                ),

                _buildFieldTitle("Mot de passe"),
                _buildTextField(
                  controller: _passwordController,
                  hint: "••••••",
                  isPassword: true,
                ),

                _buildFieldTitle("Confirmer le mot de passe"),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: "••••••",
                  isPassword: true,
                ),

                _buildFieldTitle("Rôle de l'agent"),
                _buildRoleDropdown(),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.black12),
                        ),
                        child: const Text(
                          "Annuler",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF001D6E),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "S'inscrire",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  Widget _buildFieldTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Ce champ est obligatoire";
        }

        if (keyboardType == TextInputType.emailAddress && !value.contains("@")) {
          return "Email invalide";
        }

        if (isPassword && value.length < 3) {
          return "Mot de passe trop court";
        }

        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3F6F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF001D6E)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF001D6E)),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'agent', child: Text('Agent')),
        DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
            DropdownMenuItem(value: 'gestionnaire', child: Text('Gestionnaire')),
      ],
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedRole = val;
          });
        }
      },
    );
  }
}
