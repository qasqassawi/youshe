import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/owner_order_provider.dart';
import '../../shared/widgets/order_status_badge.dart';
import '../../shared/widgets/loading_widget.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerOrderProvider>().loadMyShopOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);
    final orderProvider = context.watch<OwnerOrderProvider>();

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
                  onRefresh: () async => orderProvider.loadMyShopOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orderProvider.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderProvider.orders[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF333333),
                            child: Icon(
                              order.isPending
                                  ? Icons.access_time
                                  : order.isConfirmed
                                      ? Icons.check
                                      : Icons.close,
                              color: order.isPending
                                  ? Colors.white70
                                  : order.isConfirmed
                                      ? Colors.white
                                      : const Color(0xFFCF6679),
                            ),
                          ),
                          title: Text('${t('orderNumber')}${order.id.substring(0, 8)}',
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${order.totalAmount.toStringAsFixed(2)} JOD',
                                  style: const TextStyle(color: Color(0xFF888888))),
                              Row(
                                children: [
                                  OrderStatusBadge(status: order.status, locale: locale),
                                  if (order.autoCancelled) ...[
                                    const SizedBox(width: 4),
                                    Text(t('autoCancelled'),
                                        style: const TextStyle(
                                            fontSize: 10, color: Color(0xFFCF6679))),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                          onTap: () => context.go('/owner/orders/${order.id}'),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
