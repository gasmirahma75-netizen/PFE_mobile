import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import 'package:url_launcher/url_launcher.dart';

class GererContractPage extends StatefulWidget {
  @override
  _GererContractPageState createState() => _GererContractPageState();
}

class _GererContractPageState extends State<GererContractPage> {
  List allContracts = []; 
  List filteredContracts = []; 
  bool isLoading = true;
  String searchQuery = "";
  final Color posteBlue = const Color(0xFF001A70);

  @override
  void initState() {
    super.initState();
    fetchContracts();
  }

  Future<void> fetchContracts() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(ApiConfig.contractsUrl));
      if (response.statusCode == 200) {
        setState(() {
          allContracts = json.decode(response.body);
          filteredContracts = allContracts; 
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterContracts(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredContracts = allContracts;
      } else {
        final input = query.toLowerCase().trim(); 
        
        filteredContracts = allContracts.where((c) {
          final objet = (c['objet'] ?? "").toString().toLowerCase();
          final montant = (c['montant'] ?? "").toString().toLowerCase();
          final direction = (c['direction'] ?? "").toString().toLowerCase();
          final nomFichier = (c['nom_fichier'] ?? "").toString().toLowerCase();
          final dateDebut = (c['date_debut'] ?? "").toString().toLowerCase();
          final dateFin = (c['date_fin'] ?? "").toString().toLowerCase();
          final status = (c['status'] ?? "").toString().toLowerCase();

          return objet.contains(input) || 
                 montant.contains(input) || 
                 direction.contains(input) || 
                 nomFichier.contains(input) ||
                 dateDebut.contains(input) ||
                 dateFin.contains(input) ||
                 status.contains(input);
        }).toList();
      }
    });
  }

  void _showEditDialog(dynamic contract) {
    final objetCtrl = TextEditingController(text: contract['objet']?.toString() ?? "");
    final montantCtrl = TextEditingController(text: contract['montant']?.toString() ?? "0");
    final directionCtrl = TextEditingController(text: contract['direction']?.toString() ?? "");
    String selectedStatus = contract['status'] ?? "En attente";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier le contrat"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: objetCtrl, decoration: const InputDecoration(labelText: "Objet")),
              TextField(controller: montantCtrl, decoration: const InputDecoration(labelText: "Montant"), keyboardType: TextInputType.number),
              TextField(controller: directionCtrl, decoration: const InputDecoration(labelText: "Direction")),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: ["En attente", "Validé", "Expiré"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => selectedStatus = val!,
                decoration: const InputDecoration(labelText: "Statut"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final response = await http.put(
                Uri.parse("${ApiConfig.contractsUrl}/${contract['id']}"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "objet": objetCtrl.text,
                  "montant": montantCtrl.text,
                  "direction": directionCtrl.text,
                  "status": selectedStatus,
                  "date_debut": contract['date_debut'],
                  "date_fin": contract['date_fin'],
                  "nom_fichier": contract['nom_fichier'] // On conserve le nom du fichier existant
                }),
              );
              if (response.statusCode == 200) {
                Navigator.pop(context);
                fetchContracts(); 
              }
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

void _showDetails(dynamic c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Détails du Contrat", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: posteBlue)),
            const Divider(),
            ListTile(leading: const Icon(Icons.info), title: const Text("Objet"), subtitle: Text(c['objet'] ?? "N/A")),
            ListTile(leading: const Icon(Icons.business), title: const Text("Direction"), subtitle: Text(c['direction'] ?? "N/A")),
            ListTile(leading: const Icon(Icons.calendar_today), title: const Text("Période"), subtitle: Text("Du ${c['date_debut'] ?? '...'} au ${c['date_fin'] ?? '...'}")),
            ListTile(leading: const Icon(Icons.file_present), title: const Text("Fichier"), subtitle: Text(c['nom_fichier'] ?? "Aucun fichier associé")),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                // ✅ Désactivation du bouton si le nom du fichier est NULL ou vide
                onPressed: (c['nom_fichier'] == null || c['nom_fichier'].toString().isEmpty) 
                ? null 
                : () async {
                  final String fileName = c['nom_fichier'].toString();
                  final String fileUrl = "${ApiConfig.baseUrl}/uploads/$fileName";
                  final Uri url = Uri.parse(fileUrl);
                  
                  try {
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Impossible d'ouvrir le fichier : $fileName")),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erreur lors de l'ouverture du PDF")),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(c['nom_fichier'] == null ? "Fichier manquant" : "Visualiser le PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Contrats"),
        backgroundColor: posteBlue,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterContracts,
              decoration: InputDecoration(
                hintText: "Rechercher un contrat...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredContracts.length,
              itemBuilder: (context, index) {
                final item = filteredContracts[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    onTap: () => _showDetails(item), 
                    title: Text(item['objet'] ?? "Sans titre", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${item['montant'] ?? 0} DT - ${item['direction'] ?? 'Direction inconnue'}"),
                        Chip(
                          label: Text(item['status'] ?? "En attente", style: const TextStyle(fontSize: 10)),
                          backgroundColor: item['status'] == "Validé" ? Colors.green[100] : Colors.orange[100],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue), 
                          onPressed: () => _showEditDialog(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red), 
                          onPressed: () async {
                            bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirmation"),
                                content: const Text("Voulez-vous vraiment supprimer ce contrat ?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false), 
                                    child: const Text("Annuler"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                final response = await http.delete(
                                  Uri.parse("${ApiConfig.contractsUrl}/${item['id']}"),
                                );
                                if (response.statusCode == 200) {
                                  fetchContracts(); 
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Contrat supprimé"), backgroundColor: Colors.green),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}