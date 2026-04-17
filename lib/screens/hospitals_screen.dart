import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/config/app_routes.dart';
import 'package:allo_secours/models/service_model.dart';
import 'package:allo_secours/providers/location_provider.dart';
import 'package:allo_secours/providers/services_provider.dart';
import 'package:allo_secours/utils/mock_data.dart';
import 'package:allo_secours/widgets/custom_app_bar.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({Key? key}) : super(key: key);

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  List<Service> _hospitals = [];
  bool _isLoading = true;
  String? _error;
  String _sortBy = 'distance'; // 'distance' | 'rating'

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Essai de chargement depuis l'API
      final provider = context.read<ServicesProvider>();
      await provider.fetchServices(category: 'hospital');

      if (provider.allServices.isNotEmpty) {
        setState(() {
          _hospitals = provider.allServices;
        });
      } else {
        // Fallback sur MockData
        setState(() {
          _hospitals = MockData.getServicesByCategory('hospital');
        });
      }
    } catch (_) {
      // En cas d'erreur, utiliser MockData
      setState(() {
        _hospitals = MockData.getServicesByCategory('hospital');
      });
    } finally {
      _sortHospitals();
      setState(() => _isLoading = false);
    }
  }

  void _sortHospitals() {
    if (_sortBy == 'distance') {
      _hospitals.sort((a, b) => a.distance.compareTo(b.distance));
    } else {
      _hospitals.sort((a, b) => b.rating.compareTo(a.rating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Hôpitaux'),
      body: Column(
        children: [
          // Barre de filtres
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Consumer<LocationProvider>(
                  builder: (context, loc, _) => Expanded(
                    child: Text(
                      loc.currentLocation != null
                          ? '${_hospitals.length} hôpitaux trouvés'
                          : '${_hospitals.length} hôpitaux',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                _buildSortChip('Distance', 'distance'),
                const SizedBox(width: 8),
                _buildSortChip('Note', 'rating'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _hospitals.isEmpty
                    ? _buildError()
                    : RefreshIndicator(
                        onRefresh: _loadHospitals,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _hospitals.length,
                          itemBuilder: (context, index) {
                            return _buildHospitalCard(_hospitals[index]);
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
        _sortHospitals();
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.lightGray,
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

  Widget _buildHospitalCard(Service hospital) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.serviceDetail, arguments: hospital),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hospital.name,
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
                            color: hospital.isOpen
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            hospital.isOpen ? 'Ouvert' : 'Fermé',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: hospital.isOpen
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hospital.address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.orange, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          hospital.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' (${hospital.reviewCount} avis)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textLight),
                        Text(
                          ' ${hospital.distance.toStringAsFixed(1)} km',
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

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Connexion impossible',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadHospitals,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
