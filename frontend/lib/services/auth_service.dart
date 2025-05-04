import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Pour TimeoutException
import '../config/api_config.dart'; // Importe les URLs

// Classe responsable de la communication avec l'API d'authentification
class AuthService {

  // Méthode pour l'inscription
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(userData),
      ).timeout(const Duration(seconds: 15)); // Timeout un peu plus long

      dynamic responseBody;
      try { responseBody = jsonDecode(response.body); }
      catch(e) {
         print("AuthService Register: Invalid JSON - ${response.body}");
         // Tente de donner un message plus utile si possible
         String message = 'Invalid server response.';
         if (response.statusCode >= 500) message = 'Server error. Please try again later.';
         return {'success': false, 'message': message, 'statusCode': response.statusCode};
      }

      if (response.statusCode == 201) {
        return {'success': true, 'message': responseBody['message'] ?? 'Registration successful!', 'data': responseBody};
      } else {
        return {'success': false, 'message': responseBody['message'] ?? 'Registration failed.', 'statusCode': response.statusCode};
      }
    } on TimeoutException catch (_) {
       print('AuthService Register Error: Timeout');
       return {'success': false, 'message': 'Connection timed out. Please try again.'};
    } on http.ClientException catch (e) { // Erreurs réseau spécifiques
       print('AuthService Register Error: ClientException - $e');
       return {'success': false, 'message': 'Network error. Please check your connection.'};
    } catch (e) { // Autres erreurs
      print('AuthService Register Error: $e');
      return {'success': false, 'message': 'An unexpected error occurred during registration.'};
    }
  }

  // Méthode pour la connexion
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      dynamic responseBody;
      try { responseBody = jsonDecode(response.body); }
      catch(e) {
         print("AuthService Login: Invalid JSON - ${response.body}");
         String message = 'Invalid server response.';
         if (response.statusCode >= 500) message = 'Server error. Please try again later.';
         else if (response.statusCode == 401) message = 'Invalid credentials.'; // Message par défaut pour 401
         return {'success': false, 'message': message, 'statusCode': response.statusCode};
      }

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseBody['message'] ?? 'Login successful!', 'data': responseBody['userData']};
      } else {
        return {'success': false, 'message': responseBody['message'] ?? 'Login failed.', 'statusCode': response.statusCode};
      }
     } on TimeoutException catch (_) {
       print('AuthService Login Error: Timeout');
       return {'success': false, 'message': 'Connection timed out. Please try again.'};
    } on http.ClientException catch (e) {
       print('AuthService Login Error: ClientException - $e');
       return {'success': false, 'message': 'Network error. Please check your connection.'};
    } catch (e) {
      print('AuthService Login Error: $e');
      return {'success': false, 'message': 'An unexpected error occurred during login.'};
    }
  }
}
