import 'package:flutter/material.dart'; // Importe le package de base pour Flutter (widgets, thèmes, etc.)

// --- Importations de fichiers locaux ---
// Ces importations organisent le code en séparant les responsabilités.
import '../../config/app_colors.dart'; // Importe les couleurs définies pour l'application (pour une apparence cohérente).
import '../../services/auth_service.dart'; // Importe le service qui gère l'authentification (inscription, connexion).
import '../../utils/validators.dart'; // Importe des fonctions pour valider les entrées utilisateur (email, mot de passe).
import 'widgets/background_layer.dart'; // Importe un widget personnalisé pour l'arrière-plan de l'écran.
import 'widgets/sliding_form_panel.dart'; // Importe un widget personnalisé pour le panneau de formulaire coulissant.
import 'widgets/form_elements/custom_text_field.dart'; // Importe un champ de texte personnalisé réutilisable.

// --- Widget Principal de l'Écran ---
// Un StatefulWidget est utilisé car l'interface utilisateur de cet écran doit changer
// en fonction des interactions de l'utilisateur (par exemple, afficher/masquer le formulaire,
// état de connexion, messages d'erreur).
class RegisterScreen extends StatefulWidget {
  // Le constructeur constant améliore les performances.
  const RegisterScreen({super.key}); // `super.key` transmet la clé au widget parent.

  // Crée l'objet State associé à ce StatefulWidget. C'est là que la logique et l'état résident.
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// --- Classe d'État pour RegisterScreen ---
// Contient l'état mutable (variables qui changent) et la logique de l'écran.
class _RegisterScreenState extends State<RegisterScreen> {
  // --- Clés Globales (GlobalKey) ---
  // Utilisées pour identifier et interagir avec les widgets Form (validation, réinitialisation).
  final _registerFormKey = GlobalKey<FormState>(); // Clé pour le formulaire d'inscription.
  final _loginFormKey = GlobalKey<FormState>();    // Clé pour le formulaire de connexion (dans le dialogue).

  // --- Service d'Authentification ---
  // Instance du service qui communique avec le backend (ou la logique métier) pour l'authentification.
  final AuthService _authService = AuthService();

  // --- États de l'Interface Utilisateur (UI) ---
  // Variables booléennes pour contrôler l'affichage conditionnel des éléments UI.
  bool _isRegisterFormVisible = false; // Contrôle la visibilité du panneau d'inscription.
  bool _isLoggedIn = false;           // Indique si l'utilisateur est connecté.
  String? _loggedInUserFirstName;     // Stocke le prénom de l'utilisateur connecté (si disponible).
  // Constante pour la durée de l'animation du panneau coulissant.
  static const Duration _slideDuration = Duration(milliseconds: 350);

  // --- Contrôleurs de Texte (TextEditingController) ---
  // Gèrent le texte entré dans les champs de texte (TextField).
  // Ils permettent de lire, écrire et écouter les changements de texte.

  // Contrôleurs pour le formulaire d'inscription :
  final _firstNameController = TextEditingController();
  final _emailRegisterController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordRegisterController = TextEditingController();

  // Contrôleurs pour le formulaire de connexion (dialogue) :
  final _emailLoginController = TextEditingController();
  final _passwordLoginController = TextEditingController();

  // --- Variables d'État du Formulaire d'Inscription ---
  // Stockent les sélections de l'utilisateur dans le formulaire.
  String _selectedUserType = 'merchant'; // Type d'utilisateur par défaut.
  String? _selectedCompanyLocation;     // Localisation de l'entreprise (nullable).
  String? _selectedIndustry;           // Secteur d'activité (nullable).
  bool _acceptedPrivacyPolicy = false; // État de la case à cocher de la politique de confidentialité.

  // --- États de Chargement et Messages d'Erreur ---
  // Utilisés pour afficher des indicateurs de chargement et des retours d'erreur.
  bool _isLoadingRegister = false;      // Indique si une opération d'inscription est en cours.
  String? _errorMessageRegister;       // Stocke le message d'erreur pour l'inscription.
  bool _isLoadingLogin = false;         // Indique si une opération de connexion est en cours.
  String? _errorMessageLogin;          // Stocke le message d'erreur pour la connexion (dans le dialogue).

