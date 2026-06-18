class ProductModel {
  final String id;
  final String shopId;
  final String nameEn;
  final String nameAr;
  final String descEn;
  final String descAr;
  final double price;
  final String currency;
  final List<String> sizes;
  final String category;
  final List<String> images;
  final bool isAvailable;
  final bool isDemo;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.shopId,
    required this.nameEn,
    required this.nameAr,
    this.descEn = '',
    this.descAr = '',
    required this.price,
    this.currency = 'JOD',
    this.sizes = const [],
    this.category = '',
    this.images = const [],
    this.isAvailable = true,
    this.isDemo = false,
    this.createdAt,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      shopId: data['shopId'] as String? ?? '',
      nameEn: data['nameEn'] as String? ?? '',
      nameAr: data['nameAr'] as String? ?? '',
      descEn: data['descEn'] as String? ?? '',
      descAr: data['descAr'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'JOD',
      sizes: List<String>.from(data['sizes'] as List? ?? []),
      category: data['category'] as String? ?? '',
      images: List<String>.from(data['images'] as List? ?? []),
      isAvailable: data['isAvailable'] as bool? ?? true,
      isDemo: data['isDemo'] as bool? ?? false,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'shopId': shopId,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'descEn': descEn,
        'descAr': descAr,
        'price': price,
        'currency': currency,
        'sizes': sizes,
        'category': category,
        'images': images,
        'isAvailable': isAvailable,
        'isDemo': isDemo,
      };

  String displayName(String locale) => locale == 'ar' ? nameAr : nameEn;
  String displayDesc(String locale) => locale == 'ar' ? descAr : descEn;
}
