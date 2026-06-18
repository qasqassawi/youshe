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

  final _categories = ['', 'Traditional', 'Modern', 'Sportswear', 'Kids', 'Accessories'];

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
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = isSelected ? '' : cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white24,
                        ),
                      ),
                      child: Text(
                        cat.isEmpty ? t('all') : cat,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white54,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: shopProvider.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: 4,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShopSkeleton(),
                    ),
                  )
                : filteredShops.isEmpty
                    ? Center(child: Text(t('noShops'), style: const TextStyle(color: Colors.white38)))
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
