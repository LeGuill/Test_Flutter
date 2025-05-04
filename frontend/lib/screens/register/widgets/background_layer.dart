import 'package:flutter/material.dart';
import '../../../config/app_colors.dart'; // Importe les couleurs globales

// Widget StatelessWidget pour afficher le fond et le contenu statique
class BackgroundLayer extends StatelessWidget {
  // Ne reçoit plus lightTextColor car on utilise AppColors.lightText
  final double screenWidth;
  final double mobileBreakpoint; // Pourrait venir de app_constants.dart

  const BackgroundLayer({
    super.key,
    required this.screenWidth,
    required this.mobileBreakpoint,
  });

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = screenWidth < mobileBreakpoint ? 20.0 : 50.0;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          // Assurez-vous que ce chemin est correct dans pubspec.yaml
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 40.0),
        child: SingleChildScrollView( // Permet le défilement si le contenu dépasse
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Image.asset(
                // Assurez-vous que ce chemin est correct dans pubspec.yaml
                'assets/images/logo.png',
                height: 50,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 80), // Espace après le logo

              // Espacement avant le contenu principal
              const SizedBox(height: 40),

              // Section centrale
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    const Text(
                      'Manage your Money\nAnywhere',
                      style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 15),

                    // Sous-titre
                    const Text(
                      'View all the analytics and grow your business\nfrom anywhere!',
                      // Utilise la couleur directement depuis AppColors
                      style: TextStyle(fontSize: 16, color: AppColors.lightText, height: 1.5, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 30),

                    // Boîtes d'information avec Wrap
                    Wrap(
                      spacing: 20.0, // Espace horizontal
                      runSpacing: 20.0, // Espace vertical si retour à la ligne
                      alignment: WrapAlignment.start, // Alignement
                      children: [
                        _buildInfoBox("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
                        _buildInfoBox("Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
                        _buildInfoBox("Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."),
                      ],
                    )
                  ],
                ),
              ),

              // Espacement après le contenu principal
              const SizedBox(height: 60),

            ],
          ),
        ),
      ),
    );
  }

  // Méthode helper privée pour construire une boîte d'info
  Widget _buildInfoBox(String text) {
    // Le style du texte interne utilise directement Colors.white ici
    const infoTextStyle = TextStyle(color: Colors.white, fontSize: 14, height: 1.6, fontFamily: 'Inter');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Text(text, style: infoTextStyle, textAlign: TextAlign.center),
    );
  }
}