  // --- Données pour les Menus Déroulants (Dropdown) ---
  // Listes statiques pour les options des menus déroulants.
  // Pourraient aussi venir d'une configuration ou d'une API dans une vraie application.
  final List<String> _companyLocations = ['United States', 'Canada', 'France', 'Germany', 'United Kingdom', 'Belgium', 'Other'];
  final List<String> _industries = ['Technology', 'Finance', 'Healthcare', 'Retail', 'Education', 'Other'];

  // --- Méthode dispose() ---
  // Appelée lorsque le widget State est retiré de l'arbre des widgets.
  // Essentiel pour libérer les ressources détenues par les contrôleurs afin d'éviter les fuites de mémoire.
  @override
  void dispose() {
    _firstNameController.dispose();
    _emailRegisterController.dispose();
    _phoneNumberController.dispose();
    _passwordRegisterController.dispose();
    _emailLoginController.dispose();
    _passwordLoginController.dispose();
    super.dispose(); // Appel important à la méthode dispose de la classe parente.
  }

  // --- Logique d'Inscription ---
  // Fonction asynchrone pour gérer le processus d'inscription.
  Future<void> _register() async {
    // Réinitialise le message d'erreur précédent.
    setState(() { _errorMessageRegister = null; });

    // 1. Valide le formulaire d'inscription en utilisant sa GlobalKey.
    //    Si la validation échoue (champs manquants ou invalides), affiche une erreur et arrête.
    if (!_registerFormKey.currentState!.validate()) {
      _showErrorSnackBar('Please fix the errors in the form'); // Affiche un message d'erreur temporaire en bas.
      return; // Sort de la fonction.
    }

    // 2. Active l'indicateur de chargement et met à jour l'UI.
    setState(() { _isLoadingRegister = true; });

    // 3. Prépare les données utilisateur à partir des contrôleurs et des états.
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

    // 4. Appelle la méthode d'inscription du service d'authentification.
    //    `await` attend que l'opération asynchrone (probablement un appel réseau) se termine.
    final result = await _authService.registerUser(userData);

    // 5. Vérifie si le widget est toujours monté (visible à l'écran) avant de mettre à jour l'état.
    //    Ceci évite les erreurs si l'utilisateur quitte l'écran pendant l'opération.
    if (mounted) {
      // Désactive l'indicateur de chargement.
      setState(() { _isLoadingRegister = false; });

      // 6. Traite le résultat de l'inscription.
      if (result['success'] == true) {
        // Succès : Réinitialise le formulaire, masque le panneau, et affiche un message de succès.
        setState(() {
          _registerFormKey.currentState?.reset(); // Réinitialise l'état de validation du formulaire.
          // Efface les contrôleurs et réinitialise les sélections.
          _firstNameController.clear(); _emailRegisterController.clear(); _phoneNumberController.clear(); _passwordRegisterController.clear();
          _selectedCompanyLocation = null; _selectedIndustry = null;
          _acceptedPrivacyPolicy = false; _selectedUserType = 'merchant';
          _isRegisterFormVisible = false; // Masque le panneau d'inscription.
        });
        _showSuccessSnackBar(result['message'] ?? 'Registration successful!'); // Affiche un message de succès.
      } else {
        // Échec : Affiche le message d'erreur renvoyé par le service.
        setState(() { _errorMessageRegister = result['message'] ?? 'Registration failed.'; });
        // Optionnel : on pourrait aussi afficher l'erreur dans un SnackBar.
        // _showErrorSnackBar(result['message']);
      }
    }
  }

