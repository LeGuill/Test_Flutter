// Centralise la configuration des URLs de l'API
class ApiConfig {
// URL de base de l'API
  static const String _baseUrl = 'http://localhost:3000/api/auth';

  // Endpoint pour l'inscription
  static const String registerUrl = '$_baseUrl/register';

  // Endpoint pour la connexion
  static const String loginUrl = '$_baseUrl/login';
}
