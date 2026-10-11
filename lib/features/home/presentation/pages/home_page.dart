import 'package:flutter/material.dart';

import '../widgets/home_bottom_bar.dart';
import '../widgets/home_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: HomeHeader(
                onMenuPressed: _openMenu,
                onProfilePressed: _openProfile,
              ),
            ),
            Expanded(child: SizedBox.expand()),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(onAddPressed: _add),
    );
  }

  static void _openMenu() {}

  static void _openProfile() {}

  static void _add() {}
}
