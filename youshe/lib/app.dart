import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'features/auth/providers/auth_provider.dart';

class YousheApp extends StatefulWidget {
  final AuthProvider authProvider;

  const YousheApp({super.key, required this.authProvider});

  @override
  State<YousheApp> createState() => _YousheAppState();
}

class _YousheAppState extends State<YousheApp> {
  Locale _locale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Youshe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        if (locale != null && supported.contains(locale)) return locale;
        return const Locale('en');
      },
      routerConfig: createRouter(widget.authProvider),
    );
  }
}
