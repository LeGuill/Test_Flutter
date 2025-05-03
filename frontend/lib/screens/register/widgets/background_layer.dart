import 'package:flutter/material.dart';

// Widget StatelessWidget pour afficher le fond et le contenu statique
class BackgroundLayer extends StatelessWidget {
  final Color lightTextColor; // Reçoit la couleur claire pour le texte

  // Constructeur qui exige la couleur
  const BackgroundLayer({
    super.key, // Bonne pratique d'accepter et passer la clé
    required this.lightTextColor,
  });

  @override
  Widget build(BuildContext context) {
    // Construit l'UI de cette couche
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          // Assurez-vous que ce chemin est correct par rapport à votre pubspec.yaml
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover, // L'image couvre tout l'espace
        ),
      ),
      // Contenu par-dessus l'image
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligne à gauche
          children: [
            // Logo
            Image.asset(
              // Assurez-vous que ce chemin est correct
              'assets/images/logo.png',
              height: 50, // Taille du logo
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.white, size: 50), // Icône de secours
            ),
            const SizedBox(height: 80), // Espace

            // Spacer pour pousser le contenu vers le centre vertical
            const Spacer(flex: 1), // Moins d'espace en haut

            // Section centrale (Titre, Sous-titre, Boîtes)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Prend hauteur minimale
                crossAxisAlignment: CrossAxisAlignment.start, // Aligne à gauche
                children: [
                  // Titre
                  const Text(
                    'Manage your Money\nAnywhere',
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3, fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 15), // Espace

                  // Sous-titre
                  Text( // Utilise la couleur passée
                    'View all the analytics and grow your business\nfrom anywhere!',
                    style: TextStyle(fontSize: 16, color: lightTextColor, height: 1.5, fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 30), // Espace

                  // Rangée des boîtes d'information
                  Row(
                    mainAxisSize: MainAxisSize.min, // Prend largeur minimale
                    children: [
                      _buildInfoBox("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
                      const SizedBox(width: 20), // Espace entre boîtes
                      _buildInfoBox("Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
                      const SizedBox(width: 20), // Espace entre boîtes
                      _buildInfoBox("Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."),
                    ],
                  ),
                ],
              ),
            ),

            // Spacer pour pousser le contenu vers le centre vertical
            const Spacer(flex: 2), // Plus d'espace en bas
          ],
        ),
      ),
    );
  }

  // Méthode helper privée pour construire une boîte d'info
  // (Pourrait aussi être un widget séparé si plus complexe)
  Widget _buildInfoBox(String text) {
    const infoTextStyle = TextStyle(color: Colors.white, fontSize: 14, height: 1.6, fontFamily: 'Inter');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0), // Padding interne
      constraints: const BoxConstraints(maxWidth: 350), // Largeur max
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35), // Fond semi-transparent
        borderRadius: BorderRadius.circular(15.0), // Coins arrondis
      ),
      child: Text(text, style: infoTextStyle, textAlign: TextAlign.center),
    );
  }
}
