import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/config/app_routes.dart';
import 'package:allo_secours/models/service_model.dart';
import 'package:allo_secours/providers/services_provider.dart';
import 'package:allo_secours/utils/mock_data.dart';
import 'package:allo_secours/widgets/custom_app_bar.dart';

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({Key? key}) : super(key: key);

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  List<Service> _pharmacies = [];
  bool _isLoading = true;
  String _sortBy = 'distance';
  bool _showOpenOnly = false;

  @override
  void initState() {
    super.initState();
    _loadPharmacies();
  }

  Future<void> _loadPharmacies() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final provider = context.read<ServicesProvider>();
      await provider.fetchServices(category: 'pharmacy');

      List<Service> list = provider.allServices.isNotEmpty
          ? provider.allServices
          : MockData.getServicesByCategory('pharmacy');

      if (_showOpenOnly) {
        list = list.where((s) => s.isOpen).toList();
      }
      setState(() => _pharmacies = list);
    } catch (_) {
      List<Service> list = MockData.getServicesByCategory('pharmacy');
      if (_showOpenOnly) {
        list = list.where((s) => s.isOpen).toList();
      }
      setState(() => _pharmacies = list);
    } finally {
      _sortPharmacies();
      setState(() => _isLoading = false);
    }
  }

  void _sortPharmacies() {
    if (_sortBy == 'distance') {
      _pharmacies.sort((a, b) => a.distance.compareTo(b.distance));
    } else {
      _pharmacies.sort((a, b) => b.rating.compareTo(a.rating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pharmacies'),
      body: Column(
        children: [
          // Filtres
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_pharmacies.length} pharmacies',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMedium,
                      fontSize: 13,
                    ),
                  ),
                ),
                // Toggle ouvertes seulement
                GestureDetector(
                  onTap: () {
                    setState(() => _showOpenOnly = !_showOpenOnly);
                    _loadPharmacies();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _showOpenOnly
                          ? Colors.green.shade600
                          : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: _showOpenOnly
                              ? Colors.white
                              : AppColors.textMedium,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ouvertes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _showOpenOnly
                                ? Colors.white
                                : AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildSortChip('Distance', 'distance'),
                const SizedBox(width: 6),
                _buildSortChip('Note', 'rating'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pharmacies.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadPharmacies,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _pharmacies.length,
                          itemBuilder: (context, index) {
                            return _buildPharmacyCard(_pharmacies[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = value);
        _sortPharmacies();
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.lightGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacyCard(Service pharmacy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.serviceDetail, arguments: pharmacy),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icône
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  color: AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pharmacy.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: pharmacy.isOpen
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pharmacy.isOpen ? 'Ouvert' : 'Fermé',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: pharmacy.isOpen
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pharmacy.workingHours,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.orange, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          pharmacy.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textLight),
                        Text(
                          ' ${pharmacy.distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_pharmacy_outlined,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            _showOpenOnly
                ? 'Aucune pharmacie ouverte en ce moment'
                : 'Aucune pharmacie trouvée',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if (_showOpenOnly)
            TextButton(
              onPressed: () {
                setState(() => _showOpenOnly = false);
                _loadPharmacies();
              },
              child: const Text('Voir toutes les pharmacies'),
            ),
        ],
      ),
    );
  }
}
