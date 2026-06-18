import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/constants.dart';
import '../../../core/demo_data.dart';
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
      final firestoreShops = snapshot.docs
          .map((doc) => ShopModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .where((s) => s.isActive)
          .toList();
      _shops = [...DemoData.shops, ...firestoreShops];
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _shops = List.from(DemoData.shops);
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<ShopModel?> getShopById(String shopId) async {
    if (shopId.startsWith(DemoData.shopIdPrefix)) {
      try {
        return DemoData.shops.firstWhere((s) => s.id == shopId);
      } catch (_) {
        return null;
      }
    }
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
