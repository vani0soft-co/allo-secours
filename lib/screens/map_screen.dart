import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/config/app_routes.dart';
import 'package:allo_secours/models/service_model.dart';
import 'package:allo_secours/providers/location_provider.dart';
import 'package:allo_secours/providers/services_provider.dart';
import 'package:allo_secours/utils/mock_data.dart';
import 'package:allo_secours/widgets/custom_app_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Service> _services = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  final List<_CategoryFilter> _categories = const [
    _CategoryFilter('all', 'Tous', Icons.grid_view_rounded, Colors.blueGrey),
    _CategoryFilter('hospital', 'Hôpitaux', Icons.local_hospital_rounded, AppColors.primary),
    _CategoryFilter('pharmacy', 'Pharmacies', Icons.local_pharmacy_rounded, AppColors.secondary),
    _CategoryFilter('emergency', 'Urgences', Icons.emergency_rounded, Colors.red),
    _CategoryFilter('specialist', 'Spécialistes', Icons.person_rounded, Colors.blue),
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<ServicesProvider>();
      await provider.fetchServices();
      setState(() {
        _services = provider.allServices.isNotEmpty
            ? provider.allServices
            : MockData.mockServices;
      });
    } catch (_) {
      setState(() => _services = MockData.mockServices);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Service> get _filteredServices => _selectedCategory == 'all'
      ? _services
      : _services.where((s) => s.category == _selectedCategory).toList();

  Future<void> _openInMaps(Service service) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${service.latitude},${service.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Services à proximité'),
      body: Column(
        children: [
          // Bannière info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.primary.withValues(alpha: 0.08),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cliquez sur "Itinéraire" pour ouvrir Google Maps',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),

          // Filtres catégories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? cat.color : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? cat.color : AppColors.dividerGray,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 14,
                              color: isSelected ? Colors.white : cat.color),
                          const SizedBox(width: 6),
                          Text(cat.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textDark,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Localisation actuelle
          Consumer<LocationProvider>(
            builder: (context, loc, _) {
              if (loc.currentLocation != null) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: loc.isSimulated ? Colors.orange.shade50 : Colors.green.shade50,
                  child: Row(
                    children: [
                      Icon(
                        loc.isSimulated ? Icons.location_searching : Icons.my_location_rounded,
                        size: 13,
                        color: loc.isSimulated ? Colors.orange.shade700 : Colors.green.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          loc.isSimulated
                              ? 'Position simulée : ${loc.currentLocation!.address}'
                              : 'Position : ${loc.currentLocation!.latitude.toStringAsFixed(4)}, '
                                '${loc.currentLocation!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: loc.isSimulated ? Colors.orange.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (loc.error != null) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.red.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.location_off, size: 14, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.error!,
                          style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                        ),
                      ),
                      TextButton(
                        onPressed: () => loc.useSimulatedLocation(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Simuler', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => context.read<LocationProvider>().getCurrentLocation(),
                    icon: const Icon(Icons.my_location, size: 14),
                    label: const Text('Ma position', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: () => context.read<LocationProvider>().useSimulatedLocation(),
                    icon: const Icon(Icons.location_searching, size: 14),
                    label: const Text('Simuler Paris', style: TextStyle(fontSize: 12)),
                  ),
                ],
              );
            },
          ),

          // Liste des services
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredServices.isEmpty
                    ? const Center(child: Text('Aucun service trouvé'))
                    : RefreshIndicator(
                        onRefresh: _loadServices,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredServices.length,
                          itemBuilder: (context, index) {
                            return _buildServiceCard(_filteredServices[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
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
                  color: _categoryColor(service.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_categoryIcon(service.category),
                    color: _categoryColor(service.category), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(service.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
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
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(service.address,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMedium),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.orange, size: 13),
                        Text(' ${service.rating.toStringAsFixed(1)}',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textLight),
                        Text(' ${service.distance.toStringAsFixed(1)} km',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textLight)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.directions_rounded,
                        color: Colors.green, size: 22),
                    tooltip: 'Itinéraire',
                    onPressed: () => _openInMaps(service),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: AppColors.textLight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'hospital': return Icons.local_hospital_rounded;
      case 'pharmacy': return Icons.local_pharmacy_rounded;
      case 'emergency': return Icons.emergency_rounded;
      case 'specialist': return Icons.person_rounded;
      default: return Icons.place_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'hospital': return AppColors.primary;
      case 'pharmacy': return AppColors.secondary;
      case 'emergency': return Colors.red;
      case 'specialist': return Colors.blue;
      default: return Colors.teal;
    }
  }
}

class _CategoryFilter {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _CategoryFilter(this.value, this.label, this.icon, this.color);
}
