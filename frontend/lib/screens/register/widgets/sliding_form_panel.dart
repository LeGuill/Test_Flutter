import 'package:flutter/material.dart';
import '../../../config/app_colors.dart'; // Importe les couleurs globales
// Importe les widgets de formulaire extraits
import 'form_elements/custom_text_field.dart';
import 'form_elements/custom_dropdown.dart';
import 'form_elements/user_type_toggle.dart';
import 'form_elements/privacy_policy_checkbox.dart';
import 'form_elements/login_link.dart';
// Importe les validateurs pour les passer aux widgets enfants
import '../../../utils/validators.dart';

// Widget pour le panneau de formulaire coulissant (maintenant simplifié)
class SlidingFormPanel extends StatelessWidget {
  // --- Paramètres Requis ---
  final bool isVisible;
  final Duration slideDuration;
  final double formWidth;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController passwordController;
  final String selectedUserType;
  final String? selectedCompanyLocation;
  final String? selectedIndustry;
  final bool acceptedPrivacyPolicy;
  final bool isLoading;
  final String? errorMessage; // Erreur globale (ex: backend)
  final List<String> companyLocations;
  final List<String> industries;
  final ValueChanged<String> onUserTypeChanged;
  final ValueChanged<String?> onCompanyLocationChanged;
  final ValueChanged<String?> onIndustryChanged;
  final ValueChanged<bool?> onPrivacyPolicyChanged;
  final VoidCallback onRegister;
  final VoidCallback onClose;
  final VoidCallback onLoginLinkTap;

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

  @override
  Widget build(BuildContext context) {
    final double formHorizontalPadding = formWidth < 400 ? 25.0 : 35.0;

    return AnimatedPositioned(
      duration: slideDuration,
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      width: formWidth,
      right: isVisible ? 0 : -formWidth,
      child: Container(
        decoration: BoxDecoration(
           color: AppColors.formBackground, // Utilise couleur config
           borderRadius: const BorderRadius.only(topLeft: Radius.circular(25.0), bottomLeft: Radius.circular(25.0)),
           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(-10, 0))],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(formHorizontalPadding, 20.0, formHorizontalPadding, 40.0),
                child: Form(
                  key: formKey,
                  // La colonne assemble maintenant les widgets de formulaire extraits
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Titre
                      const Text(
                        'Create an account',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.darkText, fontFamily: 'Inter'),
                        textAlign: TextAlign.center
                      ),
                      const SizedBox(height: 35),

                      // --- Utilisation des widgets extraits ---
                      UserTypeToggle(
                        selectedUserType: selectedUserType,
                        onUserTypeChanged: onUserTypeChanged,
                      ),
                      const SizedBox(height: 25),
                      CustomTextField(
                        controller: firstNameController,
                        label: 'First Name',
                        validator: (v) => validateRequired(v, 'First Name'),
                      ),
                      const SizedBox(height: 18),
                      CustomDropdown(
                        hint: 'Where is your company based?',
                        value: selectedCompanyLocation,
                        items: companyLocations,
                        onChanged: onCompanyLocationChanged,
                        validator: (v) => validateDropdown(v, 'location'),
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
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
                        keyboardType: TextInputType.phone,
                        validator: (v) => validateRequired(v, 'Phone number'),
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: passwordController,
                        label: 'Password',
                        obscureText: true,
                        validator: (v) => validatePassword(v, checkLength: true),
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 25),
                      PrivacyPolicyCheckbox(
                        initialValue: acceptedPrivacyPolicy,
                        onChanged: onPrivacyPolicyChanged,
                      ),
                      const SizedBox(height: 25),

                      // Affichage Erreur Globale
                      if (errorMessage != null) Padding(padding: const EdgeInsets.only(bottom: 15.0), child: Text(errorMessage!, style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 13), textAlign: TextAlign.center)),

                      // Bouton Soumission
                      ElevatedButton(
                        onPressed: isLoading ? null : onRegister,
                        // Style hérité du thème global
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('Create an Account'),
                      ),
                      const SizedBox(height: 30),

                      // Lien Connexion
                      LoginLink(onLoginTap: onLoginLinkTap),
                    ],
                  ),
                ),
              ),
            ),
            // Bouton Fermer
            Positioned(
              top: 15, right: 15,
              child: IconButton(icon: const Icon(Icons.close, color: AppColors.greyText), iconSize: 28, tooltip: 'Fermer le formulaire', onPressed: onClose),
            ),
          ],
        ),
      ),
    );
  }
}
