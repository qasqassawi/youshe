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

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().loadShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);
    final shopProvider = context.watch<ShopProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(t('appName')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/customer/shops'),
          ),
        ],
      ),
      body: shopProvider.isLoading
          ? const LoadingWidget()
          : shopProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t('error')),
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
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: shopProvider.shops.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            t('shops'),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      final shop = shopProvider.shops[index - 1];
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
    );
  }
}
