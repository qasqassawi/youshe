import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'constants.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/customer/screens/customer_home_screen.dart';
import '../features/customer/screens/shop_list_screen.dart';
import '../features/customer/screens/shop_detail_screen.dart';
import '../features/customer/screens/product_detail_screen.dart';
import '../features/customer/screens/cart_screen.dart';
import '../features/customer/screens/checkout_screen.dart';
import '../features/customer/screens/order_tracking_screen.dart';
import '../features/customer/screens/similar_items_screen.dart';
import '../features/shop_owner/screens/owner_dashboard_screen.dart';
import '../features/shop_owner/screens/product_form_screen.dart';
import '../features/shop_owner/screens/order_management_screen.dart';
import '../features/shop_owner/screens/order_detail_screen.dart';
import '../features/shop_owner/screens/shop_profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.user != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation.startsWith('/register');

      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
        return '/login';
      }

      if (isLoggedIn) {
        if (isLoginRoute || isRegisterRoute) {
          return authProvider.userRole == UserRole.shopOwner ? '/owner/dashboard' : '/customer/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(
            path: '/customer/home',
            builder: (context, state) => const CustomerHomeScreen(),
          ),
          GoRoute(
            path: '/customer/shops',
            builder: (context, state) => const ShopListScreen(),
          ),
          GoRoute(
            path: '/customer/shops/:shopId',
            builder: (context, state) => ShopDetailScreen(shopId: state.pathParameters['shopId']!),
          ),
          GoRoute(
            path: '/customer/products/:productId',
            builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['productId']!),
          ),
          GoRoute(
            path: '/customer/cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/customer/checkout',
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
            path: '/customer/orders',
            builder: (context, state) => const OrderTrackingScreen(),
          ),
          GoRoute(
            path: '/customer/similar-items',
            builder: (context, state) {
              final category = state.uri.queryParameters['category'] ?? '';
              final excludeShopId = state.uri.queryParameters['excludeShopId'] ?? '';
              return SimilarItemsScreen(category: category, excludeShopId: excludeShopId);
            },
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => OwnerShell(child: child),
        routes: [
          GoRoute(
            path: '/owner/dashboard',
            builder: (context, state) => const OwnerDashboardScreen(),
          ),
          GoRoute(
            path: '/owner/products',
            builder: (context, state) => const ProductFormScreen(),
          ),
          GoRoute(
            path: '/owner/products/add',
            builder: (context, state) => const ProductFormScreen(isEditing: false),
          ),
          GoRoute(
            path: '/owner/products/:productId/edit',
            builder: (context, state) => ProductFormScreen(
              isEditing: true,
              productId: state.pathParameters['productId'],
            ),
          ),
          GoRoute(
            path: '/owner/orders',
            builder: (context, state) => const OrderManagementScreen(),
          ),
          GoRoute(
            path: '/owner/orders/:orderId',
            builder: (context, state) => OrderDetailScreen(orderId: state.pathParameters['orderId']!),
          ),
          GoRoute(
            path: '/owner/shop',
            builder: (context, state) => const ShopProfileScreen(),
          ),
        ],
      ),
    ],
  );
}

class CustomerShell extends StatefulWidget {
  final Widget child;
  const CustomerShell({super.key, required this.child});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              context.go('/customer/home');
              break;
            case 1:
              context.go('/customer/shops');
              break;
            case 2:
              context.go('/customer/cart');
              break;
            case 3:
              context.go('/customer/orders');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.store_outlined), label: 'Shops'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt_outlined), label: 'Orders'),
        ],
      ),
    );
  }
}

class OwnerShell extends StatefulWidget {
  final Widget child;
  const OwnerShell({super.key, required this.child});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              context.go('/owner/dashboard');
              break;
            case 1:
              context.go('/owner/products');
              break;
            case 2:
              context.go('/owner/orders');
              break;
            case 3:
              context.go('/owner/shop');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_outlined), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.receipt_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.store_outlined), label: 'Shop'),
        ],
      ),
    );
  }
}
