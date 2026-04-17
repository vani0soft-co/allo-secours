import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';

class CarService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('cars');

  Stream<List<CarModel>> getCars({bool? availableOnly}) {
    Query q = _col.orderBy('createdAt', descending: true);
    if (availableOnly == true) q = q.where('isAvailable', isEqualTo: true);
    return q.snapshots().map((s) =>
        s.docs.map((d) => CarModel.fromDoc(d)).toList());
  }

  Future<CarModel> getCar(String id) async {
    final doc = await _col.doc(id).get();
    return CarModel.fromDoc(doc);
  }

  Stream<CarModel> carStream(String id) =>
      _col.doc(id).snapshots().map((d) => CarModel.fromDoc(d));

  Future<String> addCar(CarModel car) async {
    final ref = await _col.add(car.toMap());
    return ref.id;
  }

  Future<void> updateCar(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);

  Future<void> deleteCar(String id) => _col.doc(id).delete();

  Future<void> setAvailability(String id, bool available) =>
      _col.doc(id).update({'isAvailable': available});

  Future<List<CarModel>> searchCars(String query) async {
    final snap = await _col.get();
    final q = query.toLowerCase();
    return snap.docs
        .map((d) => CarModel.fromDoc(d))
        .where((c) =>
            c.brand.toLowerCase().contains(q) ||
            c.model.toLowerCase().contains(q))
        .toList();
  }
}