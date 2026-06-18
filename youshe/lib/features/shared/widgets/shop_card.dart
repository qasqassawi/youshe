import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/shop_model.dart';

class ShopCard extends StatefulWidget {
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
  State<ShopCard> createState() => _ShopCardState();
}

class _ShopCardState extends State<ShopCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                color: const Color(0xFF1A1A1A),
                child: shop.coverUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: shop.coverUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: Colors.white24)),
                        errorWidget: (_, __, ___) => const Icon(Icons.store, size: 40, color: Colors.white24),
                      )
                    : const Icon(Icons.store, size: 40, color: Colors.white24),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white12,
                      backgroundImage: shop.logoUrl.isNotEmpty ? NetworkImage(shop.logoUrl) : null,
                      child: shop.logoUrl.isEmpty
                          ? const Icon(Icons.store, size: 20, color: Colors.white54)
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
                                  shop.displayName(widget.locale),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (shop.isDemo) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                          if (shop.city.isNotEmpty)
                            Text(
                              shop.city,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${shop.fulfillmentRate.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
