class ApiConfig {
  // On définit l'adresse de base SANS le /api à la fin
  static const String baseUrl = "http://192.168.1.21:8000"; 

  // On ajoute le chemin complet ici, proprement
  static const String loginUrl = "$baseUrl/api/login";
  static const String statsUrl = "$baseUrl/api/contracts/stats";
  static const String contractsUrl = "$baseUrl/api/contracts";
  static const String uploadUrl = "$baseUrl/api/upload-contract";
  static const String saveUrl = "$baseUrl/api/save-contract"; 
  static const String feedbackUrl = "$baseUrl/api/contracts/feedback"; 
}