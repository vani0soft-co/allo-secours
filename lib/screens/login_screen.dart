import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/config/app_routes.dart';
import 'package:allo_secours/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login fields
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _loginPasswordVisible = false;

  // Register fields
  final _regFirstNameCtrl = TextEditingController();
  final _regLastNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();
  bool _regPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regFirstNameCtrl.dispose();
    _regLastNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _loginEmailCtrl.text.trim(),
      password: _loginPasswordCtrl.text,
    );
    if (success && mounted) {
      Get.offAllNamed(AppRoutes.home);
    } else if (mounted && auth.error != null) {
      _showError(auth.error!);
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    if (_regPasswordCtrl.text != _regConfirmCtrl.text) {
      _showError('Les mots de passe ne correspondent pas');
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      firstName: _regFirstNameCtrl.text.trim(),
      lastName: _regLastNameCtrl.text.trim(),
      email: _regEmailCtrl.text.trim(),
      password: _regPasswordCtrl.text,
    );
    if (success && mounted) {
      Get.offAllNamed(AppRoutes.home);
    } else if (mounted && auth.error != null) {
      _showError(auth.error!);
    }
  }

  Future<void> _handleDemo() async {
    await context.read<AuthProvider>().loginAsDemo();
    if (mounted) Get.offAllNamed(AppRoutes.home);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: AppColors.emergency,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Zone gradient (40% de la hauteur) ───────────────────────
            Container(
              width: double.infinity,
              height: screenHeight * 0.40,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Allô Secours',
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Votre santé, notre priorité',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.80),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Carte blanche arrondie ────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 24,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 28),

                    // ─── Tabs Connexion / Inscription ──────────────────────
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.textMedium,
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                        padding: EdgeInsets.zero,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Connexion'),
                          Tab(text: 'Inscription'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Contenu des tabs ──────────────────────────────────
                    SizedBox(
                      height: 420,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLoginForm(),
                          _buildRegisterForm(),
                        ],
                      ),
                    ),

                    // ─── Séparateur ────────────────────────────────────────
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Divider(color: AppColors.dividerGray),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'ou',
                              style: GoogleFonts.poppins(
                                color: AppColors.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: AppColors.dividerGray),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ─── Bouton démo ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: OutlinedButton.icon(
                        onPressed: _handleDemo,
                        icon: const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 20,
                        ),
                        label: Text(
                          'Continuer en mode démo',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primaryLight,
                            width: 1.5,
                          ),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: AppColors.lightGray,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Formulaire Connexion ─────────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _loginEmailCtrl,
                  label: 'Adresse email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Email invalide' : null,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _loginPasswordCtrl,
                  label: 'Mot de passe',
                  icon: Icons.lock_outline_rounded,
                  obscureText: !_loginPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _loginPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.mediumGray,
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _loginPasswordVisible = !_loginPasswordVisible),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Minimum 6 caractères' : null,
                ),
                const SizedBox(height: 24),
                _buildGradientButton(
                  label: 'Se connecter',
                  isLoading: auth.isLoading,
                  onPressed: _handleLogin,
                  gradient: AppColors.primaryGradient,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Formulaire Inscription ───────────────────────────────────────────────
  Widget _buildRegisterForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _regFirstNameCtrl,
                        label: 'Prénom',
                        icon: Icons.person_outline_rounded,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _regLastNameCtrl,
                        label: 'Nom',
                        icon: Icons.person_outline_rounded,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _regEmailCtrl,
                  label: 'Adresse email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Email invalide' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _regPasswordCtrl,
                  label: 'Mot de passe',
                  icon: Icons.lock_outline_rounded,
                  obscureText: !_regPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _regPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.mediumGray,
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _regPasswordVisible = !_regPasswordVisible),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Minimum 6 caractères' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _regConfirmCtrl,
                  label: 'Confirmer le mot de passe',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 24),
                _buildGradientButton(
                  label: "S'inscrire",
                  isLoading: auth.isLoading,
                  onPressed: _handleRegister,
                  gradient: AppColors.greenGradient,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Bouton gradient réutilisable ─────────────────────────────────────────
  Widget _buildGradientButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
    required LinearGradient gradient,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: isLoading ? null : gradient,
          color: isLoading ? AppColors.dividerGray : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  // ─── Champ texte réutilisable ─────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: AppColors.mediumGray,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.lightGray,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.dividerGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.emergency, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.emergency, width: 2),
        ),
      ),
    );
  }
}
