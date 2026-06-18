import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String phone;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.phone = '',
    this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? 'customer',
      phone: data['phone'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'role': role,
        'phone': phone,
      };

  bool get isShopOwner => role == 'shop_owner';
}
