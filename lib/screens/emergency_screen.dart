import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/config/app_routes.dart';
import 'package:allo_secours/models/service_model.dart';
import 'package:allo_secours/providers/location_provider.dart';
import 'package:allo_secours/providers/services_provider.dart';
import 'package:allo_secours/utils/mock_data.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  List<Service> _emergencyServices = [];
  bool _isLoading = true;

  // Animation pulse
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadEmergencyServices();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadEmergencyServices() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<ServicesProvider>();
      await provider.fetchServices(category: 'emergency');
      if (provider.allServices.isNotEmpty) {
        setState(() => _emergencyServices = provider.allServices);
      } else {
        setState(() =>
            _emergencyServices = MockData.getServicesByCategory('emergency'));
      }
    } catch (_) {
      setState(
          () => _emergencyServices = MockData.getServicesByCategory('emergency'));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) _showCallDialog(number);
    }
  }

  void _showCallDialog(String number) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Appeler le secours',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.emergencyGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_in_talk_rounded,
                  size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.emergency,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Confirmez l\'appel d\'urgence',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.textMedium,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(color: AppColors.textMedium),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.emergencyGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Appel vers $number en cours...',
                            style: GoogleFonts.poppins()),
                      ],
                    ),
                    backgroundColor: AppColors.emergency,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: const Icon(Icons.phone, size: 16),
              label: Text('Appeler', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ─── AppBar gradient rouge ──────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.emergencyGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'URGENCES',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Consumer<LocationProvider>(
                    builder: (context, loc, _) => Row(
                      children: [
                        Icon(
                          loc.currentLocation != null
                              ? Icons.location_on
                              : Icons.location_off,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          loc.currentLocation != null
                              ? 'Localisé'
                              : 'Non localisé',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          // ─── Bannière info ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.emergency.withValues(alpha: 0.08),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.emergency, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'En cas de danger immédiat au Bénin, appelez le 13 (SAMU) ou le 18 (Pompiers)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.emergency,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── 3 gros boutons d'appel ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildCallCard(
                    label: 'SAMU',
                    number: '13',
                    icon: Icons.local_hospital_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF233C), Color(0xFFFF6B6B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    description: 'Urgences médicales',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCallCard(
                    label: 'Pompiers',
                    number: '18',
                    icon: Icons.fire_truck_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    description: 'Incendie & secours',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCallCard(
                    label: 'Police',
                    number: '117',
                    icon: Icons.local_police_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A2463), Color(0xFF3E92CC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    description: 'Sécurité & ordre',
                  ),
                ),
              ],
            ),
          ),

          // ─── Section conseils d'urgence ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dividerGray),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.lightbulb_rounded,
                            color: AppColors.accent, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Conseils d\'urgence',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...[
                    'Restez calme et précisez votre localisation exacte.',
                    'Ne raccrochèz pas avant que le secouriste vous le dise.',
                    'En cas d\'arrêt cardiaque, pratiquez le massage cardiaque.',
                  ].map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.secondary, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textMedium,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),

          // ─── Titre liste urgences ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Services d\'urgence à proximité',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),

          // ─── Liste des urgences ──────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.emergency,
                      strokeWidth: 2.5,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadEmergencyServices,
                    color: AppColors.emergency,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _emergencyServices.isEmpty
                          ? 1
                          : _emergencyServices.length,
                      itemBuilder: (context, index) {
                        if (_emergencyServices.isEmpty) {
                          return _buildDefaultEmergencyList();
                        }
                        return _buildEmergencyCard(_emergencyServices[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Card d'appel principal avec animation pulse ──────────────────────────
  Widget _buildCallCard({
    required String label,
    required String number,
    required IconData icon,
    required LinearGradient gradient,
    required String description,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _callNumber(number),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.40),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.80),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(Service service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerGray),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.serviceDetail, arguments: service),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.emergencyGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emergency_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.address,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textMedium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.emergency.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            service.workingHours,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.emergency,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.mediumGray),
                        Text(
                          ' ${service.distance.toStringAsFixed(1)} km',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.phone_rounded,
                      color: AppColors.secondary, size: 18),
                  onPressed: () => _callNumber(service.phone),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultEmergencyList() {
    final items = [
      {
        'name': 'SAMU Bénin – Aide Médicale Urgente',
        'number': '13',
        'dist': '0 km',
      },
      {'name': 'Pompiers', 'number': '18', 'dist': '1.2 km'},
      {
        'name': 'Police Nationale',
        'number': '117',
        'dist': '1.8 km',
      },
    ];
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.dividerGray),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.emergencyGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.emergency_rounded,
                  color: Colors.white, size: 20),
            ),
            title: Text(
              item['name']!,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textDark,
              ),
            ),
            subtitle: Text(
              item['dist']!,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
            trailing: GestureDetector(
              onTap: () => _callNumber(item['number']!),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.emergencyGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      item['number']!,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
