import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importe le package http
import 'dart:convert'; // Pour jsonEncode et jsonDecode

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Clé globale pour identifier et valider le formulaire
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour récupérer le texte des champs
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false; // Pour afficher un indicateur de chargement
  String? _errorMessage; // Pour afficher les erreurs du backend ou générales
  String? _successMessage; // Pour afficher un message de succès

  // --- Validation Côté Client ---

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Regex simple pour la validation de l'email
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

   String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
       return 'Password must be at least 6 characters long';
    }
    // AJouter d'autres règles de validation si nécessaire (chiffres, majuscules, etc.)
    return null;
  }


  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // --- Fonction d'Enregistrement ---
  Future<void> _register() async {
    // Réinitialiser les messages précédents
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    // Valider le formulaire
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Affiche l'indicateur de chargement
      });

      // Récupérer les données des contrôleurs
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text; // Déjà validé pour correspondre

      // URL API backend 

      const String apiUrl = 'http://localhost:3000/api/auth/register';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{ // Encode les données en JSON
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'password': password,
            'confirmPassword': confirmPassword, // Backend le re-vérifie aussi
          }),
        );

         // Décode la réponse JSON
         final responseBody = jsonDecode(response.body);

        if (response.statusCode == 201) {
          // Succès
          setState(() {
              _successMessage = responseBody['message'] ?? 'Registration successful!';
              // Optionnel: Vider les champs après succès
              _formKey.currentState?.reset();
              _firstNameController.clear();
              _lastNameController.clear();
              _emailController.clear();
              _passwordController.clear();
              _confirmPasswordController.clear();
          });
          // Affiche un SnackBar de succès 
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(_successMessage!),
              backgroundColor: Colors.green,
            ),
          );

        } else {
          // Erreur gérée par le backend (400, 409, etc.)
          setState(() {
            _errorMessage = responseBody['message'] ?? 'An error occurred';
          });
        }
      } catch (e) {
        // Erreur de connexion ou autre erreur inattendue
        print('Registration Error: $e'); // Log pour le debug
        setState(() {
          _errorMessage = 'Could not connect to the server. Please try again later.';
        });
      } finally {
        // Quoi qu'il arrive, arrêter le chargement
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Le formulaire n'est pas valide, afficher un message (optionnel, les validateurs le font déjà)
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please fix the errors in the form')),
      // );
    }
  }

  @override
  void dispose() {
    // Libérer les contrôleurs quand le widget est détruit
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Utilise MediaQuery pour adapter la largeur du formulaire
    final screenWidth = MediaQuery.of(context).size.width;
    // Limite la largeur max du formulaire sur les grands écrans
    final formWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

    return Scaffold(
      // appBar: AppBar(title: const Text('Register')), // Optionnel
      body: Center( // Centre le contenu
        child: SingleChildScrollView( // Permet le défilement si le contenu dépasse
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox( // Limite la largeur du formulaire
             constraints: BoxConstraints(maxWidth: formWidth),
             child: Form(
               key: _formKey, // Attache la clé au formulaire
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center, // Centre verticalement
                 crossAxisAlignment: CrossAxisAlignment.stretch, // Étire les éléments en largeur
                 children: <Widget>[
                   // --- Titre et Description (Style inspiré du Dribbble) ---
                   const Text(
                     'Create Account',
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       fontSize: 28,
                       fontWeight: FontWeight.bold,
                       color: Colors.black87, // Ajuste la couleur
                     ),
                   ),
                   const SizedBox(height: 10),
                   const Text(
                     'Fill in the details below to create your account.',
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       fontSize: 16,
                       color: Colors.grey, // Ajuste la couleur
                     ),
                   ),
                   const SizedBox(height: 30),

                   // --- Affichage des Messages d'Erreur / Succès ---
                   if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                   // (Commenté car le SnackBar est plus visible pour le succès)
                   // if (_successMessage != null)
                   //   Padding(
                   //     padding: const EdgeInsets.only(bottom: 15.0),
                   //     child: Text(
                   //       _successMessage!,
                   //       style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                   //       textAlign: TextAlign.center,
                   //     ),
                   //   ),


                   // --- Champs du Formulaire ---
                   Row( // Pour mettre First Name et Last Name sur la même ligne
                     children: [
                       Expanded(
                         child: TextFormField(
                           controller: _firstNameController,
                           decoration: const InputDecoration(labelText: 'First Name'),
                           validator: (value) => _validateRequired(value, 'First Name'),
                           textInputAction: TextInputAction.next, // Pour passer au champ suivant
                         ),
                       ),
                       const SizedBox(width: 10), // Espace entre les champs
                       Expanded(
                         child: TextFormField(
                           controller: _lastNameController,
                           decoration: const InputDecoration(labelText: 'Last Name'),
                           validator: (value) => _validateRequired(value, 'Last Name'),
                           textInputAction: TextInputAction.next,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 15),
                   TextFormField(
                     controller: _emailController,
                     decoration: const InputDecoration(labelText: 'Email Address'),
                     validator: _validateEmail,
                     keyboardType: TextInputType.emailAddress,
                     textInputAction: TextInputAction.next,
                   ),
                   const SizedBox(height: 15),
                   TextFormField(
                     controller: _passwordController,
                     decoration: const InputDecoration(labelText: 'Password'),
                     obscureText: true, // Masque le mot de passe
                     validator: _validatePassword,
                     textInputAction: TextInputAction.next,
                   ),
                   const SizedBox(height: 15),
                   TextFormField(
                     controller: _confirmPasswordController,
                     decoration: const InputDecoration(labelText: 'Confirm Password'),
                     obscureText: true,
                     validator: _validateConfirmPassword,
                     textInputAction: TextInputAction.done, // Le dernier champ
                     onFieldSubmitted: (_) => _isLoading ? null : _register(), // Permet d'envoyer avec "Entrée"
                   ),
                   const SizedBox(height: 30),

                   // --- Bouton d'Enregistrement ---
                   ElevatedButton(
                     onPressed: _isLoading ? null : _register, // Désactive le bouton pendant le chargement
                     child: _isLoading
                         ? const SizedBox( // Indicateur de chargement
                             height: 20,
                             width: 20,
                             child: CircularProgressIndicator(
                               strokeWidth: 3,
                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                             ),
                           )
                         : const Text('Create Account'),
                   ),
                 ],
               ),
             ),
          )
        ),
      ),
    );
  }
}