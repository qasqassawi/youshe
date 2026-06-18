import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t('cart'))),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: AppTheme.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('${t('cart')} ${t('isEmpty').toLowerCase()}', style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final product = item.product;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: product.images.isNotEmpty
                                      ? Image.network(product.images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                                      : const Icon(Icons.image),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.displayName(locale), style: const TextStyle(fontWeight: FontWeight.w600)),
                                    if (item.selectedSize.isNotEmpty)
                                      Text('${t('size')}: ${item.selectedSize}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                    const SizedBox(height: 4),
                                    Text('${product.price.toStringAsFixed(2)} ${product.currency}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent)),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outlined, size: 20),
                                          onPressed: () => cart.updateQuantity(index, item.quantity - 1),
                                        ),
                                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outlined, size: 20),
                                          onPressed: () => cart.updateQuantity(index, item.quantity + 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outlined, color: AppTheme.error),
                                onPressed: () => cart.removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(t('total'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              '${cart.totalAmount.toStringAsFixed(2)} JOD',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/customer/checkout'),
                            child: Text(t('checkout')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
