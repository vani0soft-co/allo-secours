import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/config/app_routes.dart';
import 'package:allo_secours/models/service_model.dart';
import 'package:allo_secours/providers/services_provider.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({Key? key}) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late Service _service;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Récupère le service passé en argument
    final args = Get.arguments;
    if (args is Service) {
      _service = args;
    } else {
      // Fallback sur un service par défaut
      _service = Service(
        id: '0',
        name: 'Service',
        category: 'hospital',
        address: 'Adresse non disponible',
        latitude: 0,
        longitude: 0,
        phone: '',
        rating: 0,
        reviewCount: 0,
        specialties: [],
        isOpen: false,
        workingHours: 'Non renseigné',
        services: [],
        distance: 0,
      );
    }

    // Vérifier si c'est un favori
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ServicesProvider>();
      setState(() => _isFavorite = provider.isFavorite(_service.id));
    });
  }

  Future<void> _callService() async {
    if (_service.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de téléphone non disponible')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: _service.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appel vers ${_service.phone}')),
        );
      }
    }
  }

  void _toggleFavorite() {
    final provider = context.read<ServicesProvider>();
    provider.toggleFavorite(_service);
    setState(() => _isFavorite = provider.isFavorite(_service.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? '${_service.name} ajouté aux favoris'
              : '${_service.name} retiré des favoris',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openInMaps() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${_service.latitude},${_service.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar avec image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    key: ValueKey(_isFavorite),
                    color: _isFavorite ? Colors.red.shade400 : Colors.white,
                  ),
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.darkBlue],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getCategoryIcon(_service.category),
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom + badge ouverture
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _service.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _service.isOpen
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _service.isOpen
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          _service.isOpen ? 'Ouvert' : 'Fermé',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: _service.isOpen
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Note et catégorie
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        _service.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' (${_service.reviewCount} avis)',
                        style: const TextStyle(color: AppColors.textLight),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _service.categoryLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Infos rapides
                  _buildInfoRow(
                    icon: Icons.location_on_rounded,
                    color: Colors.red,
                    label: _service.address.isNotEmpty
                        ? _service.address
                        : 'Adresse non renseignée',
                  ),
                  if (_service.phone.isNotEmpty)
                    _buildInfoRow(
                      icon: Icons.phone_rounded,
                      color: Colors.green,
                      label: _service.phone,
                      onTap: _callService,
                      isLink: true,
                    ),
                  _buildInfoRow(
                    icon: Icons.access_time_rounded,
                    color: Colors.orange,
                    label: _service.workingHours.isNotEmpty
                        ? _service.workingHours
                        : 'Horaires non renseignés',
                  ),
                  _buildInfoRow(
                    icon: Icons.straighten_rounded,
                    color: Colors.blue,
                    label: '${_service.distance.toStringAsFixed(1)} km de vous',
                  ),

                  // Description
                  if (_service.description != null &&
                      _service.description!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _service.description!,
                      style: const TextStyle(
                        color: AppColors.textMedium,
                        height: 1.5,
                      ),
                    ),
                  ],

                  // Spécialités
                  if (_service.specialties.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Spécialités',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _service.specialties.map((spec) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            spec,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openInMaps,
                          icon: const Icon(Icons.directions_rounded),
                          label: const Text('Itinéraire'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _service.phone.isNotEmpty ? _callService : null,
                          icon: const Icon(Icons.phone_rounded),
                          label: const Text('Appeler'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed(
                        AppRoutes.myOpinion,
                        arguments: _service,
                      ),
                      icon: const Icon(Icons.star_outline_rounded),
                      label: const Text('Laisser un avis'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color color,
    required String label,
    VoidCallback? onTap,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isLink ? AppColors.primary : AppColors.textMedium,
                    fontWeight:
                        isLink ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                    decoration:
                        isLink ? TextDecoration.underline : TextDecoration.none,
                  ),
                ),
              ),
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
}
