import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import 'theme/app_theme.dart';

class LinkApp extends StatefulWidget {
  const LinkApp({super.key});

  @override
  State<LinkApp> createState() => _LinkAppState();
}

class _LinkAppState extends State<LinkApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      themeAnimationDuration: Duration.zero,
      themeAnimationCurve: Curves.easeOutCubic,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: LoginPage(
        onAuthenticated: () => _navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => HomePage(
              isDarkMode: _themeMode == ThemeMode.dark,
              isArabic: _locale.languageCode == 'ar',
              onLanguageToggle: () => setState(() {
                _locale = _locale.languageCode == 'ar'
                    ? const Locale('en')
                    : const Locale('ar');
              }),
              onThemeToggle: () => setState(() {
                _themeMode = _themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
              }),
            ),
          ),
        ),
      ),
    );
  }
}
