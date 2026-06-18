import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/order_model.dart';
import '../providers/order_provider.dart';
import '../../shared/widgets/order_status_badge.dart';
import '../../shared/widgets/loading_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t('orders'))),
      body: orderProvider.isLoading
          ? const LoadingWidget()
          : orderProvider.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 80, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(t('noOrders'),
                          style: const TextStyle(fontSize: 16, color: Colors.white38)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => orderProvider.loadMyOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orderProvider.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderProvider.orders[index];
                      return _OrderCard(
                        order: order,
                        locale: locale,
                        t: t,
                        onViewSimilar: order.isCancelled && !order.autoCancelled
                            ? () {
                                if (order.items.isNotEmpty) {
                                  final category =
                                      order.items.first.displayName(locale);
                                  context.go(
                                    '/customer/similar-items?category=$category&excludeShopId=${order.shopId}',
                                  );
                                }
                              }
                            : null,
                      );
                    },
                  ),
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String locale;
  final String Function(String) t;
  final VoidCallback? onViewSimilar;

  const _OrderCard({
    required this.order,
    required this.locale,
    required this.t,
    this.onViewSimilar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${t('orderNumber')}${order.id.substring(0, 8)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                OrderStatusBadge(status: order.status, locale: locale),
              ],
            ),
            const SizedBox(height: 8),
            ...order.items.take(3).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${item.displayName(locale)} x${item.quantity}',
                      style: const TextStyle(color: Color(0xFF888888)),
                    ),
                  ),
                ),
            if (order.items.length > 3)
              Text('+${order.items.length - 3} ${t('items').toLowerCase()}',
                  style: const TextStyle(color: Color(0xFF888888))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.totalAmount.toStringAsFixed(2)} JOD',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
                if (order.createdAt != null)
                  Text(
                    '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
              ],
            ),
            if (order.autoCancelled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(t('autoCancelled'),
                    style:
                        const TextStyle(color: Color(0xFFCF6679), fontSize: 12)),
              ),
            if (onViewSimilar != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onViewSimilar,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: Text(t('similarItems')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
