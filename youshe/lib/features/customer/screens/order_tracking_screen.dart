import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
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
                      Icon(Icons.receipt_long_outlined, size: 80, color: AppTheme.textSecondary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(t('noOrders'), style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
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
                      return _OrderCard(order: order, locale: locale, t: t);
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

  const _OrderCard({required this.order, required this.locale, required this.t});

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
                Text('${t('orderNumber')}${order.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                OrderStatusBadge(status: order.status, locale: locale),
              ],
            ),
            const SizedBox(height: 8),
            ...order.items.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${item.displayName(locale)} x${item.quantity}',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                )),
            if (order.items.length > 3)
              Text('+${order.items.length - 3} ${t('items').toLowerCase()}', style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.totalAmount.toStringAsFixed(2)} JOD',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accent),
                ),
                if (order.createdAt != null)
                  Text(
                    '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
              ],
            ),
            if (order.autoCancelled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(t('autoCancelled'), style: const TextStyle(color: AppTheme.error, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
