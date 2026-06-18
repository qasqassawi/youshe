import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isPlacing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacing = true);

    try {
      final cart = context.read<CartProvider>();
      final orderProvider = context.read<OrderProvider>();

      final firstItem = cart.items.first.product;
      final shopId = firstItem.shopId;

      final orderItems = cart.items
          .map((item) => OrderItem(
                productId: item.product.id,
                nameEn: item.product.nameEn,
                nameAr: item.product.nameAr,
                quantity: item.quantity,
                price: item.product.price,
                size: item.selectedSize,
              ))
          .toList();

      await orderProvider.placeOrder(
        shopId: shopId,
        items: orderItems,
        totalAmount: cart.totalAmount,
        deliveryAddress: _addressController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        customerName: '',
        customerNotes: _notesController.text.trim(),
      );

      cart.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!'), behavior: SnackBarBehavior.floating),
        );
        context.go('/customer/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);
    final cart = context.watch<CartProvider>();

    if (cart.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/customer/cart'));
      return Scaffold(appBar: AppBar(title: Text(t('checkout'))), body: const SizedBox());
    }

    return Scaffold(
      appBar: AppBar(title: Text(t('checkout'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...cart.items.map((item) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.displayName(locale),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, color: Colors.white)),
                              if (item.selectedSize.isNotEmpty)
                                Text('${t('size')}: ${item.selectedSize}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                              Text('${t('quantity')}: ${item.quantity}',
                                  style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                        Text(
                          '${(item.product.price * item.quantity).toStringAsFixed(2)} JOD',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: t('deliveryAddress'),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.location_on_outlined, color: Colors.white54),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (v) => (v == null || v.trim().isEmpty) ? t('fieldRequired') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: t('phone'),
                prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white54),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (v) => (v == null || v.trim().isEmpty) ? t('fieldRequired') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: '${t('customerNotes')} (${t('optional')})',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.note_outlined, color: Colors.white54),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(
                          '${cart.totalAmount.toStringAsFixed(2)} JOD',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on_outlined,
                              color: Colors.white54, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            t('cashOnDelivery'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t('orderWillAutoCancel'),
              style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPlacing ? null : _placeOrder,
                child: _isPlacing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : Text(t('placeOrder')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
