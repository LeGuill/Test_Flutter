import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart'; // Importe les couleurs

// Widget pour le sélecteur Merchant/Agent
class UserTypeToggle extends StatelessWidget {
  final String selectedUserType;
  final ValueChanged<String> onUserTypeChanged;

  const UserTypeToggle({
    super.key,
    required this.selectedUserType,
    required this.onUserTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.toggleButtonBackground, // Utilise couleur config
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          _buildToggleButton(context, 'Merchant', 'merchant'),
          const SizedBox(width: 4),
          _buildToggleButton(context, 'Agent', 'agent'),
        ],
      ),
    );
  }

  // Méthode helper interne pour construire chaque bouton
  Widget _buildToggleButton(BuildContext context, String text, String value) {
    bool isSelected = selectedUserType == value;
    // Utilise le thème pour le style de base, surcharge les couleurs
    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: isSelected ? Colors.black : Colors.transparent,
      foregroundColor: isSelected ? Colors.white : AppColors.darkText,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shadowColor: Colors.transparent,
      // Le textStyle est hérité du ElevatedButtonTheme de main.dart
    );

    return Expanded(
      child: ElevatedButton(
        onPressed: () => onUserTypeChanged(value),
        style: style,
        child: Text(text), // Le style du texte vient du thème
      ),
    );
  }
}
