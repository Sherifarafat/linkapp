import 'package:flutter/material.dart';

import '../features/home/presentation/pages/home_page.dart';
import 'theme/app_theme.dart';

class LinkApp extends StatelessWidget {
  const LinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}
