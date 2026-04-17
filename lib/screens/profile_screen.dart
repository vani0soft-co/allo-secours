import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/config/app_routes.dart';
import 'package:allo_secours/models/service_model.dart';
import 'package:allo_secours/providers/auth_provider.dart';
import 'package:allo_secours/providers/services_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Initiales de l'utilisateur
        final nameParts = auth.userName.trim().split(' ');
        final initials = nameParts.length >= 2
            ? '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase()
            : (auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : '?');

        return Scaffold(
          backgroundColor: AppColors.background,

          // ─── AppBar gradient ──────────────────────────────────────────
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  'Mon profil',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          body: SingleChildScrollView(
            child: Column(
              children: [
                // ─── Header gradient avec avatar ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      // ─── Avatar circulaire avec initiales ───────────────
                      Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(
                                  color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkBlue
                                      .withValues(alpha: 0.30),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  size: 13, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Nom
                      Text(
                        auth.userName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Text(
                        auth.userEmail,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─── Stats ─────────────────────────────────────────
                      Consumer<ServicesProvider>(
                        builder: (context, svc, _) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat(
                                  '${svc.favorites.length}', 'Favoris'),
                              Container(
                                width: 1,
                                height: 32,
                                color: Colors.white.withValues(alpha: 0.30),
                              ),
                              const _ReviewsStatWidget(),
                              Container(
                                width: 1,
                                height: 32,
                                color: Colors.white.withValues(alpha: 0.30),
                              ),
                              _buildStat('0', 'Recherches'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Section Mon compte ─────────────────────────────────────
                _buildSection(
                  title: 'Mon compte',
                  items: [
                    _ProfileMenuItem(
                      icon: Icons.favorite_rounded,
                      label: 'Mes favoris',
                      color: AppColors.emergency,
                      onTap: () => _showFavorites(context),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.history_rounded,
                      label: 'Mon historique de recherche',
                      color: AppColors.primaryLight,
                      onTap: () => Get.toNamed(AppRoutes.mySearches),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.star_rounded,
                      label: 'Mes avis',
                      color: AppColors.accent,
                      onTap: () => Get.toNamed(AppRoutes.myOpinion),
                    ),
                  ],
                ),

                // ─── Section Paramètres ──────────────────────────────────────
                _buildSection(
                  title: 'Paramètres',
                  items: [
                    _ProfileMenuItem(
                      icon: Icons.notifications_rounded,
                      label: 'Notifications',
                      color: const Color(0xFF9B59B6),
                      onTap: () =>
                          _showSettingsDialog(context, 'Notifications'),
                      trailing: Switch(
                        value: true,
                        onChanged: (_) {},
                        activeThumbColor: AppColors.primaryLight,
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.location_on_rounded,
                      label: 'Localisation',
                      color: AppColors.secondary,
                      onTap: () =>
                          _showSettingsDialog(context, 'Localisation'),
                      trailing: Switch(
                        value: true,
                        onChanged: (_) {},
                        activeThumbColor: AppColors.primaryLight,
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.language_rounded,
                      label: 'Langue',
                      color: const Color(0xFF1ABC9C),
                      subtitle: 'Français',
                      onTap: () => _showLanguageDialog(context),
                    ),
                  ],
                ),

                // ─── Section Support ─────────────────────────────────────────
                _buildSection(
                  title: 'Support',
                  items: [
                    _ProfileMenuItem(
                      icon: Icons.help_rounded,
                      label: 'Aide et support',
                      color: const Color(0xFF5C6BC0),
                      onTap: () => _showHelpDialog(context),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.info_rounded,
                      label: 'À propos',
                      color: const Color(0xFF78909C),
                      subtitle: 'Version 1.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ─── Bouton déconnexion ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () => _confirmLogout(context, auth),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.emergencyGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emergency
                                .withValues(alpha: 0.30),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Se déconnecter',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.70),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<_ProfileMenuItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Container(
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
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon,
                            color: item.color, size: 18),
                      ),
                      title: Text(
                        item.label,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: item.subtitle != null
                          ? Text(
                              item.subtitle!,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textLight,
                              ),
                            )
                          : null,
                      trailing: item.trailing ??
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.mediumGray, size: 18),
                      onTap: item.onTap,
                    ),
                    if (i < items.length - 1)
                      Divider(
                        height: 1,
                        indent: 68,
                        endIndent: 16,
                        color: AppColors.dividerGray,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showFavorites(BuildContext context) {
    final favorites = context.read<ServicesProvider>().favorites;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surface,
      builder: (ctx) {
        return Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.dividerGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Mes favoris',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite_border_rounded,
                              size: 52, color: AppColors.mediumGray),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun favori pour le moment',
                            style: GoogleFonts.poppins(
                                color: AppColors.textMedium),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (_, i) {
                        final Service service = favorites[i];
                        return ListTile(
                          leading: const Icon(Icons.favorite_rounded,
                              color: AppColors.emergency),
                          title: Text(service.name,
                              style: GoogleFonts.poppins()),
                          subtitle: Text(service.address,
                              style: GoogleFonts.poppins(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.pop(ctx);
                            Get.toNamed(AppRoutes.serviceDetail,
                                arguments: service);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Déconnexion',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium),
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
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await auth.logout();
                Get.offAllNamed(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
              ),
              child:
                  Text('Déconnecter', style: GoogleFonts.poppins()),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, String setting) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paramètre "$setting" bientôt disponible',
            style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Choisir la langue',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        children: ['Français', 'English', 'العربية'].map((lang) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Langue "$lang" sélectionnée',
                        style: GoogleFonts.poppins())),
              );
            },
            child: Text(lang, style: GoogleFonts.poppins()),
          );
        }).toList(),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Aide et support',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('support@allosecours.app',
                style: GoogleFonts.poppins(fontSize: 13)),
            const SizedBox(height: 8),
            Text('+225 27 00 00 00 00',
                style: GoogleFonts.poppins(fontSize: 13)),
            const SizedBox(height: 8),
            Text('Lun-Ven 8h-18h',
                style: GoogleFonts.poppins(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Fermer',
                style: GoogleFonts.poppins(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Allô Secours',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.local_hospital_rounded,
        color: AppColors.primary,
        size: 48,
      ),
      children: [
        Text(
          'Application de géolocalisation des services de santé.\n\nTrouvez rapidement les hôpitaux, pharmacies et services d\'urgence près de vous.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
      ],
    );
  }
}

// ─── Classes utilitaires ──────────────────────────────────────────────────────

class _ProfileMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });
}

class _ReviewsStatWidget extends StatelessWidget {
  const _ReviewsStatWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '0',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Avis',
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.70),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
