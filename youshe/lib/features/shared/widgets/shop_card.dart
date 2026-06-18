import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/shop_model.dart';
import '../../../core/theme.dart';

class ShopCard extends StatelessWidget {
  final ShopModel shop;
  final String locale;
  final VoidCallback? onTap;

  const ShopCard({
    super.key,
    required this.shop,
    required this.locale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
              ),
              child: shop.coverUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: shop.coverUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => const Icon(Icons.store, size: 40, color: AppTheme.textSecondary),
                    )
                  : const Icon(Icons.store, size: 40, color: AppTheme.textSecondary),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    backgroundImage: shop.logoUrl.isNotEmpty ? NetworkImage(shop.logoUrl) : null,
                    child: shop.logoUrl.isEmpty ? const Icon(Icons.store, size: 20, color: AppTheme.primary) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.displayName(locale),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (shop.city.isNotEmpty)
                          Text(shop.city, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  _FulfillmentBadge(rate: shop.fulfillmentRate),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FulfillmentBadge extends StatelessWidget {
  final double rate;
  const _FulfillmentBadge({required this.rate});

  @override
  Widget build(BuildContext context) {
    final color = rate >= 90
        ? Colors.green
        : rate >= 70
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${rate.toStringAsFixed(0)}%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
