import 'package:flutter/material.dart';
import '../../../config/app_colors.dart'; // Importe les couleurs définies globalement pour l'application
// Importe les widgets personnalisés pour les éléments de formulaire, favorisant la réutilisabilité
import 'form_elements/custom_text_field.dart';        // Champ de texte personnalisé
import 'form_elements/custom_dropdown.dart';         // Menu déroulant personnalisé
import 'form_elements/user_type_toggle.dart';       // Sélecteur de type d'utilisateur (ex: client/entreprise)
import 'form_elements/privacy_policy_checkbox.dart'; // Case à cocher pour la politique de confidentialité
import 'form_elements/login_link.dart';             // Lien pour rediriger vers la page de connexion
// Importe les fonctions de validation pour vérifier les entrées utilisateur
import '../../../utils/validators.dart';

// Définit un widget `SlidingFormPanel` qui est un `StatelessWidget`.
// Il représente un panneau de formulaire qui apparaît en glissant depuis le côté droit.
// 'Stateless' signifie que son apparence et ses données ne changent pas dynamiquement *en interne*.
// Les changements (comme la visibilité) sont gérés par le widget parent qui le reconstruit avec de nouvelles valeurs.
class SlidingFormPanel extends StatelessWidget {
  // --- Déclaration des Paramètres Requis ---
  // Ces paramètres doivent être fournis lors de la création d'une instance de `SlidingFormPanel`.

  final bool isVisible; // Contrôle si le panneau est visible ou caché
  final Duration slideDuration; // Durée de l'animation de glissement
  final double formWidth; // Largeur du panneau de formulaire
  final GlobalKey<FormState> formKey; // Clé unique pour identifier et gérer l'état du formulaire (validation, sauvegarde)
  // Contrôleurs pour récupérer/modifier le texte des champs de saisie
  final TextEditingController firstNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController passwordController;
  // Variables pour stocker les sélections de l'utilisateur
  final String selectedUserType;          // Type d'utilisateur choisi (ex: 'Client', 'Entreprise')
  final String? selectedCompanyLocation; // Lieu de l'entreprise (peut être null)
  final String? selectedIndustry;        // Secteur d'activité (peut être null)
  final bool acceptedPrivacyPolicy;   // Indique si la politique de confidentialité est acceptée
  // Indicateurs d'état
  final bool isLoading;               // `true` si une opération (ex: envoi) est en cours
  final String? errorMessage;         // Message d'erreur à afficher (peut être null)
  // Listes de données pour les menus déroulants
  final List<String> companyLocations;
  final List<String> industries;
  // Fonctions de rappel (callbacks) pour notifier le widget parent des changements ou actions
  final ValueChanged<String> onUserTypeChanged;          // Appelé quand le type d'utilisateur change
  final ValueChanged<String?> onCompanyLocationChanged; // Appelé quand le lieu change
  final ValueChanged<String?> onIndustryChanged;        // Appelé quand le secteur change
  final ValueChanged<bool?> onPrivacyPolicyChanged;   // Appelé quand la case est cochée/décochée
  final VoidCallback onRegister;                         // Appelé lors du clic sur le bouton d'inscription
  final VoidCallback onClose;                            // Appelé lors du clic sur le bouton de fermeture
  final VoidCallback onLoginLinkTap;                   // Appelé lors du clic sur le lien de connexion

  // Constructeur du widget : initialise toutes les propriétés requises.
  // `super.key` transmet une clé optionnelle au constructeur parent (`StatelessWidget`), utile pour Flutter.
  const SlidingFormPanel({
    super.key,
    required this.isVisible,
    required this.slideDuration,
    required this.formWidth,
    required this.formKey,
    required this.firstNameController,
    required this.emailController,
    required this.phoneNumberController,
    required this.passwordController,
    required this.selectedUserType,
    required this.selectedCompanyLocation,
    required this.selectedIndustry,
    required this.acceptedPrivacyPolicy,
    required this.isLoading,
    required this.errorMessage,
    required this.companyLocations,
    required this.industries,
    required this.onUserTypeChanged,
    required this.onCompanyLocationChanged,
    required this.onIndustryChanged,
    required this.onPrivacyPolicyChanged,
    required this.onRegister,
    required this.onClose,
    required this.onLoginLinkTap,
  });

