import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/format_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/car_provider.dart';
import '../../../providers/parcel_provider.dart';
import '../../../providers/reservation_provider.dart';
import '../cars/admin_cars_screen.dart';
import '../reservations/admin_reservations_screen.dart';
import '../parcels/admin_parcels_screen.dart';
import '../clients/admin_clients_screen.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DashboardPage(),
      const AdminCarsScreenEmbedded(),
      const AdminReservationsScreenEmbedded(),
      const AdminParcelsScreenEmbedded(),
      const AdminClientsScreenEmbedded(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.directions_car_outlined),
                activeIcon: Icon(Icons.directions_car_rounded),
                label: 'Voitures'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today_rounded),
                label: 'Réservations'),
            BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2_rounded),
                label: 'Colis'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Clients'),
          ],
        ),
      ),
    );
  }
}

class _DashboardPage extends ConsumerWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(allCarsStreamProvider);
    final reservationsAsync = ref.watch(allReservationsProvider);
    final parcelsAsync = ref.watch(allParcelsProvider);
    final userAsync = ref.watch(userStreamProvider);

    final totalCars = carsAsync.valueOrNull?.length ?? 0;
    final availableCars =
        carsAsync.valueOrNull?.where((c) => c.isAvailable).length ?? 0;
    final totalReservations = reservationsAsync.valueOrNull?.length ?? 0;
    final activeReservations = reservationsAsync.valueOrNull
            ?.where((r) => r.status.name == 'active' || r.status.name == 'confirmed')
            .length ??
        0;
    final totalParcels = parcelsAsync.valueOrNull?.length ?? 0;
    final deliveredParcels = parcelsAsync.valueOrNull
            ?.where((p) => p.status.name == 'delivered')
            .length ??
        0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tableau de bord',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800)),
                        Text('Bienvenue, ${userAsync.valueOrNull?.fullName ?? 'Admin'}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.error),
                    onPressed: () async {
                      await ref.read(authServiceProvider).logout();
                      if (context.mounted) context.go('/auth/login');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _StatCard(
                    icon: Icons.directions_car_rounded,
                    title: 'Voitures',
                    value: '$totalCars',
                    sub: '$availableCars disponibles',
                    gradient: AppColors.primaryGradient,
                  ),
                  _StatCard(
                    icon: Icons.calendar_today_rounded,
                    title: 'Réservations',
                    value: '$totalReservations',
                    sub: '$activeReservations actives',
                    gradient: AppColors.secondaryGradient,
                  ),
                  _StatCard(
                    icon: Icons.inventory_2_rounded,
                    title: 'Colis',
                    value: '$totalParcels',
                    sub: '$deliveredParcels livrés',
                    gradient: AppColors.accentGradient,
                  ),
                  _StatCard(
                    icon: Icons.people_rounded,
                    title: 'Activité',
                    value: '${totalReservations + totalParcels}',
                    sub: 'Total opérations',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart réservations vs colis
              const Text('Activité récente',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (totalReservations > totalParcels
                            ? totalReservations
                            : totalParcels)
                        .toDouble() +
                        2,
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                          toY: totalReservations.toDouble(),
                          color: AppColors.primary,
                          width: 24,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                          toY: totalParcels.toDouble(),
                          color: AppColors.secondary,
                          width: 24,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(
                          toY: activeReservations.toDouble(),
                          color: AppColors.accent,
                          width: 24,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ]),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            switch (v.toInt()) {
                              case 0: return const Text('Réserv.',
                                  style: TextStyle(fontSize: 10));
                              case 1: return const Text('Colis',
                                  style: TextStyle(fontSize: 10));
                              case 2: return const Text('Actives',
                                  style: TextStyle(fontSize: 10));
                              default: return const SizedBox();
                            }
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Dernières réservations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dernières réservations',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              reservationsAsync.when(
                data: (list) => list.isEmpty
                    ? const Center(
                        child: Text('Aucune réservation',
                            style: TextStyle(
                                color: AppColors.textSecondary)))
                    : Column(
                        children: list
                            .take(5)
                            .map((r) => _RecentReservationTile(res: r))
                            .toList()),
                loading: () => const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String sub;
  final LinearGradient gradient;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.sub,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 26),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(title,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          Text(sub,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.65), fontSize: 11)),
        ],
      ),
    );
  }
}

class _RecentReservationTile extends StatelessWidget {
  final res;
  const _RecentReservationTile({required this.res});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getStatusBgColor(res.status.name),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_car_rounded,
                size: 16,
                color: AppColors.getStatusColor(res.status.name)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(res.carFullName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(res.userName ?? '',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.getStatusBgColor(res.status.name),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(res.statusLabel,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getStatusColor(res.status.name))),
              ),
              const SizedBox(height: 3),
              Text(FormatUtils.formatPrice(res.totalPrice),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}