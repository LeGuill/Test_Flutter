import 'package:flutter/material.dart';
import 'screens/register_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reno Energie Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tu peux personnaliser le thème
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Tu peux définir ici des styles globaux (polices, couleurs, etc.)
        // pour te rapprocher du design Dribbble.
         inputDecorationTheme: InputDecorationTheme( // Style de base pour les champs
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          filled: true,
          fillColor: Colors.grey.shade100, // Couleur de fond légère
        ),
        elevatedButtonTheme: ElevatedButtonThemeData( // Style de base pour le bouton
          style: ElevatedButton.styleFrom(
             shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
          )
        )
      ),
      home: const RegisterScreen(), 
      debugShowCheckedModeBanner: false, // Cache la bannière de debug
    );
  }
}