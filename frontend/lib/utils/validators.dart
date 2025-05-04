// Fonctions de validation réutilisables pour les formulaires

String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }
  return null;
}

String? validateDropdown(String? value, String fieldName) {
  if (value == null) {
    return 'Please select $fieldName';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email format';
  }
  return null;
}

String? validatePassword(String? value, {bool checkLength = true}) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (checkLength && value.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}

String? validatePrivacyPolicy(bool? value) {
   if (value == false || value == null) {
     return 'You must accept the privacy policy';
   }
   return null;
}
