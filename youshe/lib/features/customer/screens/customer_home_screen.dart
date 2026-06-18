import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/shop_provider.dart';
import '../../shared/widgets/shop_card.dart';
import '../../shared/widgets/loading_widget.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final _searchController = TextEditingController();
  String _selectedCategory = '';

  final _categories = ['', 'Traditional', 'Modern', 'Sportswear', 'Kids', 'Accessories'];

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().loadShops();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
      appBar: AppBar(
        title: Text(t('appName')),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: shopProvider.isLoading
            ? ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ShopSkeleton(),
                ),
              )
            : shopProvider.error != null && shopProvider.shops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t('error'), style: const TextStyle(color: Colors.white54)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => shopProvider.loadShops(),
                          child: Text(t('tryAgain')),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => shopProvider.loadShops(),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
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
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 36,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: _categories.map((cat) {
                                      final isSelected = _selectedCategory == cat;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () => setState(() =>
                                              _selectedCategory = isSelected ? '' : cat),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.white24,
                                              ),
                                            ),
                                            child: Text(
                                              cat.isEmpty ? t('all') : cat,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.white54,
                                                fontSize: 13,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  t('browseShops'),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${filteredShops.length} ${t('shops').toLowerCase()}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white38,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= filteredShops.length) return null;
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
                            childCount: filteredShops.length,
                          ),
                        ),
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 16),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
