import 'package:flutter/material.dart';

// Importe les dépendances et les fichiers locaux
import '../../config/app_colors.dart'; // Importe les couleurs
// import '../../config/api_config.dart'; // Importé par AuthService
import '../../services/auth_service.dart'; // Importe le service d'authentification
import '../../utils/validators.dart'; // Importe les validateurs
import 'widgets/background_layer.dart'; // Importe le widget de fond
import 'widgets/sliding_form_panel.dart'; // Importe le panneau de formulaire
// Importe le widget de champ de texte pour le dialogue de connexion
import 'widgets/form_elements/custom_text_field.dart';

// --- Widget principal de l'écran (Stateful car l'état change) ---
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// --- Classe d'état pour RegisterScreen ---
class _RegisterScreenState extends State<RegisterScreen> {
  // --- Clés Globales ---
  final _registerFormKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();

  // --- Service d'Authentification ---
  final AuthService _authService = AuthService(); // Instance du service

  // --- États UI ---
  bool _isRegisterFormVisible = false;
  bool _isLoggedIn = false;
  String? _loggedInUserFirstName;
  // Pourrait être dans app_constants.dart
  static const Duration _slideDuration = Duration(milliseconds: 350);

  // --- Contrôleurs de Texte (Inscription) ---
  final _firstNameController = TextEditingController();
  final _emailRegisterController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordRegisterController = TextEditingController();

  // --- Contrôleurs de Texte (Connexion) ---
  final _emailLoginController = TextEditingController();
  final _passwordLoginController = TextEditingController();

  // --- Variables d'État du Formulaire d'Inscription ---
  String _selectedUserType = 'merchant';
  String? _selectedCompanyLocation;
  String? _selectedIndustry;
  bool _acceptedPrivacyPolicy = false;

  // --- État de Chargement et Message d'Erreur ---
  bool _isLoadingRegister = false;
  String? _errorMessageRegister; // Erreur spécifique à l'inscription (ex: backend)
  bool _isLoadingLogin = false;
  String? _errorMessageLogin; // Erreur spécifique à la connexion (pour le dialogue)

  // --- Données pour les Menus Déroulants ---
  // Pourraient venir d'une config ou d'une API
  final List<String> _companyLocations = ['United States', 'Canada', 'France', 'Germany', 'United Kingdom', 'Belgium', 'Other'];
  final List<String> _industries = ['Technology', 'Finance', 'Healthcare', 'Retail', 'Education', 'Other'];

  // --- Libération des Contrôleurs ---
  @override
  void dispose() {
    _firstNameController.dispose();
    _emailRegisterController.dispose();
    _phoneNumberController.dispose();
    _passwordRegisterController.dispose();
    _emailLoginController.dispose();
    _passwordLoginController.dispose();
    super.dispose();
  }

  // --- Logique d'Inscription (utilise AuthService) ---
  Future<void> _register() async {
    setState(() { _errorMessageRegister = null; });
    if (!_registerFormKey.currentState!.validate()) {
      _showErrorSnackBar('Please fix the errors in the form');
      return;
    }
    setState(() { _isLoadingRegister = true; });
    final userData = {
      'userType': _selectedUserType,
      'firstName': _firstNameController.text,
      'companyLocation': _selectedCompanyLocation,
      'email': _emailRegisterController.text,
      'industry': _selectedIndustry,
      'phoneNumber': _phoneNumberController.text,
      'password': _passwordRegisterController.text,
      'acceptedPrivacyPolicy': _acceptedPrivacyPolicy,
    };

    // Appel au service d'authentification
    final result = await _authService.registerUser(userData);

    if (mounted) {
      setState(() { _isLoadingRegister = false; });
      if (result['success'] == true) {
        setState(() {
          _registerFormKey.currentState?.reset();
          _firstNameController.clear(); _emailRegisterController.clear(); _phoneNumberController.clear(); _passwordRegisterController.clear();
          _selectedCompanyLocation = null; _selectedIndustry = null;
          _acceptedPrivacyPolicy = false; _selectedUserType = 'merchant';
          _isRegisterFormVisible = false;
        });
        _showSuccessSnackBar(result['message']);
      } else {
        // Affiche l'erreur renvoyée par le service (peut être affichée dans le panneau)
        setState(() { _errorMessageRegister = result['message']; });
        // _showErrorSnackBar(result['message']); // Optionnel: afficher aussi en SnackBar
      }
    }
  }

