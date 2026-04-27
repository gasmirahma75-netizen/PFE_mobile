import 'dart:convert';
import 'package:http/http.dart' as http;

class AlertService {
  // Remplace par l'IP de ton serveur Node.js (affichée dans ton terminal Node)
  static const String baseUrl = "http://192.168.1.21:5000/api";

  // 1. Récupérer toutes les alertes
  static Future<List<dynamic>> getAlerts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/alerts'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec du chargement des alertes');
      }
    } catch (e) {
      print("❌ Erreur AlertService (getAlerts): $e");
      return [];
    }
  }

  // 2. Marquer une alerte comme lue (C'est la méthode qui te manquait !)
  static Future<bool> markAsRead(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/alerts/read/$id'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("✅ Alerte $id marquée comme lue");
        return true;
      } else {
        print("⚠️ Erreur lors du marquage: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Erreur AlertService (markAsRead): $e");
      return false;
    }
  }
}