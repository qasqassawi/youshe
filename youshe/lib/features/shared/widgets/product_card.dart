import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/product_model.dart';
import '../../../core/theme.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final String locale;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.locale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: product.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.images.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => const Center(child: Icon(Icons.image, color: AppTheme.textSecondary)),
                    )
                  : const Center(child: Icon(Icons.image, size: 40, color: AppTheme.textSecondary)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.displayName(locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(2)} ${product.currency}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                      fontSize: 14,
                    ),
                  ),
                  if (product.sizes.isNotEmpty)
                    Text(
                      product.sizes.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
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
