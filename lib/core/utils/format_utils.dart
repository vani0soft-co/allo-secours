import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();

  static String formatPrice(double amount, {String currency = 'FCFA'}) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(amount)} $currency';
  }

  static String formatPriceCompact(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K FCFA';
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  static String formatWeight(double kg) =>
      kg < 1 ? '${(kg * 1000).toStringAsFixed(0)} g' : '${kg.toStringAsFixed(1)} kg';

  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 8) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6)}';
    }
    return phone;
  }

  static String capitalize(String text) =>
      text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';

  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  static String truncate(String text, int maxLength) =>
      text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';

  static String generateTrackingCode() {
    final now = DateTime.now();
    final suffix = now.millisecondsSinceEpoch.toString().substring(7);
    return 'LGT${now.year}$suffix'.toUpperCase();
  }
}