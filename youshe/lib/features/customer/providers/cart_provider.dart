import 'package:flutter/foundation.dart';
import '../../../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  String selectedSize;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize = '',
  });

  double get total => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.total);

  bool get isEmpty => _items.isEmpty;

  void addItem(ProductModel product, {int quantity = 1, String size = ''}) {
    final index = _items.indexWhere((item) => item.product.id == product.id && item.selectedSize == size);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity, selectedSize: size));
    }
    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = quantity;
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
