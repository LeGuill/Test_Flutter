import 'package:flutter/gestures.dart'; // Pour TapGestureRecognizer
import 'package:flutter/material.dart';

// Widget StatelessWidget pour le panneau de formulaire coulissant
class SlidingFormPanel extends StatelessWidget {
  // --- Paramètres Requis (passés depuis le parent _RegisterScreenState) ---

  // État et dimensions
  final bool isVisible;
  final Duration slideDuration;
  final double formWidth;

  // Clé et contrôleurs du formulaire
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController passwordController;

  // Variables d'état du formulaire
  final String selectedUserType;
  final String? selectedCompanyLocation;
  final String? selectedIndustry;
  final bool acceptedPrivacyPolicy;

  // État de chargement et erreur
  final bool isLoading;
  final String? errorMessage;

  // Données pour les menus
  final List<String> companyLocations;
  final List<String> industries;

  // Callbacks (fonctions pour communiquer avec le parent)
  final ValueChanged<String> onUserTypeChanged;
  final ValueChanged<String?> onCompanyLocationChanged;
  final ValueChanged<String?> onIndustryChanged;
  final ValueChanged<bool?> onPrivacyPolicyChanged;
  final VoidCallback onRegister;
  final VoidCallback onClose;

  // Fonctions de validation (passées depuis le parent)
  final String? Function(String?, String) validateRequired;
  final String? Function(String?, String) validateDropdown;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;

  // Couleurs (passées pour la cohérence)
  final Color formBackgroundColor;
  final Color primaryRedColor;
  final Color greyTextColor;
  final Color darkTextColor;
  final Color toggleButtonBg;

  // Constructeur pour initialiser toutes les variables requises
  const SlidingFormPanel({
    super.key, // Bonne pratique
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
    required this.validateRequired,
    required this.validateDropdown,
    required this.validateEmail,
    required this.validatePassword,
    required this.formBackgroundColor,
    required this.primaryRedColor,
    required this.greyTextColor,
    required this.darkTextColor,
    required this.toggleButtonBg,
  });

