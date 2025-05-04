// Centralise la configuration des URLs de l'API
class ApiConfig {
  // IMPORTANT : Modifiez cette URL pour pointer vers votre backend réel
  // Si vous testez sur un appareil physique, localhost ne fonctionnera pas.
  // Utilisez l'adresse IP locale de votre machine (ex: 'http://192.168.1.100:3000/api/auth')
  // ou un service comme ngrok pour exposer votre localhost.
  static const String _baseUrl = 'http://localhost:3000/api/auth';

  // Endpoint pour l'inscription
  static const String registerUrl = '$_baseUrl/register';

  // Endpoint pour la connexion
  static const String loginUrl = '$_baseUrl/login';
}
