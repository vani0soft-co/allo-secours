import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/car_provider.dart';
import '../../../providers/reservation_provider.dart';
import '../../../services/notification_service.dart';
import '../../../models/notification_model.dart';

class CarBookingScreen extends ConsumerStatefulWidget {
  final String carId;
  const CarBookingScreen({super.key, required this.carId});

  @override
  ConsumerState<CarBookingScreen> createState() => _CarBookingScreenState();
}

class _CarBookingScreenState extends ConsumerState<CarBookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _focusedDay = DateTime.now();
  bool _loading = false;

  int get _totalDays =>
      _startDate != null && _endDate != null
          ? _endDate!.difference(_startDate!).inDays
          : 0;

  double _totalPrice(double pricePerDay, double deposit) =>
      _totalDays * pricePerDay + deposit;

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _focusedDay = focused;
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = selected;
        _endDate = null;
      } else {
        if (selected.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = selected;
        } else if (selected.isAtSameMomentAs(_startDate!)) {
          _startDate = null;
        } else {
          _endDate = selected;
        }
      }
    });
  }

  Future<void> _book() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner les dates')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await ref.read(userStreamProvider.future);
      final car = await ref.read(carDetailProvider(widget.carId).future);
      final resService = ref.read(reservationServiceProvider);

      final available = await resService.isCarAvailable(
          widget.carId, _startDate!, _endDate!);
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Cette voiture est déjà réservée pour ces dates')),
          );
        }
        return;
      }

      final id = await resService.createReservation(
        user: user!,
        car: car,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      await NotificationService.saveNotification(
        userId: user.id,
        title: 'Réservation envoyée',
        body:
            'Votre réservation pour ${car.fullName} est en attente de confirmation.',
        type: NotificationType.reservation,
        refId: id,
      );

      if (mounted) {
        context.go('/client/reservations');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Réservation effectuée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final carAsync = ref.watch(carDetailProvider(widget.carId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Réserver'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: carAsync.when(
        data: (car) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: car.mainPhoto != null
                                ? Image.network(car.mainPhoto!,
                                    width: 80,
                                    height: 60,
                                    fit: BoxFit.cover)
                                : Container(
                                    width: 80,
                                    height: 60,
                                    color: AppColors.primaryLight,
                                    child: const Icon(
                                        Icons.directions_car_rounded,
                                        color: AppColors.primary)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(car.fullName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(
                                    '${FormatUtils.formatPrice(car.pricePerDay)}/jour',
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Sélectionnez vos dates',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay:
                            DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        rangeStartDay: _startDate,
                        rangeEndDay: _endDate,
                        rangeSelectionMode: RangeSelectionMode.toggledOn,
                        onDaySelected: _onDaySelected,
                        onRangeSelected: (start, end, focused) {
                          setState(() {
                            _startDate = start;
                            _endDate = end;
                            _focusedDay = focused;
                          });
                        },
                        onPageChanged: (f) =>
                            setState(() => _focusedDay = f),
                        calendarStyle: CalendarStyle(
                          rangeHighlightColor: AppColors.primaryLight,
                          rangeStartDecoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle),
                          rangeEndDecoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle),
                          todayDecoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle),
                        ),
                        headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_startDate != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _SummaryRow(
                              label: 'Date de début',
                              value: AppDateUtils.formatDate(_startDate!),
                            ),
                            if (_endDate != null) ...[
                              const Divider(height: 20),
                              _SummaryRow(
                                label: 'Date de fin',
                                value: AppDateUtils.formatDate(_endDate!),
                              ),
                              const Divider(height: 20),
                              _SummaryRow(
                                label: 'Nombre de jours',
                                value: '$_totalDays jour(s)',
                              ),
                              const Divider(height: 20),
                              _SummaryRow(
                                label: 'Location',
                                value: FormatUtils.formatPrice(
                                    _totalDays * car.pricePerDay),
                              ),
                              const Divider(height: 20),
                              _SummaryRow(
                                label: 'Caution',
                                value:
                                    FormatUtils.formatPrice(car.deposit),
                              ),
                              const Divider(height: 20),
                              _SummaryRow(
                                label: 'Total',
                                value: FormatUtils.formatPrice(
                                    _totalPrice(car.pricePerDay, car.deposit)),
                                isTotal: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: AppColors.shadow, blurRadius: 12)
                ],
              ),
              child: CustomButton(
                label: _endDate != null
                    ? 'Confirmer la réservation — ${FormatUtils.formatPrice(_totalPrice(car.pricePerDay, car.deposit))}'
                    : 'Sélectionnez une date de fin',
                onPressed: _endDate != null ? _book : null,
                isLoading: _loading,
              ),
            ),
          ],
        ),
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _SummaryRow(
      {required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 15 : 14,
                fontWeight:
                    isTotal ? FontWeight.w700 : FontWeight.w400,
                color:
                    isTotal ? AppColors.textPrimary : AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: FontWeight.w700,
                color: isTotal ? AppColors.primary : AppColors.textPrimary)),
      ],
    );
  }
}