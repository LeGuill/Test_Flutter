import 'package:flutter/material.dart';

// Widget StatelessWidget pour le bouton qui ré-ouvre le formulaire
class OpenFormButton extends StatelessWidget {
  final VoidCallback onPressed; // Fonction à exécuter au clic
  final Color primaryRedColor; // Couleur du bouton

  // Constructeur qui exige la fonction et la couleur
  const OpenFormButton({
    super.key,
    required this.onPressed,
    required this.primaryRedColor,
  });

  @override
  Widget build(BuildContext context) {
    // Positionne le bouton en haut à droite
    return Positioned(
      top: 20, // Espace depuis le haut
      right: 25, // Espace depuis la droite
      child: ElevatedButton(
        onPressed: onPressed, // Appelle la fonction passée
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRedColor, // Utilise la couleur passée
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
          elevation: 3, // Ombre légère
        ),
        child: const Text('Create Account'),
      ),
    );
  }
}
