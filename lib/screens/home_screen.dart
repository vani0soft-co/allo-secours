import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/config/app_routes.dart';
import 'package:allo_secours/providers/auth_provider.dart';
import 'package:allo_secours/providers/location_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _carouselController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentNavIndex = 0;

  final List<_CarouselItem> _carouselItems = const [
    _CarouselItem(
      title: 'Urgences 24h/24',
      subtitle: 'Des services d\'urgence disponibles\nà toute heure',
      gradient: AppColors.emergencyGradient,
      icon: Icons.emergency_rounded,
    ),
    _CarouselItem(
      title: 'Trouvez une pharmacie',
      subtitle: 'Plus de 500 pharmacies\nrépertoriées près de vous',
      gradient: AppColors.greenGradient,
      icon: Icons.local_pharmacy_rounded,
    ),
    _CarouselItem(
      title: 'Consultez un spécialiste',
      subtitle: 'Prenez rendez-vous facilement\navec nos médecins partenaires',
      gradient: AppColors.primaryGradient,
      icon: Icons.medical_services_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String query) {
    if (query.trim().isEmpty) return;
    Get.toNamed(AppRoutes.services, arguments: {'query': query.trim()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── SliverAppBar avec gradient ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Row: greeting + notifications ───────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bonjour, ${auth.userName.split(' ').first} \u{1F44B}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Consumer<LocationProvider>(
                                    builder: (context, loc, _) => Row(
                                      children: [
                                        Icon(
                                          loc.currentLocation != null
                                              ? Icons.location_on_rounded
                                              : Icons.location_off_rounded,
                                          size: 12,
                                          color: Colors.white.withValues(
                                              alpha: 0.75),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          loc.currentLocation != null
                                              ? 'Position activée'
                                              : 'Activez votre localisation',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.white.withValues(
                                                alpha: 0.75),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _buildAppBarAction(
                                  icon: Icons.notifications_outlined,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Aucune nouvelle notification'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildAppBarAction(
                                  icon: Icons.person_outline_rounded,
                                  onTap: () =>
                                      Get.toNamed(AppRoutes.profile),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ─── Barre de recherche ───────────────────────────
                        Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.darkBlue.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: _onSearchSubmit,
                            onChanged: (value) {
                              setState(() {});
                              if (value.length >= 3) _onSearchSubmit(value);
                            },
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Hôpital, pharmacie, spécialiste...',
                              hintStyle: GoogleFonts.poppins(
                                color: AppColors.mediumGray,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.primaryLight,
                                size: 20,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      color: AppColors.mediumGray,
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Carrousel ────────────────────────────────────────────
                const SizedBox(height: 20),
                SizedBox(
                  height: 160,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _carouselController,
                        itemCount: _carouselItems.length,
                        itemBuilder: (context, index) {
                          return _buildCarouselCard(_carouselItems[index]);
                        },
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _carouselController,
                            count: _carouselItems.length,
                            effect: const ExpandingDotsEffect(
                              dotHeight: 6,
                              dotWidth: 6,
                              activeDotColor: Colors.white,
                              dotColor: Colors.white38,
                              expansionFactor: 3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Bannière urgences ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.emergency),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFF0F1),
                            Color(0xFFFFE5E8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              AppColors.emergency.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.emergency.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emergency_rounded,
                              color: AppColors.emergency,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Urgence médicale ?',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.emergency,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Appelez le 15 ou accédez aux urgences',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.emergency
                                        .withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.emergency.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Section : Nos services ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nos services',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.services),
                        child: Text(
                          'Voir tout',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ─── Grille 2×2 catégories principales ───────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildCategoryCard(
                        icon: Icons.local_hospital_rounded,
                        label: 'Hôpitaux',
                        gradient: AppColors.primaryGradient,
                        onTap: () => Get.toNamed(AppRoutes.hospitals),
                      ),
                      _buildCategoryCard(
                        icon: Icons.local_pharmacy_rounded,
                        label: 'Pharmacies',
                        gradient: AppColors.greenGradient,
                        onTap: () => Get.toNamed(AppRoutes.pharmacies),
                      ),
                      _buildCategoryCard(
                        icon: Icons.emergency_rounded,
                        label: 'Urgences',
                        gradient: AppColors.emergencyGradient,
                        onTap: () => Get.toNamed(AppRoutes.emergency),
                      ),
                      _buildCategoryCard(
                        icon: Icons.person_rounded,
                        label: 'Spécialistes',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => Get.toNamed(AppRoutes.services,
                            arguments: {'category': 'specialist'}),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Section : Services proches (scroll horizontal) ───────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Services proches',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildNearbyChip(
                        icon: Icons.medication_rounded,
                        label: 'Médicaments',
                        color: Colors.orange,
                        onTap: () => Get.toNamed(AppRoutes.services,
                            arguments: {'category': 'medication'}),
                      ),
                      _buildNearbyChip(
                        icon: Icons.calendar_today_rounded,
                        label: 'Rendez-vous',
                        color: Colors.purple,
                        onTap: () => Get.toNamed(AppRoutes.services,
                            arguments: {'category': 'appointment'}),
                      ),
                      _buildNearbyChip(
                        icon: Icons.image_rounded,
                        label: 'Imagerie',
                        color: Colors.teal,
                        onTap: () => Get.toNamed(AppRoutes.services,
                            arguments: {'category': 'imaging'}),
                      ),
                      _buildNearbyChip(
                        icon: Icons.history_rounded,
                        label: 'Historique',
                        color: Colors.cyan,
                        onTap: () => Get.toNamed(AppRoutes.mySearches),
                      ),
                      _buildNearbyChip(
                        icon: Icons.star_rounded,
                        label: 'Votre avis',
                        color: Colors.amber,
                        onTap: () => Get.toNamed(AppRoutes.myOpinion),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Section : Infos santé ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Infos santé',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildHealthTip(
                          icon: Icons.water_drop_rounded,
                          title: 'Hydratation',
                          tip: 'Buvez au moins 1,5 L d\'eau par jour.',
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHealthTip(
                          icon: Icons.directions_walk_rounded,
                          title: 'Activité',
                          tip: '30 min de marche par jour bénéficient au cœur.',
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),

      // ─── BottomNavigationBar ─────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentNavIndex,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryLight.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            setState(() => _currentNavIndex = index);
            switch (index) {
              case 0:
                break;
              case 1:
                Get.toNamed(AppRoutes.map);
                break;
              case 2:
                Get.toNamed(AppRoutes.emergency);
                break;
              case 3:
                Get.toNamed(AppRoutes.profile);
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined,
                  color: AppColors.mediumGray),
              selectedIcon: const Icon(Icons.home_rounded,
                  color: AppColors.primaryLight),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined,
                  color: AppColors.mediumGray),
              selectedIcon: const Icon(Icons.map_rounded,
                  color: AppColors.primaryLight),
              label: 'Carte',
            ),
            NavigationDestination(
              icon: const Icon(Icons.emergency_outlined,
                  color: AppColors.mediumGray),
              selectedIcon: const Icon(Icons.emergency_rounded,
                  color: AppColors.emergency),
              label: 'Urgences',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded,
                  color: AppColors.mediumGray),
              selectedIcon: const Icon(Icons.person_rounded,
                  color: AppColors.primaryLight),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers UI ──────────────────────────────────────────────────────────

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCarouselCard(_CarouselItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: item.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.80),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              item.icon,
              size: 64,
              color: Colors.white.withValues(alpha: 0.20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTip({
    required IconData icon,
    required String title,
    required String tip,
    required Color color,
  }) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tip,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Modèle carrousel ─────────────────────────────────────────────────────────
class _CarouselItem {
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;

  const _CarouselItem({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });
}
