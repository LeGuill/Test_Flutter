import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart'; // Importe les couleurs

// Widget réutilisable pour un menu déroulant stylisé
class CustomDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Utilise le thème global pour le style de base
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            // Le style pourrait venir du thème
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.darkText),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      // Style du texte sélectionné
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.darkText),
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.greyText),
      // L'InputDecoration hérite du thème global
      decoration: InputDecoration(
        hintText: hint,
        // Les autres styles (fillColor, borders, padding, hintStyle)
        // sont définis dans le thème global (main.dart)
      ),
      isExpanded: true,
    );
  }
}
