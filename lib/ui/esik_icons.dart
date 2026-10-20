import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Tasarımdaki çizgi ikonlar (24×24, yuvarlak uçlu). Yol verileri kanvastaki
/// artboard'larla birebir aynıdır; yeni ikon eklerken buraya ekleyin.
enum EsikIcon {
  iron(
    'M3 17h15a2 2 0 0 0 2-2v-5H9.5A6.5 6.5 0 0 0 3 16.5V17zM9 10V8a2 2 0 0 1 2-2h7a2 2 0 0 1 2 2v2M7 20h2M12 20h2',
  ),
  checklist(
    'M10 6h10M10 12h10M10 18h10M3.5 6l1.5 1.5L7.5 5M3.5 12l1.5 1.5L7.5 11M3.5 18l1.5 1.5L7.5 17',
  ),
  lock(
    'M7 11h10a1.5 1.5 0 0 1 1.5 1.5v6A1.5 1.5 0 0 1 17 20H7a1.5 1.5 0 0 1-1.5-1.5v-6A1.5 1.5 0 0 1 7 11zM8.5 11V8a3.5 3.5 0 0 1 7 0v3M12 14.5v2.5',
  ),
  bag(
    'M6 9a3 3 0 0 1 3-3h6a3 3 0 0 1 3 3v10a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1zM9 6V5a3 3 0 0 1 6 0v1M9 13h6M9 13v2',
  ),
  plug('M9 3v5M15 3v5M6 8h12v3a6 6 0 0 1-12 0zM12 17v4'),
  notes(
    'M7 3h7l5 5v12a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1zM14 3v5h5M9 13h6M9 17h4',
  ),
  key(
    'M5.5 9.5a4.5 4.5 0 1 0 9 0a4.5 4.5 0 1 0-9 0zM13.2 12.7L20 19.5M17.5 17l1.8-1.8M15.5 15l1.5-1.5',
  ),
  wallet(
    'M4 7a2 2 0 0 1 2-2h11v4M4 7v11a2 2 0 0 0 2 2h13a1 1 0 0 0 1-1V10a1 1 0 0 0-1-1H6a2 2 0 0 1-2-2zM16 14.5h1',
  ),
  flame(
    'M12 3c1 3 5 5 5 10a5 5 0 0 1-10 0c0-2.5 1.5-4 2.5-5 0 2 1 3 2.5 3 0-3-1-5 0-8z',
  ),
  bulb(
    'M9 18h6M10 21h4M12 3a6 6 0 0 0-3.5 10.9c.6.5 1 1.2 1 2V16h5v-.1c0-.8.4-1.5 1-2A6 6 0 0 0 12 3z',
  ),
  pill('M10.5 3.5a5 5 0 0 1 7 7l-7 7a5 5 0 0 1-7-7zM7 10l7 7'),
  moon('M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z'),
  sun(
    'M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8zM12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4',
  ),
  check('M5 12.5l4.5 4.5L19 7.5'),
  clock('M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM12 7v5l3.5 2'),
  alarm('M4 13a8 8 0 1 0 16 0a8 8 0 1 0-16 0zM12 9v4l2.5 2M4 4L2 6M20 4l2 2'),
  bell('M6 16V11a6 6 0 0 1 12 0v5l1.5 2h-15zM10 21h4'),
  list('M10 6h10M10 12h10M10 18h10M4.5 6h.01M4.5 12h.01M4.5 18h.01'),
  history('M12 3a9 9 0 1 0 9 9M12 7v5l3 2M21 3v5h-5'),
  sliders('M4 7h10M18 7h2M4 17h4M12 17h8M16 5v4M10 15v4'),
  chevronRight('M9 6l6 6-6 6'),
  arrowLeft('M19 12H5M11 6l-6 6 6 6'),
  arrowRight('M5 12h14M13 6l6 6-6 6'),
  plus('M12 5v14M5 12h14');

  const EsikIcon(this.path);
  final String path;
}

class EsikIconView extends StatelessWidget {
  const EsikIconView(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 1.6,
  });

  final EsikIcon icon;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final c =
        color ??
        DefaultTextStyle.of(context).style.color ??
        const Color(0xFFFFFFFF);
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
        'stroke="#000000" stroke-width="$strokeWidth" stroke-linecap="round" '
        'stroke-linejoin="round"><path d="${icon.path}"/></svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}
