import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/product_provider.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/loading_widget.dart';

class SimilarItemsScreen extends StatefulWidget {
  final String category;
  final String excludeShopId;

  const SimilarItemsScreen({
    super.key,
    required this.category,
    required this.excludeShopId,
  });

  @override
  State<SimilarItemsScreen> createState() => _SimilarItemsScreenState();
}

class _SimilarItemsScreenState extends State<SimilarItemsScreen> {
  List? _products;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSimilarItems();
  }

  Future<void> _loadSimilarItems() async {
    final provider = context.read<ProductProvider>();
    final products = await provider.getSimilarProducts(widget.category, widget.excludeShopId);
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);

    return Scaffold(
      appBar: AppBar(title: Text(t('similarItems'))),
      body: _isLoading
          ? const LoadingWidget()
          : _products == null || _products!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: AppTheme.textSecondary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(t('noProducts'), style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        t('similarItemsFrom'),
                        style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _products!.length,
                        itemBuilder: (context, index) {
                          final product = _products![index] as dynamic;
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
