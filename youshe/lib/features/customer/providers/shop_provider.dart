import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/constants.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/shop_model.dart';

class ShopProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  List<ShopModel> _shops = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  List<ShopModel> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadShops() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore
        .collection(FirestoreCollections.shops)
        .orderBy('fulfillmentRate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _shops = snapshot.docs
          .map((doc) => ShopModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .where((s) => s.isActive)
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

  Future<ShopModel?> getShopById(String shopId) async {
    final data = await _firestore.get(FirestoreCollections.shops, shopId);
    if (data == null) return null;
    return ShopModel.fromMap(shopId, data);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
