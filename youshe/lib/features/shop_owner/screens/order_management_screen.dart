import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
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
                      Icon(Icons.receipt_long_outlined, size: 80, color: AppTheme.textSecondary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(t('noOrders'), style: const TextStyle(fontSize: 16)),
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
                            backgroundColor: order.isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            child: Icon(
                              order.isPending ? Icons.access_time : order.isConfirmed ? Icons.check : Icons.close,
                              color: order.isPending ? Colors.orange : order.isConfirmed ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text('${t('orderNumber')}${order.id.substring(0, 8)}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${order.totalAmount.toStringAsFixed(2)} JOD'),
                              Row(
                                children: [
                                  OrderStatusBadge(status: order.status, locale: locale),
                                  if (order.autoCancelled) ...[
                                    const SizedBox(width: 4),
                                    Text(t('autoCancelled'), style: const TextStyle(fontSize: 10, color: AppTheme.error)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/owner/orders/${order.id}'),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
