import 'package:flutter/material.dart';

// Widget StatelessWidget pour afficher le fond et le contenu statique
class BackgroundLayer extends StatelessWidget {
  final Color lightTextColor;
  final double screenWidth;
  final double mobileBreakpoint;

  const BackgroundLayer({
    super.key,
    required this.lightTextColor,
    required this.screenWidth,
    required this.mobileBreakpoint,
  });

  @override
  Widget build(BuildContext context) {
    // Calcul Adaptatif du Padding Horizontal
    final double horizontalPadding = screenWidth < mobileBreakpoint ? 20.0 : 50.0;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      // Utilise le padding horizontal calculé
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 40.0),
        // <<< AJOUT : SingleChildScrollView pour éviter le débordement vertical >>>
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                height: 50,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 80), // Espace après le logo

              // <<< MODIFIÉ : Remplacement du Spacer(flex: 1) par un SizedBox >>>
              // Ajustez cette hauteur si nécessaire pour l'espacement avant le contenu central
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
                    Text(
                      'View all the analytics and grow your business\nfrom anywhere!',
                      style: TextStyle(fontSize: 16, color: lightTextColor, height: 1.5, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 30),

                    // Boîtes d'information avec Wrap
                    Wrap(
                      spacing: 20.0,
                      runSpacing: 20.0,
                      alignment: WrapAlignment.start,
                      children: [
                        _buildInfoBox("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
                        _buildInfoBox("Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
                        _buildInfoBox("Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."),
                      ],
                    )
                  ],
                ),
              ),

              // <<< MODIFIÉ : Remplacement du Spacer(flex: 2) par un SizedBox >>>
              // Ajustez cette hauteur si nécessaire pour l'espacement après le contenu central
              const SizedBox(height: 60),

            ], // Fin des children de la Column principale
          ), // Fin de SingleChildScrollView
        ), // Fin du Padding
      ), // Fin du Container principal
    ); // Fin du return
  }

  // Méthode helper privée pour construire une boîte d'info
  Widget _buildInfoBox(String text) {
    const infoTextStyle = TextStyle(color: Colors.white, fontSize: 14, height: 1.6, fontFamily: 'Inter');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
      constraints: const BoxConstraints(maxWidth: 350), // Largeur max de chaque boîte
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Text(text, style: infoTextStyle, textAlign: TextAlign.center),
    );
  }
}
