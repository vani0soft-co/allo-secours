import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/config/app_routes.dart';
import 'package:allo_secours/widgets/custom_app_bar.dart';

class MySearchesScreen extends StatefulWidget {
  const MySearchesScreen({Key? key}) : super(key: key);

  @override
  State<MySearchesScreen> createState() => _MySearchesScreenState();
}

class _MySearchesScreenState extends State<MySearchesScreen> {
  List<_SearchEntry> _history = [];
  bool _isLoading = true;

  static const String _prefsKey = 'search_history';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    setState(() {
      _history = raw.map((e) {
        final parts = e.split('|');
        return _SearchEntry(
          query: parts[0],
          timestamp: parts.length > 1
              ? DateTime.tryParse(parts[1]) ?? DateTime.now()
              : DateTime.now(),
        );
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _isLoading = false;
    });
  }

  Future<void> _deleteEntry(_SearchEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    raw.removeWhere((e) => e.startsWith('${entry.query}|'));
    await prefs.setStringList(_prefsKey, raw);
    setState(() => _history.remove(entry));
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Effacer l\'historique'),
        content:
            const Text('Voulez-vous supprimer tout votre historique de recherche ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tout effacer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      setState(() => _history.clear());
    }
  }

  void _searchAgain(String query) {
    Get.toNamed(AppRoutes.services, arguments: {'query': query});
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mes recherches',
        actions: _history.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded,
                      color: Colors.white),
                  tooltip: 'Tout effacer',
                  onPressed: _clearAll,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final entry = _history[index];
                      return _buildHistoryTile(entry);
                    },
                  ),
                ),
    );
  }

  Widget _buildHistoryTile(_SearchEntry entry) {
    return Dismissible(
      key: Key(entry.query + entry.timestamp.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade100,
        child: Icon(Icons.delete_rounded, color: Colors.red.shade700),
      ),
      onDismissed: (_) => _deleteEntry(entry),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.history_rounded,
              color: AppColors.primary, size: 18),
        ),
        title: Text(
          entry.query,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(
          _formatDate(entry.timestamp),
          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.north_west_rounded,
              size: 16, color: AppColors.textLight),
          tooltip: 'Relancer la recherche',
          onPressed: () => _searchAgain(entry.query),
        ),
        onTap: () => _searchAgain(entry.query),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Aucune recherche récente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vos recherches apparaîtront ici',
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.services),
            icon: const Icon(Icons.search_rounded),
            label: const Text('Rechercher un service'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Utilitaire statique pour sauvegarder une recherche depuis n'importe quel écran
class SearchHistory {
  static Future<void> save(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('search_history') ?? [];
    // Éviter les doublons récents
    raw.removeWhere((e) => e.startsWith('$query|'));
    raw.insert(0, '$query|${DateTime.now().toIso8601String()}');
    // Garder seulement les 50 dernières recherches
    if (raw.length > 50) raw.removeLast();
    await prefs.setStringList('search_history', raw);
  }
}

class _SearchEntry {
  final String query;
  final DateTime timestamp;

  _SearchEntry({required this.query, required this.timestamp});
}
