import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<dynamic> users = [];
  bool isLoading = true;
  final Color posteBlue = const Color(0xFF001A70);

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // --- RÉCUPÉRATION DES UTILISATEURS AVEC SÉCURITÉ ---
  Future<void> _fetchUsers() async {
    try {
      setState(() => isLoading = true);
      final data = await ApiService.getAllUsers();
      setState(() {
        // Sécurité : si data est null, on évite le crash avec une liste vide
        users = data ?? []; 
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de connexion : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

 // --- DIALOGUE DE MODIFICATION SÉCURISÉ AVEC GESTIONNAIRE ---
  void _showEditDialog(dynamic user) {
    // Sécurité sur les champs texte pour éviter l'écran rouge
    final nomCtrl = TextEditingController(text: user['nom_complet']?.toString() ?? "");
    final emailCtrl = TextEditingController(text: user['email']?.toString() ?? "");
    
    // --- SÉCURISATION DU RÔLE (Ajout de Gestionnaire) ---
    List<String> rolesAutorises = ['Admin', 'Gestionnaire', 'Agent'];
    
    String selectedRole = user['role']?.toString() ?? 'Agent';
    
    // Si le rôle en base n'est pas dans notre liste, on met 'Agent' par défaut
    if (!rolesAutorises.contains(selectedRole)) {
      selectedRole = 'Agent';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Modifier l'utilisateur"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomCtrl, 
                  decoration: const InputDecoration(labelText: "Nom Complet")
                ),
                TextField(
                  controller: emailCtrl, 
                  decoration: const InputDecoration(labelText: "Email")
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Rôle de l'utilisateur :", style: TextStyle(fontSize: 12, color: Colors.grey))
                ),
                DropdownButton<String>(
                  value: selectedRole,
                  isExpanded: true,
                  underline: Container(height: 1, color: Colors.grey),
                  items: rolesAutorises.map((String r) {
                    return DropdownMenuItem<String>(
                      value: r,
                      child: Text(r),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // Met à jour l'affichage dans le dialogue immédiatement
                      setDialogState(() {
                        selectedRole = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Annuler")
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: posteBlue),
              onPressed: () async {
                // Préparation des données pour l'API
                Map<String, dynamic> updateData = {
                  'nom_complet': nomCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'role': selectedRole, // Admin, Gestionnaire ou Agent
                };

                bool ok = await ApiService.updateUser(user['id'], updateData);
                
                if (ok && mounted) {
                  Navigator.pop(context);
                  _fetchUsers(); // Rafraîchir la liste sur l'écran principal
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Utilisateur mis à jour avec succès"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Utilisateurs"),
        backgroundColor: posteBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _fetchUsers, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchUsers,
              child: users.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucun utilisateur trouvé.\nVérifiez votre base contracts_ai.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) {
                        final u = users[index];
                        
                        // --- SÉCURITÉ ANTI-CRASH (L'erreur RangeError venait d'ici) ---
                        String displayInitial = "?";
                        if (u['nom_complet'] != null && u['nom_complet'].toString().trim().isNotEmpty) {
                          displayInitial = u['nom_complet'].toString().trim()[0].toUpperCase();
                        }

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: posteBlue,
                              child: Text(displayInitial, style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(u['nom_complet']?.toString() ?? "Sans nom", 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${u['email'] ?? 'Pas d\'email'}\nRôle: ${u['role'] ?? 'Agent'}"),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditDialog(u),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    bool? confirm = await _confirmDelete();
                                    if (confirm == true) {
                                      bool ok = await ApiService.deleteUser(u['id']);
                                      if (ok) _fetchUsers();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Future<bool?> _confirmDelete() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer ?"),
        content: const Text("Voulez-vous vraiment supprimer cet utilisateur de la base ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }
}