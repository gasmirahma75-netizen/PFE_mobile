class ApiConfig {
  // Adresses de base
  static const String baseUrl = "http://192.168.1.21:5000"; 
  static const String serviceUrl = "http://192.168.1.21:8000";
 
  // --- AUTHENTIFICATION ---
  static const String loginUrl = "$baseUrl/api/login";
  static const String registerUrl = "$baseUrl/api/register";

  // --- GESTION DES UTILISATEURS ---
  static const String usersUrl = "$baseUrl/api/users"; // Pour lister, modifier, supprimer

  // --- CŒUR DU SYSTÈME (CONTRATS & AUDIT) ---
  static const String contractsUrl = "$baseUrl/api/contracts"; // GET pour la liste
  
  // CORRECTION : On utilise la même route /api/contracts pour l'enregistrement (POST)
  static const String saveUrl = "$baseUrl/api/contracts"; 
  
  // Envoi du fichier à Node.js qui transmet à FastAPI
  static const String uploadUrl = "$baseUrl/api/upload-contract";

  // --- ANALYSE DE DONNÉES & RETOURS ---
  static const String statsUrl = "$baseUrl/api/contracts/stats"; 
  static const String feedbackUrl = "$baseUrl/api/contracts/feedback"; 
}