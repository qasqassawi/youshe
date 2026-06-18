import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/owner_order_provider.dart';
import '../providers/owner_product_provider.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _pendingCount = 0;
  int _totalProducts = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerOrderProvider>().loadMyShopOrders();
      context.read<OwnerProductProvider>().loadMyProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<OwnerOrderProvider>();
    final productProvider = context.watch<OwnerProductProvider>();

    _pendingCount = orderProvider.orders.where((o) => o.isPending).length;
    _totalProducts = productProvider.products.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          orderProvider.loadMyShopOrders();
          productProvider.loadMyProducts();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t('welcome'), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.shopping_bag_outlined,
                    label: t('totalOrders'),
                    value: '${orderProvider.orders.length}',
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.access_time,
                    label: t('pending'),
                    value: '$_pendingCount',
                    color: Colors.orange,
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
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.percent,
                    label: t('fulfillmentRate'),
                    value: '${authProvider.user?.uid != null ? "..." : "0"}%',
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(t('myOrders'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...orderProvider.orders.take(5).map((order) => Card(
                  child: ListTile(
                    leading: OrderStatusIcon(order.status),
                    title: Text('${t('orderNumber')}${order.id.substring(0, 8)}'),
                    subtitle: Text('${order.totalAmount.toStringAsFixed(2)} JOD'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/owner/orders/${order.id}'),
                  ),
                )),
            if (orderProvider.orders.length > 5)
              TextButton(
                onPressed: () => context.go('/owner/orders'),
                child: Text('${t('orders')} →'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
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
        return const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.access_time, color: Colors.white, size: 20));
      case 'confirmed':
        return const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.check, color: Colors.white, size: 20));
      case 'cancelled':
        return const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.close, color: Colors.white, size: 20));
      case 'delivered':
        return const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.local_shipping, color: Colors.white, size: 20));
      default:
        return const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.check_circle, color: Colors.white, size: 20));
    }
  }
}
