import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../../shared/widgets/loading_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  String _selectedSize = '';
  int _quantity = 1;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final product = await context.read<ProductProvider>().getProductById(widget.productId);
      if (mounted) setState(() => _product = product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);

    if (_product == null) return Scaffold(appBar: AppBar(), body: const LoadingWidget());

    final product = _product!;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: product.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.images[_currentImageIndex % product.images.length],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => const Center(child: Icon(Icons.image, size: 60)),
                    )
                  : Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image, size: 60))),
            ),
            if (product.images.length > 1)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: product.images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => setState(() => _currentImageIndex = index),
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentImageIndex == index ? AppTheme.primary : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: product.images[index],
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(Icons.image, size: 20),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.displayName(locale), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${product.price.toStringAsFixed(2)} ${product.currency}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accent),
                  ),
                  const SizedBox(height: 12),
                  if (product.displayDesc(locale).isNotEmpty) ...[
                    Text(product.displayDesc(locale), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 16),
                  ],
                  if (product.sizes.isNotEmpty) ...[
                    Text(t('size'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: product.sizes.map((size) {
                        final selected = _selectedSize == size;
                        return ChoiceChip(
                          label: Text(size),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedSize = selected ? '' : size),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Text(t('quantity'), style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outlined),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outlined),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<CartProvider>().addItem(
                              product,
                              quantity: _quantity,
                              size: _selectedSize,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.displayName(locale)} ${t('addToCart').toLowerCase()}')),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(t('addToCart')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
