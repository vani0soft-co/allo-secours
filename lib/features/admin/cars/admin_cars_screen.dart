import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/car_model.dart';
import '../../../providers/car_provider.dart';

class AdminCarsScreen extends ConsumerWidget {
  const AdminCarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AdminCarsScreenEmbedded();
  }
}

class AdminCarsScreenEmbedded extends ConsumerWidget {
  const AdminCarsScreenEmbedded({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(allCarsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gestion des voitures'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/cars/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter'),
      ),
      body: carsAsync.when(
        data: (cars) {
          if (cars.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.directions_car_outlined,
              title: 'Aucune voiture',
              subtitle: 'Ajoutez votre première voiture',
              actionLabel: 'Ajouter une voiture',
              onAction: () => context.push('/admin/cars/add'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            itemCount: cars.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _AdminCarCard(car: cars[i]),
          );
        },
        loading: () => const ShimmerList(count: 4, itemHeight: 110),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class _AdminCarCard extends ConsumerWidget {
  final CarModel car;
  const _AdminCarCard({required this.car});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14)),
            child: car.mainPhoto != null
                ? Image.network(car.mainPhoto!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(car.fullName,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Switch(
                        value: car.isAvailable,
                        onChanged: (v) => ref
                            .read(carServiceProvider)
                            .setAvailability(car.id, v),
                        activeColor: AppColors.success,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                      '${car.transmissionLabel} • ${car.seats} places • ${car.fuelLabel}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                          '${FormatUtils.formatPrice(car.pricePerDay)}/j',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.primary),
                        onPressed: () => context
                            .push('/admin/cars/${car.id}/edit'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.error),
                        onPressed: () =>
                            _deleteDialog(context, ref, car),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 100,
      height: 100,
      color: AppColors.primaryLight,
      child: const Icon(Icons.directions_car_rounded,
          size: 36, color: AppColors.primary),
    );
  }

  void _deleteDialog(
      BuildContext context, WidgetRef ref, CarModel car) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cette voiture ?'),
        content: Text('${car.fullName} sera supprimée définitivement.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(carServiceProvider).deleteCar(car.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voiture supprimée')),
                );
              }
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}