class Validators {
  Validators._();

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName est obligatoire' : 'Ce champ est obligatoire';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'email est obligatoire';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Adresse email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est obligatoire';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirmez le mot de passe';
    if (value != original) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le téléphone est obligatoire';
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 8) return 'Numéro de téléphone invalide';
    return null;
  }

  static String? positiveNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Ce champ'} est obligatoire';
    }
    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null) return 'Valeur numérique invalide';
    if (number <= 0) return 'La valeur doit être supérieure à 0';
    return null;
  }

  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final v in validators) {
      final result = v(value);
      if (result != null) return result;
    }
    return null;
  }
}