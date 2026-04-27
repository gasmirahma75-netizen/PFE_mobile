import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Clés pour stocker les données dans le téléphone
  static const String _keyIsLoggedIn = "is_logged_in";
  static const String _keyUserName = "user_name";
  static const String _keyUserId = "user_id";

  // Sauvegarder les infos après le Login
  static Future<void> saveSession(int id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyUserId, id);
    await prefs.setString(_keyUserName, name);
  }

  // Vérifier si quelqu'un est déjà connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Récupérer le nom (pour afficher "Bonjour, Rahma")
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? "Utilisateur";
  }

  // Tout effacer (Déconnexion)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}