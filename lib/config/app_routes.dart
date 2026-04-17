import 'package:get/get.dart';
import 'package:allo_secours/screens/home_screen.dart';
import 'package:allo_secours/screens/login_screen.dart';
import 'package:allo_secours/screens/services_screen.dart';
import 'package:allo_secours/screens/hospitals_screen.dart';
import 'package:allo_secours/screens/pharmacies_screen.dart';
import 'package:allo_secours/screens/emergency_screen.dart';
import 'package:allo_secours/screens/service_detail_screen.dart';
import 'package:allo_secours/screens/map_screen.dart';
import 'package:allo_secours/screens/my_searches_screen.dart';
import 'package:allo_secours/screens/my_opinion_screen.dart';
import 'package:allo_secours/screens/profile_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String services = '/services';
  static const String hospitals = '/hospitals';
  static const String pharmacies = '/pharmacies';
  static const String emergency = '/emergency';
  static const String serviceDetail = '/service-detail';
  static const String map = '/map';
  static const String mySearches = '/my-searches';
  static const String myOpinion = '/my-opinion';
  static const String profile = '/profile';

  static List<GetPage> routes = [
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: services, page: () => const ServicesScreen()),
    GetPage(name: hospitals, page: () => const HospitalsScreen()),
    GetPage(name: pharmacies, page: () => const PharmaciesScreen()),
    GetPage(name: emergency, page: () => const EmergencyScreen()),
    GetPage(
      name: serviceDetail,
      page: () => const ServiceDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: map, page: () => const MapScreen()),
    GetPage(name: mySearches, page: () => const MySearchesScreen()),
    GetPage(name: myOpinion, page: () => const MyOpinionScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
  ];
}
