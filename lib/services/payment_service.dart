import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('payments');

  Future<String> createPayment({
    required String userId,
    String? userName,
    required PaymentType type,
    required String refId,
    required double amount,
    required PaymentMethod method,
  }) async {
    final ref = await _col.add({
      'userId': userId,
      'userName': userName,
      'type': type.name,
      'refId': refId,
      'amount': amount,
      'status': PaymentStatus.pending.name,
      'method': method.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updatePaymentStatus(String id, PaymentStatus status,
      {String? transactionRef}) async {
    final data = <String, dynamic>{'status': status.name};
    if (transactionRef != null) data['transactionRef'] = transactionRef;
    await _col.doc(id).update(data);
  }

  Stream<List<PaymentModel>> getAllPayments() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PaymentModel.fromDoc(d)).toList());
  }

  Stream<List<PaymentModel>> getUserPayments(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PaymentModel.fromDoc(d)).toList());
  }

  Future<Map<String, double>> getRevenueSummary() async {
    final snap = await _col.where('status', isEqualTo: 'success').get();
    double total = 0, reservation = 0, parcel = 0;
    for (final doc in snap.docs) {
      final p = PaymentModel.fromDoc(doc);
      total += p.amount;
      if (p.type == PaymentType.reservation) reservation += p.amount;
      if (p.type == PaymentType.parcel) parcel += p.amount;
    }
    return {'total': total, 'reservation': reservation, 'parcel': parcel};
  }
}