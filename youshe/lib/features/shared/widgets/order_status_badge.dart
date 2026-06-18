import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final String locale;

  const OrderStatusBadge({
    super.key,
    required this.status,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final t = (String key) => AppLocalizations.t(key, locale);
    final config = _getConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        t(status),
        style: TextStyle(
          color: config.color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  _Config _getConfig() {
    switch (status) {
      case 'pending':
        return _Config(Colors.orange);
      case 'confirmed':
        return _Config(Colors.blue);
      case 'cancelled':
        return _Config(Colors.red);
      case 'delivered':
        return _Config(Colors.green);
      case 'completed':
        return _Config(AppTheme.primary);
      default:
        return _Config(AppTheme.textSecondary);
    }
  }
}

class _Config {
  final Color color;
  _Config(this.color);
}
