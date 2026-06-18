import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _authService = AuthService();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadMyOrders() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore
        .collection(FirestoreCollections.orders)
        .where('customerId', isEqualTo: uid)
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

  Future<String> placeOrder({
    required String shopId,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    required String customerPhone,
    required String customerName,
    String customerNotes = '',
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final docRef = await _firestore.add(FirestoreCollections.orders, {
      'customerId': uid,
      'shopId': shopId,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': 'pending',
      'deliveryAddress': deliveryAddress,
      'customerPhone': customerPhone,
      'customerName': customerName,
      'customerNotes': customerNotes,
      'autoCancelled': false,
      'cancellationReason': '',
    });

    return docRef.id;
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final data = await _firestore.get(FirestoreCollections.orders, orderId);
    if (data == null) return null;
    return OrderModel.fromMap(orderId, data);
  }

  Stream<DocumentSnapshot> orderStream(String orderId) {
    return _firestore.doc(FirestoreCollections.orders, orderId).snapshots();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