  @override
  Widget build(BuildContext context) {
    // Le widget racine est AnimatedPositioned pour l'effet de glissement
    return AnimatedPositioned(
      duration: slideDuration,
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      width: formWidth,
      right: isVisible ? 0 : -formWidth, // Position animée
      child: Container(
        decoration: BoxDecoration(
          color: formBackgroundColor, // Fond blanc
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25.0),
            bottomLeft: Radius.circular(25.0),
          ),
          boxShadow: [ // Ombre
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(-10, 0),
            ),
          ],
        ),
        // Stack interne pour superposer le bouton de fermeture
        child: Stack(
          children: [
            // Contenu principal du formulaire (scrollable)
            Padding(
              padding: const EdgeInsets.only(top: 50.0), // Espace pour le bouton
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(35.0, 20.0, 35.0, 40.0),
                child: Form(
                  key: formKey, // Utilise la clé passée
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Titre du formulaire
                      Text(
                        'Create an account',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: darkTextColor, fontFamily: 'Inter'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 35),

                      // Champs du formulaire (utilisant les méthodes helper ci-dessous)
                      _buildUserTypeToggle(),
                      const SizedBox(height: 25),
                      _buildTextFormField(firstNameController, 'First Name', validator: (v) => validateRequired(v, 'First Name')),
                      const SizedBox(height: 18),
                      _buildDropdownFormField(hint: 'Where is your company based?', value: selectedCompanyLocation, items: companyLocations, onChanged: onCompanyLocationChanged, validator: (v) => validateDropdown(v, 'location')),
                      const SizedBox(height: 18),
                      _buildTextFormField(emailController, 'Email', keyboardType: TextInputType.emailAddress, validator: validateEmail),
                      const SizedBox(height: 18),
                      _buildDropdownFormField(hint: 'Please select an Industry', value: selectedIndustry, items: industries, onChanged: onIndustryChanged, validator: (v) => validateDropdown(v, 'industry')),
                      const SizedBox(height: 18),
                      _buildTextFormField(phoneNumberController, 'Phone number', keyboardType: TextInputType.phone, validator: (v) => validateRequired(v, 'Phone number')),
                      const SizedBox(height: 18),
                      _buildTextFormField(passwordController, 'Password', obscureText: true, validator: validatePassword),
                      const SizedBox(height: 25),
                      _buildPrivacyPolicyCheckbox(),
                      const SizedBox(height: 25),

                      // Affichage conditionnel du message d'erreur
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Bouton de soumission
                      ElevatedButton(
                        onPressed: isLoading ? null : onRegister, // Utilise le callback
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRedColor, // Utilise la couleur passée
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                          elevation: 3,
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('Create an Account'),
                      ),
                      const SizedBox(height: 30),

                      // Lien de connexion
                      _buildLoginLink(greyTextColor, primaryRedColor), // Utilise les couleurs passées
                    ],
                  ),
                ),
              ),
            ),

            // Bouton de fermeture positionné par-dessus
            Positioned(
              top: 15,
              right: 15,
              child: IconButton(
                icon: Icon(Icons.close, color: greyTextColor), // Utilise la couleur passée
                iconSize: 28,
                tooltip: 'Fermer le formulaire',
                onPressed: onClose, // Utilise le callback
              ),
            ),
          ],
        ),
      ),
    );
  }


  // --- Méthodes Helper pour construire les champs du formulaire ---
  // Ces méthodes sont maintenant internes à ce widget

  Widget _buildTextFormField(TextEditingController controller, String label, {bool obscureText = false, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: darkTextColor),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryRedColor.withOpacity(0.5), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildDropdownFormField({required String hint, required String? value, required List<String> items, required void Function(String?)? onChanged, required String? Function(String?)? validator}) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: darkTextColor)))).toList(),
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: darkTextColor),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryRedColor.withOpacity(0.5), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
      ),
      isExpanded: true,
    );
  }

  Widget _buildUserTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: toggleButtonBg, borderRadius: BorderRadius.circular(12.0)),
      child: Row(children: [
        _buildToggleButton('Merchant', 'merchant'),
        const SizedBox(width: 4),
        _buildToggleButton('Agent', 'agent')
      ]),
    );
  }

  Widget _buildToggleButton(String text, String value) {
    bool isSelected = selectedUserType == value; // Utilise la variable d'état passée
    return Expanded(
      child: ElevatedButton(
        onPressed: () => onUserTypeChanged(value), // Utilise le callback
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.black : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : darkTextColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shadowColor: Colors.transparent,
        ),
        child: Text(text, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }

  Widget _buildPrivacyPolicyCheckbox() {
    // L'état de validation (bordure rouge) est géré par le Form parent via la clé.
    // Ce widget se contente d'afficher la case et d'appeler le callback.
    return InkWell(
      onTap: () => onPrivacyPolicyChanged(!acceptedPrivacyPolicy), // Inverse la valeur via callback
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
              value: acceptedPrivacyPolicy, // Utilise la valeur passée
              onChanged: onPrivacyPolicyChanged, // Utilise le callback
              activeColor: primaryRedColor, // Utilise la couleur passée
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              // La bordure d'erreur sera appliquée par le FormField implicite du Form
              side: BorderSide(color: Colors.grey.shade400, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'J\'accepte la Politique de Confidentialité',
              style: TextStyle(fontSize: 13, fontFamily: 'Inter', color: darkTextColor.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink(Color normalColor, Color linkColor) {
    return Text.rich(
      TextSpan(
        text: 'Already have an account ? ',
        style: TextStyle(color: normalColor, fontSize: 14, fontFamily: 'Inter'),
        children: <TextSpan>[
          TextSpan(
            text: 'Log In',
            style: TextStyle(color: linkColor, fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 14),
            recognizer: TapGestureRecognizer()..onTap = () {
              print('Lien Se connecter cliqué !');
              // TODO: Implémenter la navigation
            },
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
