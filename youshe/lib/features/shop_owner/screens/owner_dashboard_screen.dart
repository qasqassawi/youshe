import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../customer/providers/shop_provider.dart';
import '../providers/owner_order_provider.dart';
import '../providers/owner_product_provider.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _pendingCount = 0;
  int _totalProducts = 0;
  double _fulfillmentRate = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerOrderProvider>().loadMyShopOrders();
      context.read<OwnerProductProvider>().loadMyProducts();
      _loadShopData();
    });
  }

  void _loadShopData() {
    context.read<ShopProvider>().loadShops();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<OwnerOrderProvider>();
    final productProvider = context.watch<OwnerProductProvider>();
    final shopProvider = context.watch<ShopProvider>();

    _pendingCount = orderProvider.orders.where((o) => o.isPending).length;
    _totalProducts = productProvider.products.length;

    final ownerShops = shopProvider.shops
        .where((s) => s.ownerId == (authProvider.user?.uid ?? ''))
        .toList();
    _fulfillmentRate =
        ownerShops.isNotEmpty ? ownerShops.first.fulfillmentRate : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            orderProvider.loadMyShopOrders();
            productProvider.loadMyProducts();
            _loadShopData();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                t('welcome'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.shopping_bag_outlined,
                      label: t('totalOrders'),
                      value: '${orderProvider.orders.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.access_time,
                      label: t('pending'),
                      value: '$_pendingCount',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.inventory,
                      label: t('items'),
                      value: '$_totalProducts',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.percent,
                      label: t('fulfillmentRate'),
                      value: '${_fulfillmentRate.toStringAsFixed(0)}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                t('myOrders'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...orderProvider.orders.take(5).map((order) => Card(
                    child: ListTile(
                      leading: OrderStatusIcon(order.status),
                      title: Text(
                        '${t('orderNumber')}${order.id.substring(0, 8)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${order.totalAmount.toStringAsFixed(2)} JOD',
                        style: const TextStyle(color: Color(0xFF888888)),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                      onTap: () => context.go('/owner/orders/${order.id}'),
                    ),
                  )),
              if (orderProvider.orders.length > 5)
                TextButton(
                  onPressed: () => context.go('/owner/orders'),
                  child: Text('${t('orders')} →',
                      style: const TextStyle(color: Colors.white54)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white54),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderStatusIcon extends StatelessWidget {
  final String status;
  const OrderStatusIcon(this.status);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'pending':
        return const CircleAvatar(
          backgroundColor: Color(0xFF333333),
          child: Icon(Icons.access_time, color: Colors.white70, size: 20),
        );
      case 'confirmed':
        return const CircleAvatar(
          backgroundColor: Color(0xFF333333),
          child: Icon(Icons.check, color: Colors.white, size: 20),
        );
      case 'cancelled':
        return const CircleAvatar(
          backgroundColor: Color(0xFF333333),
          child: Icon(Icons.close, color: Color(0xFFCF6679), size: 20),
        );
      case 'delivered':
        return const CircleAvatar(
          backgroundColor: Color(0xFF333333),
          child: Icon(Icons.local_shipping, color: Colors.white70, size: 20),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Color(0xFF333333),
          child: Icon(Icons.check_circle, color: Colors.white70, size: 20),
        );
    }
  }
}
