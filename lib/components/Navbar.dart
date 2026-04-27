import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/session_manager.dart'; // Assure-toi que ce service existe pour le nom
import '../pages/UploadContract.dart';
import '../components/Login.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    // Couleurs officielles Poste Tunisienne
    const Color posteBlue = Color(0xFF001A70);
    const Color posteYellow = Color(0xFFFFC20E);

    return Drawer(
      child: Column(
        children: [
          // --- HEADER : INFOS UTILISATEUR ---
          FutureBuilder<String>(
            future: SessionManager.getUserName(), // Récupère le nom stocké
            builder: (context, snap) {
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: posteBlue),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: posteYellow,
                  child: Text(
                    (snap.hasData && snap.data!.isNotEmpty) 
                        ? snap.data![0].toUpperCase() 
                        : "U",
                    style: const TextStyle(
                      fontSize: 32.0, 
                      color: posteBlue, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                accountName: Text(
                  snap.data ?? "Utilisateur",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                accountEmail: const Text("PFE 2026 - IA Audit System"),
              );
            },
          ),

          // --- OPTIONS DE NAVIGATION ---
          ListTile(
            leading: const Icon(Icons.dashboard_outlined, color: posteBlue),
            title: const Text("Tableau de Bord"),
            onTap: () {
              Navigator.pop(context); // Ferme le menu
              // Si tu es déjà sur le Dashboard, on fait juste un pop
            },
          ),

          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined, color: posteBlue),
            title: const Text("Nouvel Audit"),
            onTap: () {
              Navigator.pop(context); // Ferme le menu
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const UploadContract())
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.history_outlined, color: posteBlue),
            title: const Text("Historique"),
            onTap: () {
              // Navigator.pushNamed(context, '/history');
            },
          ),

          const Spacer(), // Pousse le bouton déconnexion vers le bas
          const Divider(),

          // --- BOUTON DÉCONNEXION ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Déconnexion", 
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
            ),
            onTap: () async {
              // 1. Demander confirmation
              bool confirm = await _showLogoutDialog(context);
              
              if (confirm) {
                // 2. Vider les préférences (token, nom, etc.)
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // 3. Retourner au Login et vider la pile de navigation
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => const LoginPage ()), 
                    (route) => false,
                  );
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Fonction pour afficher la boîte de dialogue de confirmation
  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment quitter l'application ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Oui, déconnexion", 
              style: TextStyle(color: Colors.red)
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}