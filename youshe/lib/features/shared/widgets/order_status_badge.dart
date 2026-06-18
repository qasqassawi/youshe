import 'package:flutter/material.dart';
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
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.color.withOpacity(0.3)),
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
        return _Config(Colors.white70);
      case 'confirmed':
        return _Config(Colors.white);
      case 'cancelled':
        return _Config(const Color(0xFFCF6679));
      case 'delivered':
        return _Config(Colors.white70);
      case 'completed':
        return _Config(Colors.white);
      default:
        return _Config(Colors.white38);
    }
  }
}

class _Config {
  final Color color;
  _Config(this.color);
}