  // --- Logique de Connexion ---
  // Gère la connexion de l'utilisateur via la boîte de dialogue.
  // `dialogContext` est le contexte de la boîte de dialogue.
  // `setDialogState` est une fonction pour mettre à jour l'état *spécifiquement* dans le dialogue (pour l'erreur et le chargement).
  Future<void> _handleLogin(BuildContext dialogContext, StateSetter setDialogState) async {
    // Réinitialise l'erreur de connexion dans le dialogue.
    setDialogState(() { _errorMessageLogin = null; });

    // 1. Valide le formulaire de connexion.
    if (!_loginFormKey.currentState!.validate()) {
       return; // Arrête si invalide.
    }

    // 2. Active l'indicateur de chargement DANS le dialogue.
    setDialogState(() { _isLoadingLogin = true; });

    // 3. Récupère l'email et le mot de passe.
    final email = _emailLoginController.text;
    final password = _passwordLoginController.text;

    // 4. Appelle la méthode de connexion du service d'authentification.
    final result = await _authService.loginUser(email, password);

    // 5. Vérifie si l'écran principal est toujours monté avant de continuer.
    if (!mounted) return;

    // 6. Traite le résultat.
    if (result['success'] == true) {
        // Succès : Récupère le prénom, ferme le dialogue, met à jour l'état principal.
        final String firstName = result['data']?['firstName'] ?? 'User'; // Utilise 'User' si le prénom n'est pas fourni.
        Navigator.pop(dialogContext); // Ferme la boîte de dialogue.
        setState(() { // Met à jour l'état de l'écran principal (_RegisterScreenState).
          _isLoggedIn = true;
          _loggedInUserFirstName = firstName;
          // Efface les champs de connexion après succès.
          _emailLoginController.clear();
          _passwordLoginController.clear();
        });
    } else {
        // Échec : Met à jour le message d'erreur et arrête le chargement DANS le dialogue.
        setDialogState(() {
          _errorMessageLogin = result['message'] ?? 'Login failed.';
          _isLoadingLogin = false; // Important : arrête le chargement du dialogue.
        });
    }
  }


