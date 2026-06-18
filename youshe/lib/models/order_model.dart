class OrderItem {
  final String productId;
  final String nameEn;
  final String nameAr;
  final int quantity;
  final double price;
  final String size;

  OrderItem({
    required this.productId,
    required this.nameEn,
    required this.nameAr,
    required this.quantity,
    required this.price,
    this.size = '',
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] as String? ?? '',
      nameEn: data['nameEn'] as String? ?? '',
      nameAr: data['nameAr'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      size: data['size'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'quantity': quantity,
        'price': price,
        'size': size,
      };

  String displayName(String locale) => locale == 'ar' ? nameAr : nameEn;

  double get total => price * quantity;
}

class OrderModel {
  final String id;
  final String customerId;
  final String shopId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String deliveryAddress;
  final String customerPhone;
  final String customerName;
  final String customerNotes;
  final DateTime? createdAt;
  final DateTime? respondedAt;
  final bool autoCancelled;
  final String cancellationReason;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.shopId,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.deliveryAddress = '',
    this.customerPhone = '',
    this.customerName = '',
    this.customerNotes = '',
    this.createdAt,
    this.respondedAt,
    this.autoCancelled = false,
    this.cancellationReason = '',
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      customerId: data['customerId'] as String? ?? '',
      shopId: data['shopId'] as String? ?? '',
      items: (data['items'] as List?)
              ?.map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'pending',
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerNotes: data['customerNotes'] as String? ?? '',
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
      respondedAt: (data['respondedAt'] as dynamic)?.toDate(),
      autoCancelled: data['autoCancelled'] as bool? ?? false,
      cancellationReason: data['cancellationReason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'shopId': shopId,
        'items': items.map((e) => e.toMap()).toList(),
        'totalAmount': totalAmount,
        'status': status,
        'deliveryAddress': deliveryAddress,
        'customerPhone': customerPhone,
        'customerName': customerName,
        'customerNotes': customerNotes,
      };

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isDelivered => status == 'delivered';
  bool get isCompleted => status == 'completed';
}
