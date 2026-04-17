import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parcel_model.dart';
import '../services/parcel_service.dart';
import 'auth_provider.dart';

final parcelServiceProvider =
    Provider<ParcelService>((ref) => ParcelService());

final myParcelsProvider = StreamProvider<List<ParcelModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(parcelServiceProvider).getUserParcels(user.uid);
});

final allParcelsProvider = StreamProvider<List<ParcelModel>>((ref) {
  return ref.watch(parcelServiceProvider).getAllParcels();
});

final parcelStreamProvider =
    StreamProvider.family<ParcelModel, String>((ref, id) {
  return ref.watch(parcelServiceProvider).parcelStream(id);
});