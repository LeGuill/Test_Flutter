import 'package:flutter/material.dart';
// Importe les définitions de couleurs personnalisées pour l'application.
// Cela permet de centraliser les couleurs et de les réutiliser facilement.
import '../../../config/app_colors.dart';

// Définit un widget 'BackgroundLayer' qui est 'Stateless'.
// Un StatelessWidget décrit une partie de l'interface utilisateur qui ne dépend que de
// sa configuration (les paramètres passés au constructeur) et du BuildContext.
// Il n'a pas d'état interne mutable.
class BackgroundLayer extends StatelessWidget {
  // Largeur actuelle de l'écran, utilisée pour ajuster la mise en page (responsive).
  final double screenWidth;
  // Point de rupture (breakpoint) pour déterminer si l'affichage est de type mobile ou plus large.
  // Utilisé pour adapter le padding horizontal.
  final double mobileBreakpoint;

  // Constructeur du widget.
  // 'required' indique que ces paramètres doivent être fournis lors de la création d'une instance.
  // 'super.key' transmet la clé au constructeur de la classe parente (StatelessWidget).
  const BackgroundLayer({
    super.key,
    required this.screenWidth,
    required this.mobileBreakpoint,
  });

  // La méthode 'build' décrit la partie de l'interface utilisateur représentée par ce widget.
  // Elle est appelée par le framework Flutter lorsque le widget doit être rendu.
  @override
  Widget build(BuildContext context) {
    // Calcule le padding horizontal en fonction de la largeur de l'écran.
    // Si l'écran est plus petit que le point de rupture mobile, utilise un padding plus petit.
    final double horizontalPadding = screenWidth < mobileBreakpoint ? 20.0 : 50.0;

    // Retourne un 'Container' qui occupe toute la largeur et la hauteur disponibles.
    return Container(
      width: double.infinity, // Prend toute la largeur possible.
      height: double.infinity, // Prend toute la hauteur possible.
      // Définit la décoration du Container, ici une image de fond.
      decoration: const BoxDecoration(
        image: DecorationImage(
          // Charge l'image depuis le dossier 'assets'.
          // IMPORTANT : Assurez-vous que 'assets/images/background.jpg' est déclaré dans pubspec.yaml.
          image: AssetImage('assets/images/background.jpg'),
          // Redimensionne l'image pour couvrir entièrement le Container.
          fit: BoxFit.cover,
        ),
      ),
      // Ajoute un 'Padding' (marge intérieure) autour du contenu.
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 40.0),
        // Utilise 'SingleChildScrollView' pour permettre le défilement vertical
        // si le contenu dépasse la hauteur de l'écran.
        child: SingleChildScrollView(
          // Organise les enfants (widgets) en une colonne verticale.
          child: Column(
            // Aligne les enfants au début (gauche) de l'axe transversal (horizontal).
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Affiche le logo de l'application.
              Image.asset(
                // IMPORTANT : Assurez-vous que 'assets/images/logo.png' est déclaré dans pubspec.yaml.
                'assets/images/logo.png',
                height: 50, // Définit la hauteur de l'image.
                // 'errorBuilder' affiche une icône si l'image ne peut pas être chargée.
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.white, size: 50),
              ),
              // Ajoute un espace vertical fixe entre le logo et le contenu suivant.
              const SizedBox(height: 80),

              // Ajoute un autre espace vertical.
              const SizedBox(height: 40),

              // Centre le contenu principal (titre, sous-titre, boîtes d'info).
              Center(
                child: Column(
                  // Ajuste la taille de la colonne à la taille de ses enfants.
                  mainAxisSize: MainAxisSize.min,
                  // Aligne les enfants au début (gauche) dans cette colonne interne.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Affiche le titre principal.
                    const Text(
                      'Manage your Money\nAnywhere', // Texte avec retour à la ligne.
                      // Style du texte (taille, graisse, couleur, interligne, police).
                      style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 15), // Espace sous le titre.

                    // Affiche le sous-titre.
                    const Text(
                      'View all the analytics and grow your business\nfrom anywhere!',
                      // Utilise la couleur 'lightText' définie dans 'AppColors'.
                      style: TextStyle(fontSize: 16, color: AppColors.lightText, height: 1.5, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 30), // Espace sous le sous-titre.

                    // Utilise 'Wrap' pour afficher les boîtes d'information.
                    // Wrap permet aux éléments de passer à la ligne suivante s'ils ne tiennent pas horizontalement.
                    Wrap(
                      spacing: 20.0, // Espace horizontal entre les boîtes.
                      runSpacing: 20.0, // Espace vertical entre les lignes si les boîtes passent à la ligne.
                      alignment: WrapAlignment.start, // Alignement des boîtes au début.
                      // Liste des boîtes d'information, créées avec la méthode '_buildInfoBox'.
                      children: [
                        _buildInfoBox("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
                        _buildInfoBox("Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
                        _buildInfoBox("Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."),
                      ],
                    )
                  ],
                ),
              ),

              // Espace vertical après le contenu principal.
              const SizedBox(height: 60),

            ],
          ),
        ),
      ),
    );
  }

  // Méthode privée ('_') pour construire une boîte d'information.
  // C'est une bonne pratique pour décomposer la méthode 'build' en parties plus petites et réutilisables.
  Widget _buildInfoBox(String text) {
    // Définit le style du texte à l'intérieur de la boîte.
    const infoTextStyle = TextStyle(color: Colors.white, fontSize: 14, height: 1.6, fontFamily: 'Inter');
    // Retourne un 'Container' stylisé pour la boîte d'info.
    return Container(
      // Padding interne de la boîte.
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
      // Limite la largeur maximale de la boîte.
      constraints: const BoxConstraints(maxWidth: 350),
      // Décoration de la boîte (couleur de fond semi-transparente, coins arrondis).
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35), // Noir avec 35% d'opacité.
        borderRadius: BorderRadius.circular(15.0), // Coins arrondis.
      ),
      // Affiche le texte passé en paramètre, centré et avec le style défini.
      child: Text(text, style: infoTextStyle, textAlign: TextAlign.center),
    );
  }
}