import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:allo_secours/config/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenu;
  final VoidCallback? onMenuTap;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showMenu = false,
    this.onMenuTap,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: actions ??
            (showMenu
                ? [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: onMenuTap ?? () {},
                    ),
                  ]
                : null),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
