import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/constants.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../models/product_model.dart';

class OwnerProductProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _authService = AuthService();
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  List<ProductModel> get products => _products;
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

  void loadMyProducts() async {
    final shopId = await getMyShopId();
    if (shopId == null) return;

    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore
        .collection(FirestoreCollections.products)
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
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

  Future<String> addProduct({
    required String shopId,
    required String nameEn,
    required String nameAr,
    String descEn = '',
    String descAr = '',
    required double price,
    List<String> sizes = const [],
    String category = '',
    List<String> imageUrls = const [],
  }) async {
    final docRef = await _firestore.add(FirestoreCollections.products, {
      'shopId': shopId,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'descEn': descEn,
      'descAr': descAr,
      'price': price,
      'currency': 'JOD',
      'sizes': sizes,
      'category': category,
      'images': imageUrls,
      'isAvailable': true,
    });
    return docRef.id;
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _firestore.update(FirestoreCollections.products, productId, data);
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.delete(FirestoreCollections.products, productId);
  }

  Future<ProductModel?> getProductById(String productId) async {
    final data = await _firestore.get(FirestoreCollections.products, productId);
    if (data == null) return null;
    return ProductModel.fromMap(productId, data);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
