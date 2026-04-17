import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/config/app_routes.dart';
import 'package:allo_secours/models/service_model.dart';
import 'package:allo_secours/providers/services_provider.dart';
import 'package:allo_secours/screens/my_searches_screen.dart';
import 'package:allo_secours/widgets/custom_app_bar.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _activeCategory;
  String _sortBy = 'distance';

  final List<_FilterChip> _categoryFilters = const [
    _FilterChip('hospital', 'Hôpitaux', Icons.local_hospital_rounded),
    _FilterChip('pharmacy', 'Pharmacies', Icons.local_pharmacy_rounded),
    _FilterChip('specialist', 'Spécialistes', Icons.person_rounded),
    _FilterChip('emergency', 'Urgences', Icons.emergency_rounded),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>?;
      final query = args?['query'] as String?;
      final category = args?['category'] as String?;

      if (query != null && query.isNotEmpty) {
        _searchController.text = query;
      }
      if (category != null) {
        _activeCategory = category;
      }

      context.read<ServicesProvider>().fetchServices(
            category: _activeCategory,
            searchQuery:
                _searchController.text.isNotEmpty ? _searchController.text : null,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String value) async {
    context.read<ServicesProvider>().filterServices(value);
    if (value.trim().length >= 3) {
      await SearchHistory.save(value.trim());
    }
  }

  void _onSearchSubmit(String value) {
    if (value.trim().isNotEmpty) {
      SearchHistory.save(value.trim());
      context.read<ServicesProvider>().filterServices(value);
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      _activeCategory = _activeCategory == category ? null : category;
    });
    context.read<ServicesProvider>().fetchServices(
          category: _activeCategory,
          searchQuery: _searchController.text.isNotEmpty
              ? _searchController.text
              : null,
        );
  }

  void _applySort() {
    final provider = context.read<ServicesProvider>();
    if (_sortBy == 'distance') {
      provider.sortByDistance();
    } else {
      provider.sortByRating();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Services',
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white),
            onPressed: _showSortSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmit,
              decoration: InputDecoration(
                hintText: 'Rechercher un service...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ServicesProvider>().filterServices('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filtres de catégories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _categoryFilters.map((filter) {
                final isActive = _activeCategory == filter.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _toggleCategory(filter.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.dividerGray,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            filter.icon,
                            size: 14,
                            color: isActive ? Colors.white : AppColors.textMedium,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            filter.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Liste des services
          Consumer<ServicesProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (provider.error != null && provider.filteredServices.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text('Impossible de charger les services',
                            style: TextStyle(color: AppColors.textMedium)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => provider.fetchServices(
                              category: _activeCategory),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (provider.filteredServices.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text('Aucun service trouvé',
                            style: TextStyle(color: AppColors.textMedium)),
                        if (_activeCategory != null)
                          TextButton(
                            onPressed: () {
                              setState(() => _activeCategory = null);
                              provider.fetchServices();
                            },
                            child: const Text('Effacer les filtres'),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      provider.fetchServices(category: _activeCategory),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    itemCount: provider.filteredServices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final service = provider.filteredServices[index];
                      return _buildServiceCard(service, provider);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Service service, ServicesProvider provider) {
    final isFav = provider.isFavorite(service.id);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.serviceDetail, arguments: service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor(service.category)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(service.category),
                  color: _getCategoryColor(service.category),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service.address,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMedium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.orange, size: 13),
                        Text(
                          ' ${service.rating.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: service.isOpen
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            service.isOpen ? 'Ouvert' : 'Fermé',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: service.isOpen
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${service.distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav ? Colors.red : AppColors.textLight,
                  size: 20,
                ),
                onPressed: () => provider.toggleFavorite(service),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.dividerGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Trier par',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.location_on_rounded),
              title: const Text('Distance'),
              trailing: _sortBy == 'distance'
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'distance');
                _applySort();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rounded),
              title: const Text('Note'),
              trailing: _sortBy == 'rating'
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'rating');
                _applySort();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'pharmacy':
        return Icons.local_pharmacy_rounded;
      case 'emergency':
        return Icons.emergency_rounded;
      case 'specialist':
        return Icons.person_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'hospital':
        return AppColors.primary;
      case 'pharmacy':
        return AppColors.secondary;
      case 'emergency':
        return Colors.red;
      case 'specialist':
        return Colors.blue;
      default:
        return Colors.teal;
    }
  }
}

class _FilterChip {
  final String value;
  final String label;
  final IconData icon;

  const _FilterChip(this.value, this.label, this.icon);
}
