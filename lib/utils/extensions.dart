extension StringExtension on String {
  /// Capitalise la première lettre
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Vérifie si c'est un email valide
  bool isValidEmail() {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Vérifie si c'est un numéro de téléphone valide
  bool isValidPhone() {
    return RegExp(
      r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$',
    ).hasMatch(this);
  }
}

extension DoubleExtension on double {
  /// Arrondit à n décimales
  double roundToDecimal(int decimal) {
    int mod = 10 ^ decimal;
    return ((this * mod).round().toDouble() / mod);
  }

  /// Formate en km
  String toKmString() {
    return '${roundToDecimal(1)} km';
  }
}

extension DateTimeExtension on DateTime {
  /// Formate la date en format lisible
  String toFormattedString() {
    return '$day/$month/$year ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Vérifie si c'est aujourd'hui
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
