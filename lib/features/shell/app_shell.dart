import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/esik_icons.dart';
import '../../ui/glass_tab_bar.dart';

/// Sekmeli ana iskelet. İçerik cam çubuğun altına kadar uzanır.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const tabs = [
    GlassTab(icon: EsikIcon.moon, label: 'Bugün'),
    GlassTab(icon: EsikIcon.list, label: 'Liste'),
    GlassTab(icon: EsikIcon.history, label: 'Geçmiş'),
    GlassTab(icon: EsikIcon.sliders, label: 'Ayarlar'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, bottomInset + 14),
        child: GlassTabBar(
          tabs: tabs,
          currentIndex: navigationShell.currentIndex,
          onTabSelected: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
          onPrimary: () => context.push('/kontrol'),
        ),
      ),
    );
  }
}
