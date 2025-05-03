import 'package:flutter/gestures.dart'; // Required for TapGestureRecognizer
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode and jsonDecode

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- State Variables ---
  final _formKey = GlobalKey<FormState>();

  // --- Class-Level Color Constants ---
  // Définition des couleurs utilisées dans l'UI
  static const Color darkBackgroundColor = Color.fromRGBO(25, 25, 25, 0.98); // Couleur de fond sombre (non utilisée directement si image de fond)
  static const Color formBackgroundColor = Colors.white; // Couleur de fond du formulaire
  static const Color primaryRedColor = Color.fromARGB(255, 255, 0, 0); // Couleur red principale
  static const Color greyTextColor = Colors.grey; // Couleur de texte grise
  static const Color darkTextColor = Color(0xFF333333); // Couleur de texte foncée (pour le formulaire)
  static const Color lightTextColor = Colors.white70; // Couleur de texte claire (pour le fond)
  static const Color toggleButtonBg = Color(0xFFF0F0F0); // Couleur de fond du sélecteur de type

  // --- Animation and Visibility State ---
  bool _isFormVisible = true; // Le formulaire est visible au démarrage
  static const Duration _slideDuration = Duration(milliseconds: 350); // Durée de l'animation du panneau

  // --- Controllers and Form State Variables ---
  // Contrôleurs pour récupérer le texte des champs
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variables pour l'état du formulaire
  String _selectedUserType = 'merchant'; // Type d'utilisateur par défaut
  String? _selectedCompanyLocation; // Lieu de l'entreprise (nullable)
  String? _selectedIndustry; // Secteur d'activité (nullable)
  bool _acceptedPrivacyPolicy = false; // Case à cocher politique de confidentialité

  // Variables pour l'état de chargement et les messages d'erreur
  bool _isLoading = false;
  String? _errorMessage;

  // Données exemples pour les menus déroulants (à remplacer par vos données réelles)
  final List<String> _companyLocations = ['United States', 'Canada', 'France', 'Germany', 'United Kingdom', 'Belgium', 'Other'];
  final List<String> _industries = ['Technology', 'Finance', 'Healthcare', 'Retail', 'Education', 'Other'];

  // --- Dispose Controllers ---
  // Libère les ressources des contrôleurs quand le widget est supprimé
  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Validation Logic ---
  // Fonctions pour valider les champs du formulaire
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis'; // Message d'erreur si le champ est vide
    }
    return null; // Pas d'erreur
  }
  String? _validateDropdown(String? value, String fieldName) {
    if (value == null) {
      return 'Veuillez sélectionner $fieldName'; // Message si aucune option n'est choisie
    }
    return null; // Pas d'erreur
  }
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est requis';
    }
    // Expression régulière simple pour vérifier le format de l'email
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un format d\'email valide';
    }
    return null; // Pas d'erreur
  }
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null; // Pas d'erreur
  }

  // --- Registration Logic (_register) ---
  // Fonction appelée lors de la soumission du formulaire
  Future<void> _register() async {
    setState(() { _errorMessage = null; }); // Réinitialise le message d'erreur

    // Vérifie si le formulaire est valide
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; }); // Active l'indicateur de chargement

      // Récupère les données du formulaire
      final dataToSend = {
        'userType': _selectedUserType,
        'firstName': _firstNameController.text,
        'companyLocation': _selectedCompanyLocation,
        'email': _emailController.text, // Utilise la bonne clé 'email'
        'industry': _selectedIndustry,
        'phoneNumber': _phoneNumberController.text,
        'password': _passwordController.text,
        'acceptedPrivacyPolicy': _acceptedPrivacyPolicy,
      };

      // --> IMPORTANT : Remplacez par l'URL réelle de votre backend <--
      const String apiUrl = 'http://localhost:3000/api/auth/register';

      try {
        // Envoie les données au backend via une requête POST HTTP
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json; charset=UTF-8'}, // Spécifie le type de contenu
          body: jsonEncode(dataToSend), // Encode les données en JSON
        );

        // Tente de décoder la réponse JSON
        dynamic responseBody;
        try {
          responseBody = jsonDecode(response.body);
        } catch (e) {
          // Gère les erreurs si la réponse n'est pas du JSON valide
          print("Erreur de décodage JSON : $e | Réponse : ${response.body}");
          responseBody = {'message': 'Réponse invalide du serveur (Statut : ${response.statusCode})'};
        }

        // Vérifie le code de statut de la réponse
        if (response.statusCode == 201) { // 201 Created = Succès
          final successMsg = responseBody['message'] ?? 'Inscription réussie !';
          setState(() {
            _isLoading = false; // Désactive le chargement
            // Réinitialise les champs et l'état du formulaire
            _formKey.currentState?.reset();
            _firstNameController.clear();
            _emailController.clear();
            _phoneNumberController.clear();
            _passwordController.clear();
            _selectedCompanyLocation = null;
            _selectedIndustry = null;
            _acceptedPrivacyPolicy = false;
            _selectedUserType = 'merchant';
            // Optionnel : Fermer le panneau après succès
            // _isFormVisible = false;
          });

          // Affiche un message de succès (SnackBar)
          if (mounted) { // Vérifie si le widget est toujours monté
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(successMsg), backgroundColor: Colors.green, duration: const Duration(seconds: 3)),
            );
          }
        } else { // Gère les erreurs du backend (4xx, 5xx)
          setState(() {
            _errorMessage = responseBody['message'] ?? 'Une erreur est survenue : Statut ${response.statusCode}';
            _isLoading = false; // Désactive le chargement
          });
        }
      } catch (e) { // Gère les erreurs réseau (pas de connexion, etc.)
        print('Erreur d\'inscription : $e');
        if (mounted) {
          setState(() {
            _errorMessage = 'Impossible de se connecter au serveur. Veuillez réessayer.';
            _isLoading = false; // Désactive le chargement
          });
        }
      }
    } else { // La validation du formulaire a échoué
      if (mounted) {
        // Affiche un message indiquant de corriger les erreurs
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez corriger les erreurs dans le formulaire'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Build Method (UI Structure with Animation) ---
  // Construit l'interface utilisateur de l'écran
  @override
  Widget build(BuildContext context) {
    // Récupère la largeur de l'écran pour le dimensionnement adaptatif
    final screenWidth = MediaQuery.of(context).size.width;
    // Définit la largeur du panneau de formulaire (40% de la largeur de l'écran)
    final formWidth = screenWidth * 0.4;

    return Scaffold(
      // backgroundColor: darkBackgroundColor, // Le fond est maintenant géré par le Container avec l'image
      body: Stack( // Utilise un Stack pour superposer les éléments (fond, formulaire, bouton)
        children: [
          // --- Couche 1 : Fond avec Image (Toujours visible) ---
          Container(
            width: double.infinity, // Prend toute la largeur
            height: double.infinity, // Prend toute la hauteur
            decoration: const BoxDecoration( // Utilise 'decoration' pour l'image de fond
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'), // Chemin vers votre image de fond
                fit: BoxFit.cover, // Assure que l'image couvre tout le conteneur (responsive)
              ),
            ),
            // Padding pour le contenu affiché par-dessus l'image de fond
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 40.0), // Padding général
              child: Column( // Colonne principale pour le contenu du fond
                crossAxisAlignment: CrossAxisAlignment.start, // Aligne le logo à gauche
                children: [
                  // --- Logo ---
                  Image.asset(
                    'assets/images/logo.png', // Chemin vers votre logo
                    height: 50,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.white, size: 35), // Icône de secours
                  ),
                  const SizedBox(height: 80), // Espace après le logo

                  // --- Spacer pour pousser la section Titre/Boîtes vers le centre vertical ---
                  const Spacer(flex: 1), // Moins d'espace en haut

                  // --- Section contenant le Titre, Sous-titre et les Boîtes d'information ---
                  // Centre horizontalement toute cette section
                  Center(
                    child: Column( // Utilise une Colonne pour empiler Titre, Sous-titre et Rangée
                      mainAxisSize: MainAxisSize.min, // La Colonne prend la hauteur minimale nécessaire
                      crossAxisAlignment: CrossAxisAlignment.start, // Aligne Titre, Sous-titre et Rangée au DÉBUT (gauche)
                      children: [
                        // --- Titre ---
                        const Text(
                          'Manage your Money\nAnywhere',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Assurez-vous que le texte est lisible sur le fond
                            height: 1.3,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 15), // Espace après le titre

                        // --- Sous-titre ---
                        const Text(
                          'View all the analytics and grow your business\nfrom anywhere!',
                          style: TextStyle(
                            fontSize: 16,
                            color: lightTextColor, // Utilise la constante de couleur claire
                            height: 1.5, // Interligne
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 30), // Espace après le sous-titre

                        // --- Rangée de Boîtes d'information ---
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly, // On peut commenter ou changer si on utilise des SizedBox
                          mainAxisSize: MainAxisSize.min, // La Rangée prend la largeur minimale nécessaire
                          children: [
                            _buildInfoBox( // Première boîte
                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                            ),
                            // <<< CHANGEMENT ICI : Ajout d'espace horizontal >>>
                            const SizedBox(width: 20), // Espace entre la 1ère et la 2ème boîte
                            _buildInfoBox( // Deuxième boîte
                              "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                            ),
                            // <<< CHANGEMENT ICI : Ajout d'espace horizontal >>>
                            const SizedBox(width: 20), // Espace entre la 2ème et la 3ème boîte
                            _buildInfoBox( // Troisième boîte
                              "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
                            ),
                          ],
                        ),
                      ], // Fin des enfants de la Colonne interne (Titre + Sous-titre + Rangée)
                    ), // Fin de la Colonne interne
                  ), // Fin du Center pour la section Titre/Sous-titre/Boîtes

                  // --- Spacer pour pousser la section Titre/Boîtes vers le centre vertical ---
                  const Spacer(flex: 2), // Plus d'espace en bas

                ], // Fin des enfants de la Colonne principale du fond
              ), // Fin du Padding
            ), // Fin du Container de fond (avec image)
          ), // Fin de la Couche 1

          // --- Couche 2 : Panneau de Formulaire Coulissant ---
          AnimatedPositioned( // Widget pour animer la position
            duration: _slideDuration, // Durée de l'animation
            curve: Curves.easeInOut, // Courbe d'animation (accélération/décélération douce)
            top: 0, // Collé en haut
            bottom: 0, // Collé en bas
            width: formWidth, // Largeur définie précédemment
            // Anime la propriété 'right' en fonction de l'état de visibilité
            right: _isFormVisible ? 0 : -formWidth, // 0 = visible, -formWidth = caché à droite

            child: Container( // Le panneau lui-même
              decoration: BoxDecoration( // Style du panneau
                color: formBackgroundColor, // Fond blanc
                borderRadius: const BorderRadius.only( // Coins arrondis à gauche
                  topLeft: Radius.circular(25.0),
                  bottomLeft: Radius.circular(25.0),
                ),
                boxShadow: [ // Ombre portée pour donner de la profondeur
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(-10, 0), // Ombre vers la gauche
                  ),
                ],
              ),
              // Utilise un Stack imbriqué pour positionner le bouton de fermeture par-dessus le formulaire
              child: Stack(
                children: [
                  // Le contenu du formulaire a besoin de padding, surtout en haut pour le bouton
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0), // Espace réservé pour le bouton de fermeture
                    child: SingleChildScrollView( // Permet de faire défiler si le contenu dépasse
                      padding: const EdgeInsets.fromLTRB(35.0, 20.0, 35.0, 40.0), // Padding interne du formulaire
                      child: Form( // Widget Form pour la validation
                        key: _formKey, // Clé pour identifier et contrôler le formulaire
                        child: Column( // Colonne pour organiser les champs verticalement
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Étire les éléments enfants horizontalement
                          mainAxisSize: MainAxisSize.min, // Prend la hauteur minimale
                          children: [
                            // --- Titre du Formulaire ---
                            const Text(
                              'Create an account',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: darkTextColor, fontFamily: 'Inter'),
                              textAlign: TextAlign.center, // Centre le titre
                            ),
                            const SizedBox(height: 35), // Espace

                            // --- Éléments du Formulaire (utilisant les fonctions helper) ---
                            _buildUserTypeToggle(), // Sélecteur Merchant/Agent
                            const SizedBox(height: 25),
                            _buildTextFormField(_firstNameController, 'First Name', validator: (v) => _validateRequired(v, 'First Name')), // Champ Prénom
                            const SizedBox(height: 18),
                            _buildDropdownFormField(hint: 'Where is your company based?', value: _selectedCompanyLocation, items: _companyLocations, onChanged: (v) => setState(() => _selectedCompanyLocation = v), validator: (v) => _validateDropdown(v, 'location')), // Menu déroulant Lieu
                            const SizedBox(height: 18),
                            _buildTextFormField(_emailController, 'Email', keyboardType: TextInputType.emailAddress, validator: _validateEmail), // Champ Email
                            const SizedBox(height: 18),
                            _buildDropdownFormField(hint: 'Please select an Industry', value: _selectedIndustry, items: _industries, onChanged: (v) => setState(() => _selectedIndustry = v), validator: (v) => _validateDropdown(v, 'industry')), // Menu déroulant Secteur
                            const SizedBox(height: 18),
                            _buildTextFormField(_phoneNumberController, 'Phone number', keyboardType: TextInputType.phone, validator: (v) => _validateRequired(v, 'Phone number')), // Champ Téléphone
                            const SizedBox(height: 18),
                            _buildTextFormField(_passwordController, 'Password', obscureText: true, validator: _validatePassword), // Champ Mot de passe
                            const SizedBox(height: 25),
                            _buildPrivacyPolicyCheckbox(), // Case à cocher Politique de confidentialité
                            const SizedBox(height: 25),

                            // --- Affichage du Message d'Erreur ---
                            // S'affiche seulement si _errorMessage n'est pas null
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            // --- Bouton de Soumission ---
                            ElevatedButton(
                              onPressed: _isLoading ? null : _register, // Désactivé si _isLoading est true
                              style: ElevatedButton.styleFrom( // Style du bouton
                                backgroundColor: primaryRedColor, // Fond rouge
                                foregroundColor: Colors.white, // Texte blanc
                                padding: const EdgeInsets.symmetric(vertical: 18), // Padding vertical
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Coins arrondis
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                elevation: 3, // Légère ombre
                              ),
                              child: _isLoading // Affiche un indicateur de chargement si _isLoading est true
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                : const Text('Create an Account'), // Sinon, affiche le texte
                            ),
                            const SizedBox(height: 30), // Espace

                            // --- Lien de Connexion ---
                            _buildLoginLink(greyTextColor, primaryRedColor), // Lien "Log in"
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- Bouton de Fermeture (Positionné dans le Stack du panneau) ---
                  Positioned(
                    top: 15, // Distance du haut
                    right: 15, // Distance de la droite
                    child: IconButton( // Bouton avec icône
                      icon: const Icon(Icons.close, color: greyTextColor), // Icône 'X'
                      iconSize: 28,
                      tooltip: 'Fermer le formulaire', // Texte d'aide au survol
                      onPressed: () {
                        // Met l'état de visibilité à false, déclenchant l'animation de sortie
                        setState(() { _isFormVisible = false; });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Couche 3 : Bouton "Create Account" (Visible quand le formulaire est caché) ---
          // Ce bouton apparaît en haut à droite quand le panneau est sorti
          if (!_isFormVisible) // Conditionnellement affiché
            Positioned(
              top: 20, // Espace depuis le haut
              right: 25, // Espace depuis la droite
              child: ElevatedButton( // Utilise ElevatedButton pour la cohérence
                onPressed: () {
                  // Remet _isFormVisible à true pour faire rentrer le panneau
                  setState(() {
                    _isFormVisible = true;
                  });
                },
                style: ElevatedButton.styleFrom( // Style similaire au bouton de soumission
                  backgroundColor: primaryRedColor, // Fond rouge
                  foregroundColor: Colors.white,      // Texte blanc
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Padding ajusté
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Coins arrondis
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  elevation: 3, // Légère ombre
                ),
                child: const Text('Create Account'),
              ),
            ),

        ], // Fin des enfants du Stack principal
      ), // Fin du Stack principal
    ); // Fin du Scaffold
  }


  // --- Helper Widgets ---
  // Fonctions pour construire des parties répétitives de l'UI (widgets)

  // Construit une boîte d'information (utilisée en bas à gauche)
  Widget _buildInfoBox(String text) {
    const infoTextStyle = TextStyle(
      color: Colors.white, // Texte blanc
      fontSize: 14,
      height: 1.6, // Interligne
      fontFamily: 'Inter',
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0), // Padding interne (vertical augmenté)
      constraints: const BoxConstraints(maxWidth: 350), // Largeur maximale
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35), // Fond noir semi-transparent
        borderRadius: BorderRadius.circular(15.0), // Coins arrondis
      ),
      child: Text(
        text,
        style: infoTextStyle,
        textAlign: TextAlign.center, // Centre le texte
      ),
    );
  }

  // Construit un champ de texte standard pour le formulaire
  Widget _buildTextFormField(TextEditingController controller, String label, {bool obscureText = false, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller, // Lie le contrôleur
      obscureText: obscureText, // Cache le texte si true (pour mot de passe)
      keyboardType: keyboardType, // Type de clavier (email, phone, etc.)
      validator: validator, // Fonction de validation
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: darkTextColor), // Style du texte saisi
      decoration: InputDecoration( // Style du champ
        hintText: label, // Texte indicatif (placeholder)
        hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey), // Style du hint
        filled: true, // Active le fond coloré
        fillColor: const Color(0xFFF9F9F9), // Couleur de fond légère
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none), // Bordure par défaut (aucune)
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none), // Bordure quand activé (aucune)
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryRedColor.withOpacity(0.5), width: 1.5)), // Bordure quand focus (rouge léger)
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0), // Padding interne du champ
      ),
      textInputAction: TextInputAction.next, // Action du bouton "Entrée" (passe au champ suivant)
    );
  }

  // Construit un menu déroulant pour le formulaire
  Widget _buildDropdownFormField({required String hint, required String? value, required List<String> items, required void Function(String?)? onChanged, required String? Function(String?)? validator}) {
    return DropdownButtonFormField<String>(
      value: value, // Valeur actuellement sélectionnée
      items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: darkTextColor)))).toList(), // Construit les options
      onChanged: onChanged, // Fonction appelée quand la sélection change
      validator: validator, // Fonction de validation
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: darkTextColor), // Style du texte sélectionné
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey), // Icône flèche vers le bas
      decoration: InputDecoration( // Style similaire aux champs de texte
        hintText: hint, hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey),
        filled: true, fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryRedColor.withOpacity(0.5), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
      ),
      isExpanded: true, // Permet au texte de l'option de prendre toute la largeur
    );
  }

  // Construit le sélecteur de type d'utilisateur (Merchant/Agent)
  Widget _buildUserTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4), // Petit padding autour des boutons
      decoration: BoxDecoration(color: toggleButtonBg, borderRadius: BorderRadius.circular(12.0)), // Fond gris clair, coins arrondis
      child: Row(children: [ // Met les boutons côte à côte
        _buildToggleButton('Merchant', 'merchant'), // Bouton Merchant
        const SizedBox(width: 4), // Petit espace entre les boutons
        _buildToggleButton('Agent', 'agent'), // Bouton Agent
      ]),
    );
  }

  // Construit un bouton individuel pour le sélecteur de type
  Widget _buildToggleButton(String text, String value) {
    bool isSelected = _selectedUserType == value; // Vérifie si ce bouton est sélectionné
    return Expanded( // Permet aux boutons de partager l'espace équitablement
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedUserType = value), // Met à jour l'état quand cliqué
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.black : Colors.transparent, // Fond noir si sélectionné, transparent sinon
          foregroundColor: isSelected ? Colors.white : darkTextColor, // Texte blanc si sélectionné, foncé sinon
          elevation: 0, // Pas d'ombre
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Coins arrondis internes
          padding: const EdgeInsets.symmetric(vertical: 14), // Padding vertical
          shadowColor: Colors.transparent, // Pas d'ombre au clic
        ),
        child: Text(text, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }

  // Construit la case à cocher pour la politique de confidentialité avec validation
  Widget _buildPrivacyPolicyCheckbox() {
    return FormField<bool>( // Utilise FormField pour intégrer la validation
      key: ValueKey('privacyCheckbox$_acceptedPrivacyPolicy'), // Clé pour la reconstruction si nécessaire
      initialValue: _acceptedPrivacyPolicy, // Valeur initiale
      validator: (value) => (value == false) ? 'Vous devez accepter la politique de confidentialité' : null, // Règle de validation
      builder: (FormFieldState<bool> state) { // Construit l'UI de la case à cocher et du message d'erreur
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell( // Rend toute la ligne cliquable
            onTap: () => setState(() { // Inverse l'état et notifie le FormField du changement
              _acceptedPrivacyPolicy = !_acceptedPrivacyPolicy;
              state.didChange(_acceptedPrivacyPolicy);
            }),
            child: Row(children: [
              SizedBox(height: 20, width: 20, child: Checkbox( // La case à cocher visuelle
                value: _acceptedPrivacyPolicy,
                onChanged: (v) => setState(() { // Met à jour l'état et notifie le FormField
                  _acceptedPrivacyPolicy = v ?? false;
                  state.didChange(_acceptedPrivacyPolicy);
                }),
                activeColor: primaryRedColor, // Couleur quand cochée
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Réduit la zone de clic
                visualDensity: VisualDensity.compact, // Rend la case plus compacte
                side: BorderSide(color: state.hasError ? Colors.red : Colors.grey.shade400, width: 1.5), // Bordure rouge si erreur
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Coins légèrement arrondis
              )),
              const SizedBox(width: 8), // Espace entre la case et le texte
              // Texte cliquable
              Expanded(child: Text('J\'accepte la Politique de Confidentialité', style: TextStyle(fontSize: 13, fontFamily: 'Inter', color: state.hasError ? Colors.red : darkTextColor.withOpacity(0.8)))),
            ]),
          ),
          // Affiche le message d'erreur sous la case si la validation échoue
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12, fontFamily: 'Inter')),
            ),
        ]);
      },
    );
  }

  // Construit le lien "Log in" en bas du formulaire
  Widget _buildLoginLink(Color normalColor, Color linkColor) {
    return Text.rich( // Permet de combiner différents styles de texte
      TextSpan(
        text: 'Already have an account ? ', // Partie normale du texte
        style: TextStyle(color: normalColor, fontSize: 14, fontFamily: 'Inter'),
        children: <TextSpan>[ // Enfants avec styles différents
          TextSpan(
            text: 'Log In', // Partie cliquable (lien)
            style: TextStyle(color: linkColor, fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 14), // Style du lien (rouge et gras)
            recognizer: TapGestureRecognizer()..onTap = () { // Rend le texte cliquable
              print('Lien Se connecter cliqué !'); // Action au clic (à remplacer par la navigation)
              // TODO: Implémenter la navigation vers l'écran de connexion
            },
          ),
        ],
      ),
      textAlign: TextAlign.center, // Centre le texte
    );
  }
} // Fin de la classe _RegisterScreenState
