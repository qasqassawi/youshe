import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/firebase_options.dart';
import 'core/services/logging_service.dart';
import 'core/services/notification_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/customer/providers/cart_provider.dart';
import 'features/customer/providers/shop_provider.dart';
import 'features/customer/providers/product_provider.dart';
import 'features/customer/providers/order_provider.dart';
import 'features/shop_owner/providers/owner_product_provider.dart';
import 'features/shop_owner/providers/owner_order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptionsProvider.webOptions,
    );
    LoggingService().info('Firebase initialized', tag: 'Main');

    await NotificationService().initialize();
  } catch (e) {
    LoggingService().error('Firebase init failed', tag: 'Main', error: e);
  }

  final authProvider = AuthProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => OwnerProductProvider()),
        ChangeNotifierProvider(create: (_) => OwnerOrderProvider()),
      ],
      child: YousheApp(authProvider: authProvider),
    ),
  );
}