  // --- Logique de Déconnexion ---
  // Réinitialise l'état de connexion et efface les informations utilisateur.
  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _loggedInUserFirstName = null;
      // Efface les champs de connexion (au cas où le dialogue serait rouvert).
      _emailLoginController.clear();
      _passwordLoginController.clear();
    });
  }

  // --- Affichage de la Boîte de Dialogue de Connexion ---
  // Construit et affiche un AlertDialog pour la connexion.
  void _showLoginDialog() {
    // Réinitialise l'état du dialogue avant de l'afficher.
    _errorMessageLogin = null;
    _isLoadingLogin = false;

    showDialog(
      context: context, // Utilise le contexte de l'écran principal.
      barrierDismissible: false, // Empêche la fermeture en cliquant en dehors du dialogue.
      builder: (BuildContext dialogContext) { // `dialogContext` est spécifique à ce dialogue.
        // Utilise StatefulBuilder pour permettre la mise à jour de l'état (erreur, chargement)
        // *à l'intérieur* du dialogue sans reconstruire tout l'écran.
        return StatefulBuilder(
          builder: (context, setDialogState) { // `setDialogState` met à jour l'état du dialogue.
            return AlertDialog(
              backgroundColor: AppColors.formBackground, // Couleur de fond personnalisée.
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), // Bords arrondis.
              title: const Text('Log In', style: TextStyle(color: Color.fromARGB(255, 16, 16, 16))), // Titre.
              content: Form( // Le dialogue contient son propre formulaire.
                key: _loginFormKey, // Utilise la clé dédiée au formulaire de connexion.
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Prend la hauteur minimale nécessaire.
                  children: <Widget>[
                    // Utilise le widget de champ de texte personnalisé.
                    CustomTextField(
                       controller: _emailLoginController, // Lie le contrôleur.
                       label: 'Email',
                       keyboardType: TextInputType.emailAddress, // Type de clavier optimisé.
                       validator: validateEmail, // Fonction de validation importée.
                       textInputAction: TextInputAction.next, // Action du bouton "Entrée" (passe au champ suivant).
                    ),
                    const SizedBox(height: 15), // Espace vertical.
                    CustomTextField(
                      controller: _passwordLoginController,
                      label: 'Password',
                      obscureText: true, // Masque le texte du mot de passe.
                      // Validation simple (présence), la longueur est gérée par le backend normalement.
                      validator: (v) => validatePassword(v, checkLength: false),
                      textInputAction: TextInputAction.done, // Action "Terminé".
                    ),
                    const SizedBox(height: 15),
                    // Affiche conditionnellement le message d'erreur de connexion.
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
              actions: <Widget>[ // Boutons en bas du dialogue.
                // Bouton Annuler : Ferme le dialogue. Désactivé si chargement en cours.
                TextButton(
                  onPressed: _isLoadingLogin ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'), // Utilise le style par défaut du thème.
                ),
                // Bouton Connexion : Appelle _handleLogin. Désactivé si chargement en cours.
                ElevatedButton(
                  onPressed: _isLoadingLogin ? null : () {
                      // Appelle la logique de connexion en passant le contexte et setDialogState.
                      _handleLogin(dialogContext, setDialogState);
                  },
                  // Style personnalisé pour correspondre au thème de l'application.
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                     foregroundColor: MaterialStateProperty.all(Colors.black), // Texte noir.
                     backgroundColor: MaterialStateProperty.all(AppColors.primaryRed), // Fond rouge.
                  ),
                  // Affiche un indicateur de chargement ou le texte "Login".
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


  // --- Fonctions d'Aide pour SnackBar ---
  // Affichent des messages temporaires en bas de l'écran (feedback utilisateur).

  // Affiche un message d'erreur (fond rouge).
  void _showErrorSnackBar(String message) {
    if (!mounted) return; // Vérifie si le widget est toujours à l'écran.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.errorRed),
    );
  }

  // Affiche un message de succès (fond vert).
  void _showSuccessSnackBar(String message) {
     if (!mounted) return;
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(message), backgroundColor: AppColors.successGreen),
     );
  }

  // --- Méthode build() Principale ---
  // Responsable de la construction de l'interface utilisateur du widget.
  // Appelée initialement et à chaque fois que setState() est appelé.
  @override
  Widget build(BuildContext context) {
    // Construit conditionnellement l'UI en fonction de l'état de connexion.
    // Si l'utilisateur est connecté, affiche l'écran de bienvenue (_buildLoggedInUI).
    // Sinon, affiche l'écran d'inscription/accueil (_buildRegisterUI).
    return _isLoggedIn ? _buildLoggedInUI() : _buildRegisterUI();
  }


  // --- Construction de l'UI pour l'état "Déconnecté" (Inscription/Accueil) ---
  // Construit l'interface principale avec le fond et le panneau d'inscription potentiel.
  Widget _buildRegisterUI() {
    // Récupère la largeur de l'écran pour l'adapter (responsive design).
    final screenWidth = MediaQuery.of(context).size.width;
    // Définition des points de rupture pour adapter la largeur du formulaire.
    // Pourraient être centralisés dans un fichier de constantes.
    const double mobileBreakpoint = 600;
    const double tabletBreakpoint = 1000;
    double formWidth; // Largeur calculée du formulaire.

    // Adapte la largeur du formulaire en fonction de la largeur de l'écran.
    if (screenWidth < mobileBreakpoint) { formWidth = screenWidth * 0.9; } // Petit écran (mobile)
    else if (screenWidth < tabletBreakpoint) { formWidth = 500; }         // Écran moyen (tablette)
    else { formWidth = screenWidth * 0.4; }                               // Grand écran (desktop)

    // Limite la largeur du formulaire entre 300 et 600 pixels.
    formWidth = formWidth.clamp(300, 600);

    return Scaffold( // Widget de structure de base pour Material Design.
      body: Stack( // Permet de superposer des widgets les uns sur les autres.
        children: [
          // Couche 1: Arrière-plan personnalisé.
          BackgroundLayer(
            screenWidth: screenWidth,
            mobileBreakpoint: mobileBreakpoint,
            // Les couleurs sont maintenant gérées directement dans BackgroundLayer via AppColors.
          ),

          // Couche 2: Panneau de formulaire coulissant (widget personnalisé).
          SlidingFormPanel(
            // Passe toutes les dépendances nécessaires : état, contrôleurs, callbacks.
            isVisible: _isRegisterFormVisible, // Contrôle l'affichage.
            slideDuration: _slideDuration,    // Durée de l'animation.
            formWidth: formWidth,             // Largeur calculée.
            formKey: _registerFormKey,       // Clé du formulaire.
            // Contrôleurs de texte :
            firstNameController: _firstNameController,
            emailController: _emailRegisterController,
            phoneNumberController: _phoneNumberController,
            passwordController: _passwordRegisterController,
            // États du formulaire :
            selectedUserType: _selectedUserType,
            selectedCompanyLocation: _selectedCompanyLocation,
            selectedIndustry: _selectedIndustry,
            acceptedPrivacyPolicy: _acceptedPrivacyPolicy,
            // État de chargement et message d'erreur :
            isLoading: _isLoadingRegister,
            errorMessage: _errorMessageRegister,
            // Données pour les menus déroulants :
            companyLocations: _companyLocations,
            industries: _industries,
            // Callbacks (fonctions appelées par le panneau) :
            onUserTypeChanged: (value) => setState(() => _selectedUserType = value), // Met à jour l'état local.
            onCompanyLocationChanged: (value) => setState(() => _selectedCompanyLocation = value),
            onIndustryChanged: (value) => setState(() => _selectedIndustry = value),
            onPrivacyPolicyChanged: (value) => setState(() => _acceptedPrivacyPolicy = value ?? false),
            onRegister: _register, // Appelle la fonction d'inscription définie plus haut.
            onClose: () => setState(() => _isRegisterFormVisible = false), // Masque le panneau.
            onLoginLinkTap: _showLoginDialog, // Ouvre le dialogue de connexion.
          ),

          // Couche 3: Boutons "Log In" et "Create Account" en haut à droite.
          // S'affiche seulement si le panneau d'inscription n'est PAS visible.
          if (!_isRegisterFormVisible)
            Positioned( // Positionne les boutons précisément dans le Stack.
              top: 20,
              right: 25,
              child: Row( // Dispose les boutons horizontalement.
                mainAxisSize: MainAxisSize.min, // Prend la largeur minimale nécessaire.
                children: [
                  // Bouton "Log In" (style TextButton pour moins d'emphase).
                  TextButton(
                    onPressed: _showLoginDialog, // Ouvre le dialogue de connexion.
                    // Style personnalisé pour une meilleure visibilité sur le fond.
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, // Texte blanc.
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter', fontSize: 14),
                      backgroundColor: Colors.black.withOpacity(0.2), // Léger fond sombre.
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Bords arrondis.
                    ),
                    child: const Text('Log In'),
                  ),
                  const SizedBox(width: 15), // Espace entre les boutons.
                  // Bouton "Create Account" (style ElevatedButton, plus proéminent).
                  ElevatedButton(
                    onPressed: () => setState(() => _isRegisterFormVisible = true), // Affiche le panneau d'inscription.
                    // Le style principal vient du thème global (main.dart),
                    // mais pourrait être surchargé ici si nécessaire.
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
  // Affiche un écran simple de bienvenue après une connexion réussie.
  Widget _buildLoggedInUI() {
     // Récupère la largeur pour un padding adaptatif potentiel.
     final screenWidth = MediaQuery.of(context).size.width;
     const double mobileBreakpoint = 600; // Point de rupture pour mobile.

    return Scaffold(
      body: Stack( // Utilise un Stack pour superposer facilement les éléments sur le fond.
        children: [
          // 1. Arrière-plan (Image)
          Container(
             width: double.infinity, // Prend toute la largeur.
             height: double.infinity, // Prend toute la hauteur.
             decoration: const BoxDecoration(
               image: DecorationImage(
                 image: AssetImage('assets/images/background.jpg'), // Charge l'image de fond.
                 fit: BoxFit.cover, // Redimensionne l'image pour couvrir tout l'espace.
               ),
             ),
          ),
          // 2. Contenu superposé (Logo, Bouton Log Off, Message)
          Padding( // Ajoute de l'espace autour du contenu.
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < mobileBreakpoint ? 20.0 : 50.0, // Padding horizontal adaptatif.
              vertical: 40.0
            ),
            child: Stack( // Un autre Stack pour positionner les éléments de contenu.
              children: [
                // Logo en haut à gauche.
                Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/images/logo.png', // Charge l'image du logo.
                    height: 50, // Hauteur fixe pour le logo.
                    // errorBuilder: affiche une icône si le logo ne peut pas être chargé.
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.white, size: 50),
                  ),
                ),
                // Bouton "Log Off" en haut à droite.
                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    onPressed: _handleLogout, // Appelle la fonction de déconnexion.
                    // Style pour assurer la visibilité sur le fond.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed.withOpacity(0.9), // Fond rouge semi-transparent.
                      foregroundColor: Colors.white, // Texte blanc.
                    ),
                    child: const Text('Log Off'),
                  ),
                ),
                // Message de bienvenue centré.
                 Center(
                   child: Text(
                     // Affiche "Welcome, [Prénom]!" ou "Welcome, User!" si le prénom n'est pas disponible.
                     'Welcome, ${_loggedInUserFirstName ?? 'User'}!',
                     style: TextStyle(
                       fontSize: 40, // Grande taille de police.
                       color: Colors.white.withOpacity(0.9), // Texte blanc légèrement transparent.
                       fontWeight: FontWeight.bold, // Texte en gras.
                       fontFamily: 'Inter' // Utilise la police Inter (doit être définie dans pubspec.yaml).
                      ),
                      textAlign: TextAlign.center, // Centre le texte si plusieurs lignes.
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