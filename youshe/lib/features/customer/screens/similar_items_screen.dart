import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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

class _SimilarItemsScreenState extends State<SimilarItemsScreen>
    with SingleTickerProviderStateMixin {
  List? _products;
  bool _isLoading = true;
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
    _loadSimilarItems();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSimilarItems() async {
    final provider = context.read<ProductProvider>();
    final products = await provider.getSimilarProducts(widget.category, widget.excludeShopId);
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
      _fadeController.forward();
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
                      Icon(Icons.search_off,
                          size: 80, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(t('noProducts'),
                          style: const TextStyle(fontSize: 16, color: Colors.white38)),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          t('similarItemsFrom'),
                          style: const TextStyle(fontSize: 16, color: Color(0xFF888888)),
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
