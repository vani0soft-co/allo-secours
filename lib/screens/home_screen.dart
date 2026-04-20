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
  int _selectedNavIndex = 0;

  // ── Slides du carrousel ────────────────────────────────────────────────
  final List<_CarouselSlide> _slides = const [
    _CarouselSlide(
      title: 'Recherchez vos produits',
      bold: 'PHARMACEUTIQUES',
      suffix: 'sur Allô Secours.',
      emoji: '💊',
      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
    ),
    _CarouselSlide(
      title: 'Trouvez un',
      bold: 'HÔPITAL',
      suffix: 'près de chez vous.',
      emoji: '🏥',
      colors: [Color(0xFF0A2463), Color(0xFF3E92CC)],
    ),
    _CarouselSlide(
      title: 'Appelez les',
      bold: 'URGENCES',
      suffix: 'en un clic.',
      emoji: '🚑',
      colors: [Color(0xFFB71C1C), Color(0xFFEF5350)],
    ),
    _CarouselSlide(
      title: 'Prenez',
      bold: 'RENDEZ-VOUS',
      suffix: 'avec un spécialiste.',
      emoji: '📅',
      colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
    ),
  ];

  // ── Catégories de la grille ────────────────────────────────────────────
  final List<_Category> _categories = const [
    _Category(label: 'Hôpitaux', emoji: '🏥', route: AppRoutes.hospitals),
    _Category(label: 'Pharmacies', emoji: '🧑‍⚕️', route: AppRoutes.pharmacies),
    _Category(label: 'Médicaments', emoji: '💊', route: AppRoutes.pharmacies),
    _Category(label: 'Spécialistes', emoji: '👨‍⚕️', route: AppRoutes.services),
    _Category(label: 'Rendez-vous', emoji: '📅', route: null),
    _Category(label: 'Urgences', emoji: '🚑', route: AppRoutes.emergency),
    _Category(label: 'Imag/Radio', emoji: '🩻', route: null),
    _Category(label: 'Discutez', emoji: '💬', route: AppRoutes.myOpinion),
    _Category(label: 'Votre avis', emoji: '⭐', route: AppRoutes.myOpinion),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = context.read<LocationProvider>();
      if (!loc.hasLocation) {
        loc.useSimulatedLocation();
      }
    });
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _selectedNavIndex = index);
    switch (index) {
      case 0:
        break; // home déjà affiché
      case 1:
        Get.toNamed(AppRoutes.mySearches);
        break;
      case 2:
        Get.toNamed(AppRoutes.profile);
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notifications bientôt disponibles',
                style: GoogleFonts.poppins()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        break;
    }
  }

  void _onCategoryTap(_Category cat) {
    if (cat.route != null) {
      Get.toNamed(cat.route!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cat.label} — bientôt disponible',
              style: GoogleFonts.poppins()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final firstName = auth.userName.split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: _buildDrawer(auth),

      // ─── AppBar ────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'Bonjour $firstName !',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),

      // ─── Corps ─────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carrousel
            _buildCarousel(),

            // Indicateur de page
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SmoothPageIndicator(
                controller: _carouselController,
                count: _slides.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primary,
                  dotColor: Colors.grey.shade300,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                ),
              ),
            ),

            // Grille des catégories 3×3
            _buildCategoryGrid(),

            // Barre verte décorative
            Container(
              height: 6,
              color: AppColors.secondary,
            ),
          ],
        ),
      ),

      // ─── Bottom Navigation ─────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Carrousel ────────────────────────────────────────────────────────────
  Widget _buildCarousel() {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: _carouselController,
        itemCount: _slides.length,
        onPageChanged: (i) => setState(() {}),
        itemBuilder: (context, i) => _buildSlide(_slides[i]),
      ),
    );
  }

  Widget _buildSlide(_CarouselSlide slide) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Texte à gauche
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slide.title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF555555),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  slide.bold,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF111111),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'sur ',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF555555),
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: 'Allô Secours.',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Emoji/image à droite
          Text(
            slide.emoji,
            style: const TextStyle(fontSize: 80),
          ),
        ],
      ),
    );
  }

  // ── Grille 3×3 ───────────────────────────────────────────────────────────
  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, i) => _buildCategoryCard(_categories[i]),
    );
  }

  Widget _buildCategoryCard(_Category cat) {
    return GestureDetector(
      onTap: () => _onCategoryTap(cat),
      child: Column(
        children: [
          // Carte icône
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  cat.emoji,
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          // Label
          Text(
            cat.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF212121),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation Bar ────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      const _NavItem(icon: Icons.home_filled, label: ''),
      const _NavItem(icon: Icons.playlist_add_check_rounded, label: ''),
      const _NavItem(icon: Icons.person_outline_rounded, label: ''),
      const _NavItem(icon: Icons.notifications_none_rounded, label: ''),
    ];
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
              color: Color(0x44000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = _selectedNavIndex == i;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onNavTap(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[i].icon,
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    size: 28,
                  ),
                  if (selected)
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Drawer latéral ───────────────────────────────────────────────────────
  Widget _buildDrawer(AuthProvider auth) {
    final user = auth.user;
    return Drawer(
      child: Column(
        children: [
          // En-tête
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: Text(
                    user?['firstName']?.toString().isNotEmpty == true
                        ? user!['firstName'].toString()[0].toUpperCase()
                        : 'U',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  auth.userName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  auth.userEmail,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.home_rounded, 'Accueil',
                    () => Navigator.pop(context)),
                _drawerItem(Icons.local_hospital_rounded, 'Hôpitaux', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.hospitals);
                }),
                _drawerItem(Icons.local_pharmacy_rounded, 'Pharmacies', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.pharmacies);
                }),
                _drawerItem(Icons.emergency_rounded, 'Urgences', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.emergency);
                }),
                _drawerItem(Icons.medical_services_rounded, 'Spécialistes', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.services);
                }),
                _drawerItem(Icons.map_rounded, 'Carte', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.map);
                }),
                _drawerItem(Icons.history_rounded, 'Mes recherches', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.mySearches);
                }),
                _drawerItem(Icons.star_rounded, 'Mon avis', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.myOpinion);
                }),
                const Divider(),
                _drawerItem(Icons.person_rounded, 'Mon profil', () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.profile);
                }),
                _drawerItem(Icons.logout_rounded, 'Déconnexion', () async {
                  Navigator.pop(context);
                  await auth.logout();
                  Get.offAllNamed(AppRoutes.login);
                }, color: AppColors.emergency),
              ],
            ),
          ),
          // Version
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Allô Secours v1.0.0 — Bénin',
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary, size: 22),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color ?? const Color(0xFF212121),
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }
}

// ── Modèles internes ─────────────────────────────────────────────────────────

class _CarouselSlide {
  final String title;
  final String bold;
  final String suffix;
  final String emoji;
  final List<Color> colors;
  const _CarouselSlide({
    required this.title,
    required this.bold,
    required this.suffix,
    required this.emoji,
    required this.colors,
  });
}

class _Category {
  final String label;
  final String emoji;
  final String? route;
  const _Category({required this.label, required this.emoji, this.route});
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
