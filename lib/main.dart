import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/config/app_routes.dart';
import 'package:allo_secours/providers/auth_provider.dart';
import 'package:allo_secours/providers/location_provider.dart';
import 'package:allo_secours/providers/services_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Vérifier l'auth avant runApp — pas de navigation au démarrage
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final firstName = prefs.getString('user_firstName');
  final isAuthenticated = token != null && firstName != null;

  runApp(AlloSecours(initialRoute: isAuthenticated ? AppRoutes.home : AppRoutes.login));
}

class AlloSecours extends StatelessWidget {
  final String initialRoute;
  const AlloSecours({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
      ],
      child: GetMaterialApp(
        title: 'Allo Secours',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          useMaterial3: true,
        ),
        initialRoute: initialRoute,
        getPages: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
