import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart'; // Importe les couleurs

// Widget pour le lien "Already have an account? Log In"
class LoginLink extends StatelessWidget {
  final VoidCallback onLoginTap; // Callback quand "Log In" est cliqué

  const LoginLink({
    super.key,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    // Utilise le thème pour les styles de texte par défaut
    final textTheme = Theme.of(context).textTheme;
    final defaultStyle = textTheme.bodyMedium?.copyWith(color: AppColors.greyText) ??
                         const TextStyle(color: AppColors.greyText, fontSize: 14, fontFamily: 'Inter');
    final linkStyle = textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryRed, // Utilise couleur config
                          fontWeight: FontWeight.w600,
                        ) ??
                        const TextStyle(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          fontSize: 14,
                        );

    return Text.rich(
      TextSpan(
        text: 'Already have an account ? ',
        style: defaultStyle,
        children: <TextSpan>[
          TextSpan(
            text: 'Log In',
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = onLoginTap, // Appelle le callback
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
