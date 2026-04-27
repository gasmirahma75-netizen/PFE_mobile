import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.21:8000/api";
  static const storage = FlutterSecureStorage();

  // --- MÉTHODE POST GÉNÉRIQUE ---
  static Future<http.Response?> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
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
      await storage.write(key: 'user_id', value: data['user']['id'].toString());
      return data;
    }
    return null;
  }

  // --- TRAITEMENT IA (CORRIGÉ POUR UN SEUL FICHIER) ---
  static Future<Map<String, dynamic>?> uploadContract(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/extract-text"));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      }
      return null;
    } catch (e) {
      print("❌ Erreur upload: $e");
      return null;
    }
  }

  // --- GESTION DES CONTRATS ---

  // ✅ CORRECTION DU TYPE : Déplacement du "?" pour correspondre à l'appel
  // On renvoie Future<Map<String, dynamic>> et on gère le vide par une Map vide {}
  static Future<Map<String, dynamic>> getContractById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/contracts/$id"),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {}; // Renvoie une map vide au lieu de null
    } catch (e) {
      print("❌ Erreur getContractById: $e");
      return {}; // Renvoie une map vide en cas d'erreur
    }
  }

  static Future<List<dynamic>> getAllContracts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/contracts"))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveContract(Map<String, dynamic> contractData) async {
    final response = await post("/save-contract", contractData);
    return response != null && response.statusCode == 200;
  }
}