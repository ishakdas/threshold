import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/esik_icons.dart';
import '../../ui/glass_tab_bar.dart';
import '../../l10n/texts.dart';

/// Sekmeli ana iskelet. İçerik cam çubuğun altına kadar uzanır.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, bottomInset + 14),
        child: GlassTabBar(
          tabs: [
            GlassTab(icon: EsikIcon.door, label: l10n.tabToday),
            GlassTab(icon: EsikIcon.list, label: l10n.tabList),
            GlassTab(icon: EsikIcon.history, label: l10n.tabHistory),
            GlassTab(icon: EsikIcon.sliders, label: l10n.tabSettings),
          ],
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
