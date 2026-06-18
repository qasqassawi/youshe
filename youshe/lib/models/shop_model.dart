class ShopModel {
  final String id;
  final String ownerId;
  final String nameEn;
  final String nameAr;
  final String descEn;
  final String descAr;
  final String logoUrl;
  final String coverUrl;
  final String category;
  final String city;
  final String phone;
  final double fulfillmentRate;
  final int totalOrders;
  final int successfulOrders;
  final bool isActive;
  final bool isDemo;
  final DateTime? createdAt;

  ShopModel({
    required this.id,
    required this.ownerId,
    required this.nameEn,
    required this.nameAr,
    this.descEn = '',
    this.descAr = '',
    this.logoUrl = '',
    this.coverUrl = '',
    this.category = '',
    this.city = '',
    this.phone = '',
    this.fulfillmentRate = 100.0,
    this.totalOrders = 0,
    this.successfulOrders = 0,
    this.isActive = true,
    this.isDemo = false,
    this.createdAt,
  });

  factory ShopModel.fromMap(String id, Map<String, dynamic> data) {
    return ShopModel(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      nameEn: data['nameEn'] as String? ?? '',
      nameAr: data['nameAr'] as String? ?? '',
      descEn: data['descEn'] as String? ?? '',
      descAr: data['descAr'] as String? ?? '',
      logoUrl: data['logoUrl'] as String? ?? '',
      coverUrl: data['coverUrl'] as String? ?? '',
      category: data['category'] as String? ?? '',
      city: data['city'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      fulfillmentRate: (data['fulfillmentRate'] as num?)?.toDouble() ?? 100.0,
      totalOrders: (data['totalOrders'] as num?)?.toInt() ?? 0,
      successfulOrders: (data['successfulOrders'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      isDemo: data['isDemo'] as bool? ?? false,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'descEn': descEn,
        'descAr': descAr,
        'logoUrl': logoUrl,
        'coverUrl': coverUrl,
        'category': category,
        'city': city,
        'phone': phone,
        'fulfillmentRate': fulfillmentRate,
        'totalOrders': totalOrders,
        'successfulOrders': successfulOrders,
        'isActive': isActive,
        'isDemo': isDemo,
      };

  String displayName(String locale) => locale == 'ar' ? nameAr : nameEn;
  String displayDesc(String locale) => locale == 'ar' ? descAr : descEn;
}
