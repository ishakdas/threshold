import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Eşik logosu: bir kapı kemeri ve içinden sızan amber ışık.
/// Android uyarlanabilir ikonu (res/drawable/ic_launcher_foreground.xml)
/// aynı yolları kullanır.
class EsikLogo extends StatelessWidget {
  const EsikLogo({
    super.key,
    this.size = 22,
    required this.archColor,
    this.lightColor = const Color(0xFFFFB25C),
  });

  final double size;
  final Color archColor;
  final Color lightColor;

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  Widget build(BuildContext context) {
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">'
        '<path d="M5 22V10a7 7 0 0 1 14 0v12" stroke="${_hex(archColor)}" '
        'stroke-width="1.6" stroke-linecap="round"/>'
        '<path d="M9.5 22v-8a2.5 2.5 0 0 1 5 0v8z" fill="${_hex(lightColor)}"/>'
        '</svg>';
    return Semantics(
      label: 'Eşik',
      image: true,
      child: SvgPicture.string(svg, width: size, height: size),
    );
  }
}
