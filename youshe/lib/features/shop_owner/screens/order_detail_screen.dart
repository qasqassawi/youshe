import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/order_model.dart';
import '../providers/owner_order_provider.dart';
import '../../shared/widgets/order_status_badge.dart';
import '../../shared/widgets/loading_widget.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final provider = context.read<OwnerOrderProvider>();
    final order = await provider.getOrderById(widget.orderId);
    if (mounted) setState(() {
      _order = order;
      _isLoading = false;
    });
  }

  Future<void> _confirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Confirm Order', style: TextStyle(color: Colors.white)),
        content: const Text('Mark this order as confirmed?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yes, Confirm')),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<OwnerOrderProvider>().confirmOrder(widget.orderId);
      _loadOrder();
    }
  }

  Future<void> _cancel() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Reason for cancellation (optional)',
            hintStyle: TextStyle(color: Colors.white38),
          ),
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCF6679)),
            child: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (reason != null) {
      await context.read<OwnerOrderProvider>().cancelOrder(widget.orderId, reason: reason);
      _loadOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);

    if (_isLoading) {
      return Scaffold(appBar: AppBar(title: Text(t('orderDetail'))), body: const LoadingWidget());
    }
    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t('orderDetail'))),
        body: const Center(child: Text('Order not found', style: TextStyle(color: Colors.white38))),
      );
    }

    final order = _order!;

    return Scaffold(
      appBar: AppBar(title: Text(t('orderDetail'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${t('orderNumber')}${order.id.substring(0, 8)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              OrderStatusBadge(status: order.status, locale: locale),
            ],
          ),
          if (order.autoCancelled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCF6679).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFCF6679), size: 16),
                    const SizedBox(width: 8),
                    Text(t('autoCancelled'),
                        style: const TextStyle(
                            color: Color(0xFFCF6679), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(t('items'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          ...order.items.map((item) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.displayName(locale),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, color: Colors.white)),
                            if (item.size.isNotEmpty)
                              Text('${t('size')}: ${item.size}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                            Text('${t('quantity')}: ${item.quantity}',
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                      Text('${(item.price * item.quantity).toStringAsFixed(2)} JOD',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              )),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${order.totalAmount.toStringAsFixed(2)} JOD',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 24),
          Text(t('customerInfo'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.customerName.isNotEmpty)
                    _InfoRow(t('name'), order.customerName),
                  if (order.customerPhone.isNotEmpty)
                    _InfoRow(t('phone'), order.customerPhone),
                  if (order.deliveryAddress.isNotEmpty)
                    _InfoRow(t('deliveryAddress'), order.deliveryAddress),
                  if (order.customerNotes.isNotEmpty)
                    _InfoRow(t('customerNotes'), order.customerNotes),
                ],
              ),
            ),
          ),
          if (order.createdAt != null) ...[
            const SizedBox(height: 16),
            Text('${order.createdAt!.toLocal()}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
          ],
          if (order.cancellationReason.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('${t('cancelReason')}: ${order.cancellationReason}',
                style: const TextStyle(color: Color(0xFFCF6679))),
          ],
          const SizedBox(height: 32),
          if (order.isPending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirm,
                    icon: const Icon(Icons.check),
                    label: Text(t('confirmOrder')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _cancel,
                    icon: const Icon(Icons.close),
                    label: Text(t('cancelOrder')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFCF6679),
                      side: const BorderSide(color: Color(0xFFCF6679)),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          Text(
            t('orderWillAutoCancel'),
            style: const TextStyle(color: Color(0xFF888888), fontSize: 12, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}
