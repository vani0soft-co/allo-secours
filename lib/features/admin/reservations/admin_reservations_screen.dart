import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/reservation_model.dart';
import '../../../providers/reservation_provider.dart';

class AdminReservationsScreen extends ConsumerWidget {
  const AdminReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AdminReservationsScreenEmbedded();
  }
}

class AdminReservationsScreenEmbedded extends ConsumerStatefulWidget {
  const AdminReservationsScreenEmbedded({super.key});

  @override
  ConsumerState<AdminReservationsScreenEmbedded> createState() =>
      _AdminReservationsScreenEmbeddedState();
}

class _AdminReservationsScreenEmbeddedState
    extends ConsumerState<AdminReservationsScreenEmbedded>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resAsync = ref.watch(allReservationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gestion des réservations'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'En attente'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
          ],
        ),
      ),
      body: resAsync.when(
        data: (list) {
          final all = list;
          final pending =
              list.where((r) => r.status == ReservationStatus.pending).toList();
          final active = list
              .where((r) =>
                  r.status == ReservationStatus.active ||
                  r.status == ReservationStatus.confirmed)
              .toList();
          final done = list
              .where((r) =>
                  r.status == ReservationStatus.completed ||
                  r.status == ReservationStatus.cancelled)
              .toList();

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _ResList(reservations: all),
              _ResList(reservations: pending),
              _ResList(reservations: active),
              _ResList(reservations: done),
            ],
          );
        },
        loading: () => const ShimmerList(count: 4, itemHeight: 130),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class _ResList extends StatelessWidget {
  final List<ReservationModel> reservations;
  const _ResList({required this.reservations});

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return const EmptyStateWidget(
          icon: Icons.calendar_today_outlined,
          title: 'Aucune réservation');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: reservations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _AdminResCard(res: reservations[i]),
    );
  }
}

class _AdminResCard extends ConsumerWidget {
  final ReservationModel res;
  const _AdminResCard({required this.res});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(res.carFullName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(res.userName ?? '',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.getStatusBgColor(res.status.name),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(res.statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getStatusColor(res.status.name))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                    '${AppDateUtils.formatDate(res.startDate)} → ${AppDateUtils.formatDate(res.endDate)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
              Text(FormatUtils.formatPrice(res.totalPrice),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          if (res.status == ReservationStatus.pending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _updateStatus(context, ref, ReservationStatus.cancelled),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error)),
                    child: const Text('Refuser',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateStatus(context, ref, ReservationStatus.confirmed),
                    child: const Text('Confirmer',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            )
          else if (res.status == ReservationStatus.confirmed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _updateStatus(context, ref, ReservationStatus.active),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary),
                child: const Text('Marquer En cours'),
              ),
            )
          else if (res.status == ReservationStatus.active)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _updateStatus(context, ref, ReservationStatus.completed),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success),
                child: const Text('Marquer Terminée'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref,
      ReservationStatus status) async {
    await ref
        .read(reservationServiceProvider)
        .updateStatus(res.id, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour: ${res.statusLabel}')),
      );
    }
  }
}