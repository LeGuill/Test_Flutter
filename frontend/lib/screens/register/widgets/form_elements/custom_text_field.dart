import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart'; // Importe les couleurs globales

// Widget réutilisable pour un champ de texte stylisé du formulaire
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label; // Utilisé comme hintText pour un look moderne
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator; // Fonction de validation
  final TextInputAction? textInputAction; // Action du clavier (next, done)

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.textInputAction = TextInputAction.next, // Défaut à 'next'
  });

  @override
  Widget build(BuildContext context) {
    // Utilise le thème global défini dans main.dart pour le style de base
    // L'InputDecoration hérite du inputDecorationTheme
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      // Le style du texte saisi pourrait aussi venir du thème (textTheme)
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.darkText),
      decoration: InputDecoration(
        hintText: label,
        // Les autres styles (fillColor, borders, padding, hintStyle)
        // sont définis dans le thème global (main.dart)
      ),
      textInputAction: textInputAction,
    );
  }
}
