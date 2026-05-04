import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORTS ---
import '../main.dart'; 
import '../services/session_manager.dart'; 
import '../pages/UploadContract.dart';
import '../pages/user_management_page.dart'; 
import 'package:frontend_flutter/pages/gerer_contract.dart';
import '../main.dart';
import '../pages/UploadContract.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    const Color posteBlue = Color(0xFF001A70);
    const Color posteYellow = Color(0xFFFFC20E);

    return Drawer(
      child: Column(
        children: [
          // --- ENTÊTE DU MENU SÉCURISÉE ---
          FutureBuilder<String>(
            future: SessionManager.getUserName(),
            builder: (context, snap) {
              // On récupère le nom de la session
              String name = snap.data ?? "Utilisateur";
              
              // SÉCURITÉ : On vérifie si le nom est vide avant de prendre la 1ère lettre
              String initial = "U";
              if (name.trim().isNotEmpty) {
                initial = name.trim()[0].toUpperCase();
              }

              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: posteBlue),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: posteYellow,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 32.0, 
                      color: posteBlue, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                accountEmail: const Text("La Poste Tunisienne - Audit IA"),
              );
            },
          ),

          // --- OPTIONS DE NAVIGATION ---
          ListTile(
            leading: const Icon(Icons.grid_view_rounded, color: Colors.blueGrey),
            title: const Text("Tableau de Bord"),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.people_outline, color: posteBlue),
            title: const Text("Gérer Utilisateurs"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManagementPage()));
            },
          ),

          ListTile(
            leading: const Icon(Icons.assignment_outlined, color: posteBlue),
            title: const Text("Gérer Contrats"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => GererContractPage()));
            },
          ),
          
         ListTile(
  leading: const Icon(Icons.add_a_photo_outlined, color: posteBlue),
  title: const Text("Nouvel Audit"),
  onTap: () {
    // 1. On ferme le Drawer pour libérer l'écran
    Navigator.pop(context); 
    
    // 2. On navigue vers AuditPage (définie dans main.dart)
    // C'est cette page qui contient la boucle while(takingPhotos)
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const UploadContract())
    );
  },
),

          const Spacer(),
          const Divider(),

          // --- BOUTON DÉCONNEXION ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.grey),
            title: const Text("Déconnexion"),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginPage()), 
                  (route) => false
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}