class AppConstants {
  static const String appName = 'Youshe';
  static const Duration orderResponseTimeout = Duration(hours: 2);
  static const Duration autoCancelInterval = Duration(minutes: 5);
  static const String defaultCurrency = 'JOD';
  static const String jordanCountryCode = '+962';
}

class FirestoreCollections {
  static const String users = 'users';
  static const String shops = 'shops';
  static const String products = 'products';
  static const String orders = 'orders';
  static const String notifications = 'notifications';
}

enum UserRole { customer, shopOwner }

extension UserRoleExt on UserRole {
  String get value {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.shopOwner:
        return 'shop_owner';
    }
  }

  static UserRole fromString(String s) {
    switch (s) {
      case 'customer':
        return UserRole.customer;
      case 'shop_owner':
        return UserRole.shopOwner;
      default:
        return UserRole.customer;
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  cancelled,
  delivered,
  completed;

  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.completed:
        return 'completed';
    }
  }

  static OrderStatus fromString(String s) {
    switch (s) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
        return OrderStatus.completed;
      default:
        return OrderStatus.pending;
    }
  }
}
