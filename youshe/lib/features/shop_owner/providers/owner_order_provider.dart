import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../models/order_model.dart';

class OwnerOrderProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _authService = AuthService();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> getMyShopId() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return null;
    final snapshot = await _firestore
        .collection(FirestoreCollections.shops)
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  void loadMyShopOrders() async {
    final shopId = await getMyShopId();
    if (shopId == null) return;

    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore
        .collection(FirestoreCollections.orders)
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> confirmOrder(String orderId) async {
    await _firestore.update(FirestoreCollections.orders, orderId, {
      'status': 'confirmed',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelOrder(String orderId, {String reason = ''}) async {
    await _firestore.update(FirestoreCollections.orders, orderId, {
      'status': 'cancelled',
      'respondedAt': FieldValue.serverTimestamp(),
      'cancellationReason': reason,
    });
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final data = await _firestore.get(FirestoreCollections.orders, orderId);
    if (data == null) return null;
    return OrderModel.fromMap(orderId, data);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
