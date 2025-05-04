import 'package:flutter/material.dart';
import 'screens/register/register_screen.dart'; // Chemin vers l'écran principal
import 'config/app_colors.dart'; // Importe les couleurs centralisées

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Flutter', // Le titre de l'application (peut être vu dans l'onglet du navigateur)
      theme: ThemeData(
        // Police par défaut pour toute l'application
        fontFamily: 'Inter',

        // Définition du schéma de couleurs principal
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryRed, // Couleur de base pour générer la palette
          primary: AppColors.primaryRed,   // Couleur primaire explicite
          error: AppColors.errorRed,     // Couleur pour les erreurs
          // Vous pouvez définir d'autres couleurs ici: secondary, background, surface, etc.
          // background: AppColors.formBackground, // Couleur de fond par défaut des Scaffold, etc.
        ),

        // Densité visuelle adaptative pour différents appareils
        visualDensity: VisualDensity.adaptivePlatformDensity,

        // Style global pour les champs de texte (TextFormField, TextField)
         inputDecorationTheme: InputDecorationTheme(
          filled: true, // Active le fond coloré
          fillColor: AppColors.inputFill, // Utilise la couleur de fond définie
          // Style du texte indicatif (placeholder/label)
          hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.greyText),
          // Style du label flottant (quand le champ a le focus ou du contenu)
          // labelStyle: TextStyle(color: AppColors.primaryRed.withOpacity(0.8)), // Exemple
          // Padding interne du champ
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
          // Définition des bordures
          border: OutlineInputBorder( // Bordure par défaut (souvent invisible car fillColor)
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none, // Pas de bordure visible par défaut
          ),
          enabledBorder: OutlineInputBorder( // Bordure quand le champ est activé mais n'a pas le focus
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder( // Bordure quand le champ a le focus
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.primaryRed.withOpacity(0.7), width: 1.5), // Utilise la couleur primaire
          ),
          errorBorder: OutlineInputBorder( // Bordure quand le champ a une erreur
             borderRadius: BorderRadius.circular(12.0),
             borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5), // Utilise la couleur d'erreur
          ),
          focusedErrorBorder: OutlineInputBorder( // Bordure quand le champ a une erreur ET le focus
             borderRadius: BorderRadius.circular(12.0),
             borderSide: const BorderSide(color: AppColors.errorRed, width: 2.0),
          ),
        ),

        // Style global pour les ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
             backgroundColor: AppColors.primaryRed, // Couleur de fond par défaut
             foregroundColor: Colors.white, // Couleur de texte par défaut (blanc sur rouge)
             shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Coins arrondis standard
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0), // Padding standard
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter') // Style de texte standard
          )
        ),

        // Style global pour les TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryRed, // Couleur de texte par défaut pour TextButton
             textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')
          )
        ),

        // Style global pour AlertDialog (peut être utile pour le dialogue de connexion)
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.formBackground,
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(15.0),
           ),
           titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText, fontFamily: 'Inter'),
           // contentTextStyle: TextStyle(fontSize: 14, color: AppColors.darkText, fontFamily: 'Inter'), // Style pour le contenu
        ),

        // Vous pouvez définir d'autres thèmes ici (AppBarTheme, CardTheme, etc.)

      ),
      home: const RegisterScreen(), // Écran de démarrage
      debugShowCheckedModeBanner: false, // Cache la bannière "Debug"
    );
  }
}
