import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/shop_provider.dart';
import '../../shared/widgets/shop_card.dart';
import '../../shared/widgets/loading_widget.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = '';

  final _categories = ['', 'Traditional', 'Modern', 'Sportswear', 'Abaya', 'Kids', 'Accessories'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().loadShops();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);
    final shopProvider = context.watch<ShopProvider>();

    var filteredShops = shopProvider.shops.where((s) {
      if (_searchController.text.isNotEmpty) {
        final q = _searchController.text.toLowerCase();
        if (!s.nameEn.toLowerCase().contains(q) && !s.nameAr.contains(q)) return false;
      }
      if (_selectedCategory.isNotEmpty && s.category != _selectedCategory) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t('shops'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: t('searchShops'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.isEmpty ? t('all') : cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = isSelected ? '' : cat),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: shopProvider.isLoading
                ? const LoadingWidget()
                : filteredShops.isEmpty
                    ? Center(child: Text(t('noShops')))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredShops.length,
                        itemBuilder: (context, index) {
                          final shop = filteredShops[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ShopCard(
                              shop: shop,
                              locale: locale,
                              onTap: () => context.go('/customer/shops/${shop.id}'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
