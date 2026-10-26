import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/day_mode.dart';
import '../theme/esik_palette.dart';
import 'esik_icons.dart';
import '../l10n/texts.dart';

/// Düz, okunaklı içerik kartı. Cam efekti kullanmaz.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.radius = 28,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 18),
    this.onTap,
    this.highlighted = false,
    this.tint,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  /// Seçili/aktif durum: amber tonlu zemin ve kenar.
  final bool highlighted;

  /// Vurgu rengi; verilmezse amber. Uyarılarda [EsikPalette.warning].
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = tint ?? p.accent;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(
        color: highlighted ? accent.withValues(alpha: 0.55) : p.surfaceBorder,
      ),
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      decoration: ShapeDecoration(
        shape: shape,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: highlighted
              ? [accent.withValues(alpha: 0.26), accent.withValues(alpha: 0.10)]
              : [p.surfaceTop, p.surfaceBottom],
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Beyaz (akşam) / koyu kahve (sabah) hap buton.
class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    required this.onPressed,
    this.height = 54,
    this.expand = false,
    this.warning = false,
  });

  final String label;
  final EsikIcon? icon;
  final EsikIcon? trailingIcon;
  final VoidCallback? onPressed;
  final double height;
  final bool expand;

  /// Eksik bir şeyi tamamlatan buton: uyarı renginde, beyaz yazı.
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    // Beyaz yazı okunsun diye uyarı renginin koyu ucu.
    final background = warning ? p.warningGradient.last : p.primaryButton;
    final foreground = warning ? Colors.white : p.onPrimaryButton;
    final button = FilledButton(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        shape: const StadiumBorder(),
        textStyle: t.labelLarge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            EsikIconView(icon!, size: 16, color: foreground, strokeWidth: 2.4),
            const SizedBox(width: 8),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            EsikIconView(
              trailingIcon!,
              size: 16,
              color: foreground,
              strokeWidth: 2,
            ),
          ],
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Saydam, ince kenarlı ikincil hap buton.
class SecondaryPillButton extends StatelessWidget {
  const SecondaryPillButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.height = 54,
  });

  final String label;
  final EsikIcon? icon;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        backgroundColor: p.chip.withValues(alpha: 0.35),
        side: BorderSide(color: p.chipBorder),
        minimumSize: Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: const StadiumBorder(),
        textStyle: Theme.of(context).textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.w400),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            EsikIconView(icon!, size: 16, color: p.text, strokeWidth: 1.8),
            const SizedBox(width: 8),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

