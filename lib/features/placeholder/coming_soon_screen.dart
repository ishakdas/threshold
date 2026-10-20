import 'package:flutter/material.dart';

import '../../theme/esik_palette.dart';
import '../../ui/atmosphere.dart';

/// Henüz yapılmamış ekranlar için geçici yer tutucu.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    this.showBack = false,
  });

  final String title;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Atmosphere(
        glowTop: -440,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBack) BackButton(color: p.text),
                Text(title, style: t.titleMedium),
                const Spacer(),
                Center(
                  child: Text(
                    'Bu ekran sonraki aşamada geliyor.',
                    style: t.bodyMedium?.copyWith(color: p.textMuted),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
