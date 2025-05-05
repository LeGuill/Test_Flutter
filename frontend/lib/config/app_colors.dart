import 'package:flutter/material.dart';

// Centralise les couleurs de l'application
class AppColors {
  // Couleurs de base
  static const Color formBackground = Colors.white;
  static const Color primaryRed = Color.fromARGB(255, 255, 0, 0);
  // Utiliser une nuance spécifique de gris pour le texte si nécessaire
  static const Color greyText = Colors.grey; 
  static const Color darkText = Color(0xFF333333);
  static const Color lightText = Colors.white70; // Pour le texte sur fond sombre

  // Couleurs spécifiques aux composants
  static const Color toggleButtonBackground = Color(0xFFF0F0F0);
  static const Color inputFill = Color(0xFFF9F9F9); // Fond des champs

  // Couleurs de statut
  static const Color errorRed = Colors.red;
  static const Color successGreen = Colors.green;

}
