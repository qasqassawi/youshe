import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/shop_model.dart';
import '../providers/shop_provider.dart';
import '../providers/product_provider.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/loading_widget.dart';

class ShopDetailScreen extends StatefulWidget {
  final String shopId;
  const ShopDetailScreen({super.key, required this.shopId});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  ShopModel? _shop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shop = await context.read<ShopProvider>().getShopById(widget.shopId);
      if (mounted) {
        setState(() => _shop = shop);
        context.read<ProductProvider>().loadProductsByShop(widget.shopId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);
    final productProvider = context.watch<ProductProvider>();

    if (_shop == null) return Scaffold(appBar: AppBar(), body: const LoadingWidget());

    return Scaffold(
      appBar: AppBar(title: Text(_shop!.displayName(locale))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1)),
            child: _shop!.coverUrl.isNotEmpty
                ? Image.network(_shop!.coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 60))
                : const Icon(Icons.store, size: 60),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      backgroundImage: _shop!.logoUrl.isNotEmpty ? NetworkImage(_shop!.logoUrl) : null,
                      child: _shop!.logoUrl.isEmpty ? const Icon(Icons.store) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_shop!.displayName(locale), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          if (_shop!.city.isNotEmpty)
                            Text('${_shop!.city} · ${_shop!.category}', style: const TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${t('fulfillmentRate')}: ${_shop!.fulfillmentRate.toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                if (_shop!.displayDesc(locale).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_shop!.displayDesc(locale), style: const TextStyle(color: AppTheme.textSecondary)),
                ],
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              t('items'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: productProvider.isLoading
                ? const LoadingWidget()
                : productProvider.products.isEmpty
                    ? Center(child: Text(t('noProducts')))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: productProvider.products.length,
                        itemBuilder: (context, index) {
                          final product = productProvider.products[index];
                          return ProductCard(
                            product: product,
                            locale: locale,
                            onTap: () => context.go('/customer/products/${product.id}'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
