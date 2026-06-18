import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    '${t('cart')} ${t('isEmpty').toLowerCase()}',
                    style: const TextStyle(fontSize: 16, color: Colors.white38),
                  ),
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
                                      ? Image.network(product.images.first,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.image, color: Colors.white38))
                                      : const Icon(Icons.image, color: Colors.white38),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.displayName(locale),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                    if (item.selectedSize.isNotEmpty)
                                      Text(
                                        '${t('size')}: ${item.selectedSize}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Color(0xFF888888)),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.price.toStringAsFixed(2)} ${product.currency}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outlined,
                                              size: 20, color: Colors.white54),
                                          onPressed: () =>
                                              cart.updateQuantity(index, item.quantity - 1),
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outlined,
                                              size: 20, color: Colors.white54),
                                          onPressed: () =>
                                              cart.updateQuantity(index, item.quantity + 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outlined, color: Color(0xFFCF6679)),
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
                    color: const Color(0xFF1A1A1A),
                    border: const Border(top: BorderSide(color: Color(0xFF333333))),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
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
