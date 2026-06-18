import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(fontSize: 16)),
          ] else ...[
            const SizedBox(height: 16),
            Text(t('loading'), style: const TextStyle(fontSize: 16)),
          ],
        ],
      ),
    );
  }
}
