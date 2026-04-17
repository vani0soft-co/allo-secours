import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';

final carServiceProvider = Provider<CarService>((ref) => CarService());

final carsStreamProvider = StreamProvider<List<CarModel>>((ref) {
  return ref.watch(carServiceProvider).getCars(availableOnly: true);
});

final allCarsStreamProvider = StreamProvider<List<CarModel>>((ref) {
  return ref.watch(carServiceProvider).getCars();
});

final carDetailProvider =
    StreamProvider.family<CarModel, String>((ref, id) {
  return ref.watch(carServiceProvider).carStream(id);
});

final carSearchProvider =
    StateNotifierProvider<CarSearchNotifier, AsyncValue<List<CarModel>>>(
        (ref) => CarSearchNotifier(ref.read(carServiceProvider)));

class CarSearchNotifier extends StateNotifier<AsyncValue<List<CarModel>>> {
  final CarService _service;
  CarSearchNotifier(this._service) : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.searchCars(query));
  }
}