/// Küçük bilgi etiketi ("Yatmadan önce", "Adım 2 / 5").
class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.label, this.icon, this.iconColor});

  final String label;
  final EsikIcon? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: p.chip,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: p.chipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            EsikIconView(
              icon!,
              size: 13,
              color: iconColor ?? p.text,
              strokeWidth: 2,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Amber noktalı küçük başlık ("• Bu akşamki eşiğin").
class DotLabel extends StatelessWidget {
  const DotLabel(this.text, {super.key, this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: center ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        // Uzun çevirilerde taşmasın.
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: p.textMuted),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

/// Geri oku, başlık ve sağda isteğe bağlı bir öğe.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              tooltip: l10n.back,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: EsikIconView(EsikIcon.arrowLeft, color: p.text),
            ),
            const SizedBox(width: 2),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Akşam / Sabah arasında geçiş yapan iki hap.
class ModeSegment extends StatelessWidget {
  const ModeSegment({
    super.key,
    required this.value,
    required this.onChanged,
    this.counts,
  });

  final DayMode value;
  final ValueChanged<DayMode> onChanged;
  final Map<DayMode, int>? counts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;

    Widget pill(DayMode mode) {
      final selected = mode == value;
      final label = mode == DayMode.evening ? l10n.evening : l10n.morning;
      final count = counts?[mode];
      return Semantics(
        selected: selected,
        button: true,
        child: GestureDetector(
          onTap: () {
            if (!selected) HapticFeedback.selectionClick();
            onChanged(mode);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: selected ? p.primaryButton : p.chip.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? p.primaryButton : p.chipBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                EsikIconView(
                  mode == DayMode.evening ? EsikIcon.moon : EsikIcon.sun,
                  size: 14,
                  strokeWidth: 2,
                  color: selected ? p.onPrimaryButton : p.text,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    count == null ? label : '$label · $count',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: t.labelMedium?.copyWith(
                      color: selected ? p.onPrimaryButton : p.text,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Flexible(child: pill(DayMode.evening)),
        const SizedBox(width: 8),
        Flexible(child: pill(DayMode.morning)),
      ],
    );
  }
}

/// Yan yana seçenek hapları: biri seçili. ModeSegment ile aynı görünüm.
class ChoicePills<T> extends StatelessWidget {
  const ChoicePills({
    super.key,
    required this.values,
    required this.value,
    required this.label,
    this.icon,
    required this.onChanged,
    this.expand = true,
  });

  /// true: haplar satırı eşit bölüşür. false: her hap metni kadar, sığmazsa
  /// alt satıra geçer (uzun adlar, ör. dil seçimi).
  final bool expand;

  final List<T> values;
  final T value;
  final String Function(T) label;
  final EsikIcon Function(T)? icon;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;

    Widget pill(T v) {
      final selected = v == value;
      return Semantics(
        selected: selected,
        button: true,
        label: label(v),
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () {
            if (!selected) HapticFeedback.selectionClick();
            onChanged(v);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 38,
            padding: EdgeInsets.symmetric(horizontal: expand ? 10 : 16),
            decoration: BoxDecoration(
              color: selected ? p.primaryButton : p.chip.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: selected ? p.primaryButton : p.chipBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon case final icon?) ...[
                  EsikIconView(
                    icon(v),
                    size: 14,
                    strokeWidth: 2,
                    color: selected ? p.onPrimaryButton : p.text,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label(v),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: t.labelMedium?.copyWith(
                      color: selected ? p.onPrimaryButton : p.text,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!expand) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final v in values)
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 72),
                child: pill(v),
              ),
            ),
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: pill(values[i])),
        ],
      ],
    );
  }
}

/// Amber geçişli anahtar.
class EsikSwitch extends StatelessWidget {
  const EsikSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 34,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: value ? null : p.chip,
            gradient: value
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: p.accentGradient,
                  )
                : null,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Yuvarlak ikon kabı.
class IconCircle extends StatelessWidget {
  const IconCircle({
    super.key,
    required this.icon,
    this.size = 46,
    this.active = false,
    this.iconColor,
    this.strokeWidth = 1.5,
    this.gradient,
  });

  final EsikIcon icon;
  final double size;
  final bool active;

  /// Aktifken zemin; verilmezse amber.
  final List<Color>? gradient;
  final Color? iconColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? null : p.chip.withValues(alpha: 0.5),
        gradient: active
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradient ?? p.accentGradient,
              )
            : null,
      ),
      child: Center(
        child: EsikIconView(
          icon,
          size: size * 0.48,
          strokeWidth: strokeWidth,
          color: iconColor ?? (active ? Colors.white : p.text),
        ),
      ),
    );
  }
}

/// Eşik Plus özelliklerini gösteren rozet. Plus yokken dolu ve altın tonlu
/// (kilitli olduğu belli olsun), Plus varken ince çerçeveli ve sakin.
class PlusBadge extends StatelessWidget {
  const PlusBadge({super.key, required this.owned, this.compact = false});

  /// Plus açık mı (satın alındı ya da deneme sürüyor).
  final bool owned;

  /// Yalnızca ikon (dar yerler için).
  final bool compact;

  static const gold = [Color(0xFFFFD27A), Color(0xFFF0A23A)];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = owned ? p.accent : const Color(0xFF3A2306);
    return Semantics(
      label: 'Plus',
      excludeSemantics: true,
      child: Container(
        height: 20,
        padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: owned ? null : const LinearGradient(colors: gold),
          border: owned
              ? Border.all(color: p.accent.withValues(alpha: 0.6))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EsikIconView(
              EsikIcon.sparkle,
              size: 12,
              color: fg,
              strokeWidth: 1.8,
            ),
            if (!compact) ...[
              const SizedBox(width: 3),
              Text(
                'Plus',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
