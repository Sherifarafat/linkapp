import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import 'widgets/network_alert.dart';
import 'theme/app_theme.dart';

class LinkApp extends StatefulWidget {
  const LinkApp({super.key});

  @override
  State<LinkApp> createState() => _LinkAppState();
}

class _LinkAppState extends State<LinkApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<InternetStatus>? _networkSubscription;
  late final AppLifecycleListener _lifecycleListener;
  bool _isOffline = false;
  bool _offlineAlertShown = false;
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');
  AppAccentColor _accentColor = AppAccentColor.blue;

  @override
  void initState() {
    super.initState();
    _startNetworkMonitoring();
    _lifecycleListener = AppLifecycleListener(
      onResume: _startNetworkMonitoring,
      onPause: _stopNetworkMonitoring,
    );
  }

  void _startNetworkMonitoring() {
    if (_networkSubscription != null) return;
    _networkSubscription = InternetConnection().onStatusChange.listen(
      (status) {
        if (status == InternetStatus.connected) {
          _isOffline = false;
          _offlineAlertShown = false;
          return;
        }

        _isOffline = true;
        if (_offlineAlertShown) return;
        _offlineAlertShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_isOffline) return;
          final navigator = _navigatorKey.currentState;
          if (navigator == null) {
            _offlineAlertShown = false;
            return;
          }
          unawaited(
            NetworkAlert.showOnNavigator(
              navigator,
              isArabic: _locale.languageCode == 'ar',
            ),
          );
        });
      },
      onError: (_) {},
    );
  }

  void _stopNetworkMonitoring() {
    final subscription = _networkSubscription;
    _networkSubscription = null;
    if (subscription != null) unawaited(subscription.cancel());
  }

  @override
  void dispose() {
    _stopNetworkMonitoring();
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: AppTheme.light(_accentColor),
      darkTheme: AppTheme.dark(_accentColor),
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
              accentColor: _accentColor,
              onAccentColorChanged: (color) => setState(() => _accentColor = color),
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
