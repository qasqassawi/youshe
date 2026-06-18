import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class _ShopDetailScreenState extends State<ShopDetailScreen>
    with SingleTickerProviderStateMixin {
  ShopModel? _shop;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shop = await context.read<ShopProvider>().getShopById(widget.shopId);
      if (mounted) {
        setState(() => _shop = shop);
        _fadeController.forward();
        context.read<ProductProvider>().loadProductsByShop(widget.shopId);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);
    final productProvider = context.watch<ProductProvider>();

    if (_shop == null) return Scaffold(appBar: AppBar(), body: const LoadingWidget());

    return Scaffold(
      appBar: AppBar(title: Text(_shop!.displayName(locale))),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFF1A1A1A),
              child: _shop!.coverUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _shop!.coverUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.store, size: 60, color: Colors.white24),
                    )
                  : const Icon(Icons.store, size: 60, color: Colors.white24),
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
                        backgroundColor: Colors.white12,
                        backgroundImage:
                            _shop!.logoUrl.isNotEmpty ? NetworkImage(_shop!.logoUrl) : null,
                        child: _shop!.logoUrl.isEmpty
                            ? const Icon(Icons.store, color: Colors.white54)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _shop!.displayName(locale),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_shop!.isDemo) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white24),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: const Text(
                                      'DEMO',
                                      style: TextStyle(
                                        fontSize: 7,
                                        color: Colors.white38,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (_shop!.city.isNotEmpty)
                              Text(
                                '${_shop!.city} · ${_shop!.category}',
                                style: const TextStyle(color: Color(0xFF888888)),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_shop!.fulfillmentRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_shop!.displayDesc(locale).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _shop!.displayDesc(locale),
                      style: const TextStyle(color: Color(0xFF888888)),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                t('items'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: productProvider.isLoading
                  ? GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 4,
                      itemBuilder: (_, __) => const ProductSkeleton(),
                    )
                  : productProvider.products.isEmpty
                      ? Center(
                          child: Text(t('noProducts'), style: const TextStyle(color: Colors.white38)))
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
                              onTap: () =>
                                  context.go('/customer/products/${product.id}'),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
