import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/constants.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadProductsByShop(String shopId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore
        .collection(FirestoreCollections.products)
        .where('shopId', isEqualTo: shopId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
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

  void loadAllProducts() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore
        .collection(FirestoreCollections.products)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
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

  Future<ProductModel?> getProductById(String productId) async {
    final data = await _firestore.get(FirestoreCollections.products, productId);
    if (data == null) return null;
    return ProductModel.fromMap(productId, data);
  }

  Future<List<ProductModel>> getSimilarProducts(String category, String excludeShopId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.products)
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .where((p) => p.shopId != excludeShopId)
        .toList();
  }

  List<ProductModel> filterProducts({String? category, double? minPrice, double? maxPrice, String? size}) {
    var filtered = List<ProductModel>.from(_products);
    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((p) => p.category == category).toList();
    }
    if (minPrice != null) {
      filtered = filtered.where((p) => p.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      filtered = filtered.where((p) => p.price <= maxPrice).toList();
    }
    if (size != null && size.isNotEmpty) {
      filtered = filtered.where((p) => p.sizes.contains(size)).toList();
    }
    return filtered;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
