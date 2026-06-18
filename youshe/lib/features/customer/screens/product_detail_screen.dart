import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  ProductModel? _product;
  String _selectedSize = '';
  int _quantity = 1;
  int _currentImageIndex = 0;
  double _buttonScale = 1.0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final product = await context.read<ProductProvider>().getProductById(widget.productId);
      if (mounted) setState(() => _product = product);
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

    if (_product == null) return Scaffold(appBar: AppBar(), body: const LoadingWidget());

    final product = _product!;

    return Scaffold(
      appBar: AppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
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
                        placeholder: (_, __) =>
                            const Center(child: CircularProgressIndicator(color: Colors.white24)),
                        errorWidget: (_, __, ___) =>
                            const Center(child: Icon(Icons.image, size: 60, color: Colors.white24)),
                      )
                    : Container(
                        color: const Color(0xFF1A1A1A),
                        child: const Center(child: Icon(Icons.image, size: 60, color: Colors.white24))),
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
                              color: _currentImageIndex == index ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: product.images[index],
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.image, size: 20, color: Colors.white38),
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
                    Text(
                      product.displayName(locale),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product.price.toStringAsFixed(2)} ${product.currency}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (product.displayDesc(locale).isNotEmpty) ...[
                      Text(
                        product.displayDesc(locale),
                        style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (product.sizes.isNotEmpty) ...[
                      const Text(
                        'Size',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: product.sizes.map((size) {
                          final selected = _selectedSize == size;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSize = selected ? '' : size),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected ? Colors.white : Colors.white24,
                                ),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  color: selected ? Colors.black : Colors.white54,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outlined, color: Colors.white54),
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outlined, color: Colors.white54),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTapDown: (_) => setState(() => _buttonScale = 0.95),
                      onTapUp: (_) {
                        setState(() => _buttonScale = 1.0);
                        context.read<CartProvider>().addItem(
                              product,
                              quantity: _quantity,
                              size: _selectedSize,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.displayName(locale)} ${t('addToCart').toLowerCase()}',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onTapCancel: () => setState(() => _buttonScale = 1.0),
                      child: AnimatedScale(
                        scale: _buttonScale,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_shopping_cart, color: Colors.black, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                t('addToCart'),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