  // --- Logique de Connexion (utilise AuthService) ---
  Future<void> _handleLogin(BuildContext dialogContext, StateSetter setDialogState) async {
    setDialogState(() { _errorMessageLogin = null; });
    if (!_loginFormKey.currentState!.validate()) {
       return;
    }
    setDialogState(() { _isLoadingLogin = true; });

    final email = _emailLoginController.text;
    final password = _passwordLoginController.text;

    // Appel au service d'authentification
    final result = await _authService.loginUser(email, password);

    // Utilise 'mounted' du State principal car setDialogState peut échouer si dialogue fermé prématurément
    if (!mounted) return;

    if (result['success'] == true) {
        final String firstName = result['data']?['firstName'] ?? 'User';
        Navigator.pop(dialogContext); // Ferme le dialogue
        setState(() { // Met à jour l'état principal
          _isLoggedIn = true;
          _loggedInUserFirstName = firstName;
          _emailLoginController.clear();
          _passwordLoginController.clear();
        });
    } else {
        // Met à jour l'erreur DANS le dialogue via setDialogState
        setDialogState(() {
          _errorMessageLogin = result['message'];
          _isLoadingLogin = false; // Arrête le chargement du dialogue
        });
    }
  }


  // --- Logique de Déconnexion ---
  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _loggedInUserFirstName = null;
      _emailLoginController.clear();
      _passwordLoginController.clear();
    });
  }

  // --- Affichage de la Boîte de Dialogue de Connexion ---
  void _showLoginDialog() {
    _errorMessageLogin = null;
    _isLoadingLogin = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.formBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              title: const Text('Log In', style: TextStyle(color: Color.fromARGB(255, 16, 16, 16))),
              content: Form(
                key: _loginFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Utilisation du widget extrait CustomTextField
                    CustomTextField(
                       controller: _emailLoginController,
                       label: 'Email',
                       keyboardType: TextInputType.emailAddress,
                       validator: validateEmail, // Utilise validateur importé
                       textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: _passwordLoginController,
                      label: 'Password',
                      obscureText: true,
                      validator: (v) => validatePassword(v, checkLength: false), // Utilise validateur importé
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 15),
                    // Affichage de l'erreur de connexion
                    if (_errorMessageLogin != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          _errorMessageLogin!,
                          style: const TextStyle(color: AppColors.errorRed, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                // Bouton Annuler (utilise le style du thème TextButton)
                TextButton(
                  onPressed: _isLoadingLogin ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                // Bouton Connexion (utilise le style du thème ElevatedButton)
                ElevatedButton(
                  onPressed: _isLoadingLogin ? null : () {
                      _handleLogin(dialogContext, setDialogState);
                  },
                  // Style spécifique pour le texte noir sur fond rouge
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                     foregroundColor: MaterialStateProperty.all(Colors.black),
                     backgroundColor: MaterialStateProperty.all(AppColors.primaryRed),
                  ),
                  child: _isLoadingLogin
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('Login'),
                ),
              ],
            );
          }
        );
      },
    );
  }


  // --- Fonctions Helper pour SnackBar ---
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.errorRed),
    );
  }

  void _showSuccessSnackBar(String message) {
     if (!mounted) return;
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(message), backgroundColor: AppColors.successGreen),
     );
  }

  // --- Méthode Build Principale ---
  @override
  Widget build(BuildContext context) {
    // Affiche l'UI appropriée en fonction de l'état de connexion
    return _isLoggedIn ? _buildLoggedInUI() : _buildRegisterUI();
  }


  // --- Construction de l'UI pour l'état "Déconnecté" (Inscription/Accueil) ---
  Widget _buildRegisterUI() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Les breakpoints pourraient venir de app_constants.dart
    const double mobileBreakpoint = 600;
    const double tabletBreakpoint = 1000;
    double formWidth;
    if (screenWidth < mobileBreakpoint) { formWidth = screenWidth * 0.9; }
    else if (screenWidth < tabletBreakpoint) { formWidth = 500; }
    else { formWidth = screenWidth * 0.4; }
    formWidth = formWidth.clamp(300, 600);

    return Scaffold(
      body: Stack(
        children: [
          // Couche 1: Fond
          BackgroundLayer(
            // Ne passe plus lightTextColor car BackgroundLayer utilise AppColors
            screenWidth: screenWidth,
            mobileBreakpoint: mobileBreakpoint,
          ),

          // Couche 2: Panneau d'inscription coulissant
          SlidingFormPanel(
            // Passe tous les états, contrôleurs, callbacks nécessaires
            isVisible: _isRegisterFormVisible,
            slideDuration: _slideDuration,
            formWidth: formWidth,
            formKey: _registerFormKey,
            firstNameController: _firstNameController,
            emailController: _emailRegisterController,
            phoneNumberController: _phoneNumberController,
            passwordController: _passwordRegisterController,
            selectedUserType: _selectedUserType,
            selectedCompanyLocation: _selectedCompanyLocation,
            selectedIndustry: _selectedIndustry,
            acceptedPrivacyPolicy: _acceptedPrivacyPolicy,
            isLoading: _isLoadingRegister,
            errorMessage: _errorMessageRegister, // Passe l'erreur spécifique à l'inscription
            companyLocations: _companyLocations,
            industries: _industries,
            onUserTypeChanged: (value) => setState(() => _selectedUserType = value),
            onCompanyLocationChanged: (value) => setState(() => _selectedCompanyLocation = value),
            onIndustryChanged: (value) => setState(() => _selectedIndustry = value),
            onPrivacyPolicyChanged: (value) => setState(() => _acceptedPrivacyPolicy = value ?? false),
            onRegister: _register,
            onClose: () => setState(() => _isRegisterFormVisible = false),
            onLoginLinkTap: _showLoginDialog, // Passe la fonction pour ouvrir le dialogue
            // Ne passe plus les validateurs ou les couleurs globales
          ),

          // Couche 3: Boutons en haut à droite (si formulaire d'inscription caché)
          if (!_isRegisterFormVisible)
            Positioned(
              top: 20,
              right: 25,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton Log In (utilise le thème TextButton, peut être stylisé plus)
                  TextButton(
                    onPressed: _showLoginDialog,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, // Garde blanc pour contraste sur fond
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter', fontSize: 14),
                      backgroundColor: Colors.black.withOpacity(0.2), // Fond léger pour visibilité
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Log In'),
                  ),
                  const SizedBox(width: 15),
                  // Bouton Create Account (utilise le thème ElevatedButton)
                  ElevatedButton(
                    onPressed: () => setState(() => _isRegisterFormVisible = true),
                    // Le style vient du thème global, on peut surcharger si besoin
                    // style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
                    child: const Text('Create Account'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }


  // --- Construction de l'UI pour l'état "Connecté" ---
  Widget _buildLoggedInUI() {
     final screenWidth = MediaQuery.of(context).size.width;
     const double mobileBreakpoint = 600; // Pourrait être dans app_constants.dart

    return Scaffold(
      body: Stack(
        children: [
          // Fond
          Container(
             width: double.infinity,
             height: double.infinity,
             decoration: const BoxDecoration(
               image: DecorationImage(
                 image: AssetImage('assets/images/background.jpg'),
                 fit: BoxFit.cover,
               ),
             ),
          ),
          // Contenu
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < mobileBreakpoint ? 20.0 : 50.0,
              vertical: 40.0
            ),
            child: Stack(
              children: [
                // Logo
                Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 50,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.white, size: 50),
                  ),
                ),
                // Bouton Log Off
                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    onPressed: _handleLogout,
                    // Style hérité du thème, mais on peut forcer la couleur ici
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed.withOpacity(0.9),
                      foregroundColor: Colors.white, // Texte blanc sur fond rouge
                    ),
                    child: const Text('Log Off'),
                  ),
                ),
                // Message Bienvenue
                 Center(
                   child: Text(
                     'Welcome, ${_loggedInUserFirstName ?? 'User'}!',
                     style: TextStyle(
                       fontSize: 40,
                       color: Colors.white.withOpacity(0.9),
                       fontWeight: FontWeight.bold,
                       fontFamily: 'Inter' // Assure que la police est appliquée
                      ),
                      textAlign: TextAlign.center,
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

} // Fin de la classe _RegisterScreenState
