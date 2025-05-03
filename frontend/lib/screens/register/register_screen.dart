import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Pour les requêtes HTTP
import 'dart:convert'; // Pour encoder/décoder le JSON

// Importe les widgets extraits du sous-dossier 'widgets'
import './widgets/background_layer.dart';
import './widgets/sliding_form_panel.dart';
import './widgets/open_form_button.dart';

// --- Widget principal de l'écran (Stateful car l'état change) ---
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// --- Classe d'état pour RegisterScreen ---
class _RegisterScreenState extends State<RegisterScreen> {
  // --- Clé Globale pour le Formulaire ---
  final _formKey = GlobalKey<FormState>();

  // --- Constantes de Couleur (pourraient être dans un fichier theme.dart) ---
  static const Color formBackgroundColor = Colors.white;
  static const Color primaryRedColor = Color.fromARGB(255, 255, 0, 0);
  static const Color greyTextColor = Colors.grey;
  static const Color darkTextColor = Color(0xFF333333);
  static const Color lightTextColor = Colors.white70;
  static const Color toggleButtonBg = Color(0xFFF0F0F0);

  // --- État pour l'Animation et la Visibilité ---
  bool _isFormVisible = true;
  static const Duration _slideDuration = Duration(milliseconds: 350);

  // --- Contrôleurs de Texte ---
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- Variables d'État du Formulaire ---
  String _selectedUserType = 'merchant';
  String? _selectedCompanyLocation;
  String? _selectedIndustry;
  bool _acceptedPrivacyPolicy = false;

  // --- État de Chargement et Message d'Erreur ---
  bool _isLoading = false;
  String? _errorMessage;

  // --- Données pour les Menus Déroulants ---
  final List<String> _companyLocations = ['United States', 'Canada', 'France', 'Germany', 'United Kingdom', 'Belgium', 'Other'];
  final List<String> _industries = ['Technology', 'Finance', 'Healthcare', 'Retail', 'Education', 'Other'];

  // --- Libération des Contrôleurs ---
  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Logique de Validation ---
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName est requis';
    return null;
  }
  String? _validateDropdown(String? value, String fieldName) {
    if (value == null) return 'Veuillez sélectionner $fieldName';
    return null;
  }
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'email est requis';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) return 'Veuillez entrer un format d\'email valide';
    return null;
  }
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis';
    if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
    return null;
  }

  // --- Logique d'Inscription ---
  Future<void> _register() async {
    setState(() { _errorMessage = null; });

    // 1. Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez corriger les erreurs dans le formulaire'), backgroundColor: Colors.red),
        );
      }
      return; // Arrêter si invalide
    }

    // 2. Activer le chargement et préparer les données
    setState(() { _isLoading = true; });
    final dataToSend = {
      'userType': _selectedUserType,
      'firstName': _firstNameController.text,
      'companyLocation': _selectedCompanyLocation,
      'email': _emailController.text,
      'industry': _selectedIndustry,
      'phoneNumber': _phoneNumberController.text,
      'password': _passwordController.text,
      'acceptedPrivacyPolicy': _acceptedPrivacyPolicy,
    };

    // 3. Envoyer la requête (remplacer l'URL)
    const String apiUrl = 'http://localhost:3000/api/auth/register'; // <-- METTRE VOTRE URL
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(dataToSend),
      );

      // 4. Traiter la réponse
      dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        print("Erreur de décodage JSON : $e | Réponse : ${response.body}");
        responseBody = {'message': 'Réponse invalide du serveur (Statut : ${response.statusCode})'};
      }

      if (response.statusCode == 201) { // Succès
        final successMsg = responseBody['message'] ?? 'Inscription réussie !';
        setState(() {
          // Réinitialiser l'état et les champs
          _formKey.currentState?.reset();
          _firstNameController.clear();
          _emailController.clear();
          _phoneNumberController.clear();
          _passwordController.clear();
          _selectedCompanyLocation = null;
          _selectedIndustry = null;
          _acceptedPrivacyPolicy = false;
          _selectedUserType = 'merchant';
          // _isFormVisible = false; // Optionnel: fermer le panneau
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(successMsg), backgroundColor: Colors.green, duration: const Duration(seconds: 3)),
          );
        }
      } else { // Erreur du backend
        setState(() {
          _errorMessage = responseBody['message'] ?? 'Une erreur est survenue : Statut ${response.statusCode}';
        });
      }
    } catch (e) { // Erreur réseau
      print('Erreur d\'inscription : $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Impossible de se connecter au serveur. Veuillez réessayer.';
        });
      }
    } finally {
      // Assurer que le chargement s'arrête
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // --- Méthode Build Principale ---
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth * 0.4; // Ajustez ce ratio si nécessaire

    return Scaffold(
      // Pas de backgroundColor ici, géré par BackgroundLayer
      body: Stack( // Superpose les couches
        children: [
          // Couche 1: Fond et contenu statique
          const BackgroundLayer(
            // Passe les constantes nécessaires si elles ne sont pas définies dans BackgroundLayer
            lightTextColor: lightTextColor,
          ),

          // Couche 2: Panneau de formulaire coulissant
          SlidingFormPanel(
            // État et dimensions
            isVisible: _isFormVisible,
            slideDuration: _slideDuration,
            formWidth: formWidth,
            // Clé et contrôleurs du formulaire
            formKey: _formKey,
            firstNameController: _firstNameController,
            emailController: _emailController,
            phoneNumberController: _phoneNumberController,
            passwordController: _passwordController,
            // Variables d'état du formulaire
            selectedUserType: _selectedUserType,
            selectedCompanyLocation: _selectedCompanyLocation,
            selectedIndustry: _selectedIndustry,
            acceptedPrivacyPolicy: _acceptedPrivacyPolicy,
            // État de chargement et erreur
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            // Données pour les menus déroulants
            companyLocations: _companyLocations,
            industries: _industries,
            // Callbacks pour mettre à jour l'état parent
            onUserTypeChanged: (value) => setState(() => _selectedUserType = value),
            onCompanyLocationChanged: (value) => setState(() => _selectedCompanyLocation = value),
            onIndustryChanged: (value) => setState(() => _selectedIndustry = value),
            // Le callback pour la checkbox met directement à jour l'état
            onPrivacyPolicyChanged: (value) => setState(() => _acceptedPrivacyPolicy = value ?? false),
            // Callback pour la soumission
            onRegister: _register,
            // Callback pour fermer le panneau
            onClose: () => setState(() => _isFormVisible = false),
            // Fonctions de validation
            validateRequired: _validateRequired,
            validateDropdown: _validateDropdown,
            validateEmail: _validateEmail,
            validatePassword: _validatePassword,
            // Couleurs (passées pour que le widget enfant n'ait pas à les redéfinir)
            formBackgroundColor: formBackgroundColor,
            primaryRedColor: primaryRedColor,
            greyTextColor: greyTextColor,
            darkTextColor: darkTextColor,
            toggleButtonBg: toggleButtonBg,
          ),

          // Couche 3: Bouton pour ouvrir le formulaire (si caché)
          if (!_isFormVisible)
            OpenFormButton(
              primaryRedColor: primaryRedColor,
              onPressed: () => setState(() => _isFormVisible = true),
            ),
        ],
      ),
    );
  }
}
