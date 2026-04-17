import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/client/home/client_home_screen.dart';
import '../../features/client/cars/car_list_screen.dart';
import '../../features/client/cars/car_detail_screen.dart';
import '../../features/client/cars/car_booking_screen.dart';
import '../../features/client/parcels/parcel_list_screen.dart';
import '../../features/client/parcels/create_parcel_screen.dart';
import '../../features/client/parcels/parcel_tracking_screen.dart';
import '../../features/client/reservations/my_reservations_screen.dart';
import '../../features/client/notifications/notifications_screen.dart';
import '../../features/client/profile/profile_screen.dart';
import '../../features/client/profile/edit_profile_screen.dart';
import '../../features/admin/home/admin_home_screen.dart';
import '../../features/admin/cars/admin_cars_screen.dart';
import '../../features/admin/cars/admin_add_car_screen.dart';
import '../../features/admin/reservations/admin_reservations_screen.dart';
import '../../features/admin/parcels/admin_parcels_screen.dart';
import '../../features/admin/clients/admin_clients_screen.dart';
import '../../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation.startsWith('/auth');

      if (isSplash) return null;
      if (!isLoggedIn && !isAuth) return '/auth/login';
      if (isLoggedIn && isAuth) return '/client/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/auth',
        redirect: (_, state) => state.uri.path == '/auth' ? '/auth/login' : null,
        routes: [
          GoRoute(path: 'login', builder: (_, __) => const LoginScreen()),
          GoRoute(path: 'register', builder: (_, __) => const RegisterScreen()),
          GoRoute(path: 'forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
        ],
      ),
      GoRoute(
        path: '/client',
        redirect: (_, __) => '/client/home',
        routes: [
          GoRoute(path: 'home', builder: (_, __) => const ClientHomeScreen()),
          GoRoute(path: 'cars', builder: (_, __) => const CarListScreen()),
          GoRoute(
            path: 'cars/:id',
            builder: (_, state) => CarDetailScreen(carId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'cars/:id/book',
            builder: (_, state) => CarBookingScreen(carId: state.pathParameters['id']!),
          ),
          GoRoute(path: 'parcels', builder: (_, __) => const ParcelListScreen()),
          GoRoute(path: 'parcels/create', builder: (_, __) => const CreateParcelScreen()),
          GoRoute(
            path: 'parcels/:id/track',
            builder: (_, state) => ParcelTrackingScreen(parcelId: state.pathParameters['id']!),
          ),
          GoRoute(path: 'reservations', builder: (_, __) => const MyReservationsScreen()),
          GoRoute(path: 'notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: 'profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: 'profile/edit', builder: (_, __) => const EditProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/admin',
        redirect: (_, __) => '/admin/home',
        routes: [
          GoRoute(path: 'home', builder: (_, __) => const AdminHomeScreen()),
          GoRoute(path: 'cars', builder: (_, __) => const AdminCarsScreen()),
          GoRoute(path: 'cars/add', builder: (_, __) => const AdminAddCarScreen()),
          GoRoute(
            path: 'cars/:id/edit',
            builder: (_, state) => AdminAddCarScreen(carId: state.pathParameters['id']),
          ),
          GoRoute(path: 'reservations', builder: (_, __) => const AdminReservationsScreen()),
          GoRoute(path: 'parcels', builder: (_, __) => const AdminParcelsScreen()),
          GoRoute(path: 'clients', builder: (_, __) => const AdminClientsScreen()),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page introuvable: ${state.error}')),
    ),
  );
});