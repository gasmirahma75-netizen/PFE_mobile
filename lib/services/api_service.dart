import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants.dart'; // ✅ Correct si constants.dart est dans lib/

class ApiService {
  // Configuration des URLs de base
  static const String baseUrl = "${ApiConfig.baseUrl}/api";
  static const String serviceUrl = ApiConfig.serviceUrl;
  static const storage = FlutterSecureStorage();

  // --- MÉTHODE POST GÉNÉRIQUE ---
  // Centralise les appels pour une meilleure gestion des erreurs réseau
 static Future<http.Response?> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse("$baseUrl$endpoint");
      print("🚀 Requête POST vers : $url");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 60)); // Augmenté à 60s pour la stabilité

      return response;
    } catch (e) {
      print("❌ Erreur Réseau (POST): $e");
      return null;
    }
  }

  // --- AUTHENTIFICATION ---
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await post("/login", {'email': email, 'password': password});
    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Stockage sécurisé de l'ID utilisateur pour les sessions
      await storage.write(key: 'user_id', value: data['user']['id'].toString());
      return data;
    }
    return null;
  }

  static Future<bool> register({
    required String nomComplet,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await post("/register", {
      'nom_complet': nomComplet,
      'email': email,
      'password': password,
      'role': role,
    });
    return response != null && (response.statusCode == 200 || response.statusCode == 201);
  }

  // --- TRAITEMENT IA (FASTAPI) ---
// --- TRAITEMENT IA (PASSAGE PAR NODE.JS) ---
  static Future<Map<String, dynamic>?> uploadContract(File file) async {
    try {
      // Utilisation de l'URL Node.js (Port 5000)
      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.uploadUrl));
      
      // Ajout du fichier PDF
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      print("📤 Envoi du fichier vers Node.js : ${ApiConfig.uploadUrl}");

      // CRITIQUE : Augmentation du timeout à 120 secondes pour éviter le "Lost connection"
    var streamedResponse = await request.send();
var response = await http.Response.fromStream(streamedResponse); // ATTENDRE LE FLUX COMPLET
      
      if (response.statusCode == 200) {
        print("✅ Réponse IA reçue avec succès");
        return jsonDecode(response.body); 
      } else {
        print("❌ Erreur serveur (${response.statusCode}): ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Erreur critique upload (Timeout possible): $e");
      return null;
    }
  }
  // CORRIGÉ : Route "/contracts" au lieu de "/save-contract"[cite: 6]
  static Future<bool> saveContract(Map<String, dynamic> contractData) async {
    // Appel vers l'ID 44 que vous avez vu dans votre console
    final response = await post("/contracts", contractData);
    
    if (response != null) {
      print("📥 Réponse Serveur : ${response.body}");
      return response.statusCode == 200 || response.statusCode == 201;
    }
    return false;
  }

  // ... (Reste des méthodes login, register, getAllUsers identiques)

  static Future<List<dynamic>> getAllContracts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/contracts"))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print("❌ Erreur getAllContracts: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> getContractById(int id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/contracts/$id"))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      print("❌ Erreur getContractById: $e");
      return {};
    }
  }

  // --- GESTION DES UTILISATEURS ---

  static Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/users"))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print("❌ Erreur getAllUsers: $e");
      return [];
    }
  }

  static Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/users/$id"))
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Erreur deleteUser: $e");
      return false;
    }
  }

  static Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/users/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Erreur updateUser: $e");
      return false;
    }
  }
}