  // Méthode `build` : décrit comment construire l'interface utilisateur du widget.
  // Appelée par Flutter chaque fois que le widget doit être affiché ou mis à jour.
  @override
  Widget build(BuildContext context) {
    // Calcule le padding horizontal en fonction de la largeur pour un design adaptatif simple.
    final double formHorizontalPadding = formWidth < 400 ? 25.0 : 35.0;

    // `AnimatedPositioned` : Un widget qui anime le changement de position de son enfant.
    // Idéal pour créer l'effet de glissement du panneau.
    return AnimatedPositioned(
      duration: slideDuration, // Durée de l'animation
      curve: Curves.easeInOut, // Courbe d'animation pour un effet fluide
      top: 0,                  // Positionné en haut
      bottom: 0,               // Étiré jusqu'en bas
      width: formWidth,        // Largeur définie
      // Position horizontale : `0` si visible (aligné à droite), `-formWidth` si caché (hors de l'écran à droite)
      right: isVisible ? 0 : -formWidth,
      // `Container` : Sert de fond et de structure au panneau
      child: Container(
        decoration: BoxDecoration(
           color: AppColors.formBackground, // Couleur de fond depuis les couleurs globales
           // Coins arrondis seulement sur le côté gauche pour l'effet panneau
           borderRadius: const BorderRadius.only(topLeft: Radius.circular(25.0), bottomLeft: Radius.circular(25.0)),
           // Ombre portée pour donner de la profondeur
           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(-10, 0))],
        ),
        // `Stack` : Permet de superposer des widgets (ici, le formulaire et le bouton fermer)
        child: Stack(
          children: [
            // Contenu principal du formulaire avec padding (évite que le bouton fermer ne soit au-dessus au début)
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              // `SingleChildScrollView` : Permet au contenu de défiler si le formulaire dépasse la hauteur de l'écran
              child: SingleChildScrollView(
                // Padding interne pour espacer le contenu des bords du panneau
                padding: EdgeInsets.fromLTRB(formHorizontalPadding, 20.0, formHorizontalPadding, 40.0),
                // `Form` : Widget qui regroupe les champs de formulaire et permet la validation globale
                child: Form(
                  key: formKey, // Associe la clé globale au formulaire pour pouvoir le contrôler
                  // `Column` : Organise les éléments du formulaire verticalement
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Étire les enfants horizontalement
                    mainAxisSize: MainAxisSize.min, // La colonne prend la hauteur minimale nécessaire
                    children: [
                      // Titre du formulaire
                      const Text(
                        'Create an account',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.darkText, fontFamily: 'Inter'),
                        textAlign: TextAlign.center
                      ),
                      const SizedBox(height: 35), // Espace vertical

                      // --- Utilisation des widgets de formulaire personnalisés ---
                      // Chaque widget prend les valeurs et callbacks nécessaires depuis les paramètres du `SlidingFormPanel`.
                      UserTypeToggle(
                        selectedUserType: selectedUserType,
                        onUserTypeChanged: onUserTypeChanged, // Passe la fonction de rappel
                      ),
                      const SizedBox(height: 25), // Espace vertical
                      CustomTextField(
                        controller: firstNameController, // Lie le contrôleur au champ
                        label: 'First Name',
                        validator: (v) => validateRequired(v, 'First Name'), // Fournit une fonction de validation
                      ),
                      const SizedBox(height: 18),
                      CustomDropdown(
                        hint: 'Where is your company based?',
                        value: selectedCompanyLocation, // Valeur actuellement sélectionnée
                        items: companyLocations,        // Liste des options
                        onChanged: onCompanyLocationChanged, // Callback en cas de changement
                        validator: (v) => validateDropdown(v, 'location'), // Validation spécifique aux dropdowns
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress, // Clavier optimisé pour email
                        validator: validateEmail, // Utilise le validateur d'email importé
                      ),
                      const SizedBox(height: 18),
                      CustomDropdown(
                        hint: 'Please select an Industry',
                        value: selectedIndustry,
                        items: industries,
                        onChanged: onIndustryChanged,
                        validator: (v) => validateDropdown(v, 'industry'),
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: phoneNumberController,
                        label: 'Phone number',
                        keyboardType: TextInputType.phone, // Clavier optimisé pour téléphone
                        validator: (v) => validateRequired(v, 'Phone number'),
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: passwordController,
                        label: 'Password',
                        obscureText: true, // Masque le texte saisi (pour les mots de passe)
                        validator: (v) => validatePassword(v, checkLength: true), // Validateur de mot de passe
                        textInputAction: TextInputAction.done, // Action du bouton "Entrée" du clavier (Terminé)
                      ),
                      const SizedBox(height: 25),
                      PrivacyPolicyCheckbox(
                        initialValue: acceptedPrivacyPolicy,
                        onChanged: onPrivacyPolicyChanged, // Callback pour la case à cocher
                      ),
                      const SizedBox(height: 25),

                      // Affichage conditionnel du message d'erreur global (si non null)
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text(
                            errorMessage!, // Le '!' affirme que errorMessage n'est pas null ici
                            style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 13),
                            textAlign: TextAlign.center
                          )
                        ),

                      // Bouton principal pour soumettre le formulaire
                      ElevatedButton(
                        // Désactivé si `isLoading` est true (affiche alors le spinner)
                        onPressed: isLoading ? null : onRegister,
                        // Le style du bouton est probablement défini globalement dans le thème de l'app
                        child: isLoading
                            // Affiche un indicateur de chargement si `isLoading` est true
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            // Sinon, affiche le texte normal
                            : const Text('Create an Account'),
                      ),
                      const SizedBox(height: 30),

                      // Lien pour rediriger vers la page de connexion existante
                      LoginLink(onLoginTap: onLoginLinkTap), // Utilise le widget personnalisé
                    ],
                  ),
                ),
              ),
            ),
            // Bouton de fermeture positionné en haut à droite par-dessus le contenu
            Positioned(
              top: 15, right: 15,
              // `IconButton` : Un bouton standard avec une icône
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.greyText), // Icône "fermer"
                iconSize: 28,
                tooltip: 'Fermer le formulaire', // Texte affiché au survol (aide à l'accessibilité)
                onPressed: onClose, // Appelle la fonction de rappel pour fermer
              ),
            ),
          ],
        ),
      ),
    );
  }
}