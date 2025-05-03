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
      title: 'Test Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue, // PERSONNALISER LA COULEUR PRINCIPALE
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // DEFINIR LE THEME ICI
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
          fillColor: Colors.grey.shade100, // Couleur de fond 
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