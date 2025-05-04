import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart'; // Importe les couleurs
import '../../../../utils/validators.dart'; // Importe le validateur

// Widget pour la case à cocher Politique de Confidentialité avec validation intégrée
class PrivacyPolicyCheckbox extends StatelessWidget {
  final bool initialValue;
  final ValueChanged<bool?> onChanged;

  const PrivacyPolicyCheckbox({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Récupère le thème pour les styles

    return FormField<bool>(
      initialValue: initialValue,
      validator: validatePrivacyPolicy, // Utilise le validateur importé
      builder: (FormFieldState<bool> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                bool newValue = !state.value!;
                state.didChange(newValue);
                onChanged(newValue);
              },
              child: Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: state.value,
                      onChanged: (newValue) {
                        state.didChange(newValue);
                        onChanged(newValue);
                      },
                      // Utilise la couleur primaire du thème
                      activeColor: theme.colorScheme.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(
                        // Utilise les couleurs de config
                        color: state.hasError ? AppColors.errorRed : AppColors.greyText.withOpacity(0.6),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'I accept the Privacy Policy',
                      // Le style pourrait venir du thème (textTheme.bodySmall)
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Inter',
                        color: state.hasError ? AppColors.errorRed : AppColors.darkText.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Affiche l'erreur si présente
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 6.0),
                child: Text(
                  state.errorText!,
                  // Utilise le style d'erreur du thème si défini
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.errorRed) ??
                         const TextStyle(color: AppColors.errorRed, fontSize: 12, fontFamily: 'Inter'),
                ),
              ),
          ],
        );
      },
    );
  }
}
