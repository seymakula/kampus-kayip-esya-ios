import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../data/models/models.dart';

/// Web'in imza biçimi: kayıp eşya bürosunun delikli askı etiketi. Sol ucu
/// sivri, ucun yakınında bir delik; sağ köşeler hafif yuvarlak.
class _TagPainter extends CustomPainter {
  const _TagPainter({
    required this.fill,
    required this.hole,
    required this.notch,
    required this.holeX,
    required this.holeRadius,
    this.cornerRadius = 3,
  });

  final Color fill;
  final Color hole;

  /// Sivri ucun genişliği.
  final double notch;
  final double holeX;
  final double holeRadius;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, r = cornerRadius;
    final path = Path()
      ..moveTo(notch, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(notch, h)
      ..lineTo(0, h / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawCircle(Offset(holeX, h / 2), holeRadius, Paint()..color = hole);
  }

  @override
  bool shouldRepaint(_TagPainter old) =>
      old.fill != fill ||
      old.hole != hole ||
      old.notch != notch ||
      old.holeX != holeX ||
      old.holeRadius != holeRadius;
}

/// Etiket rozeti (web `.tag`): büyük harf, kalın, sıkı yazı.
class TagBadge extends StatelessWidget {
  const TagBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.hole,
    this.large = false,
  });

  final String label;
  final Color background;
  final Color foreground;

  /// Deliğin rengi: rozetin üstünde durduğu zemin. Verilmezse kart yüzeyi.
  final Color? hole;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final fontSize = large ? 14.0 : 12.0;
    final em = fontSize;
    return CustomPaint(
      painter: _TagPainter(
        fill: background,
        hole: hole ?? context.palette.surface,
        notch: 0.6 * em,
        holeX: 0.68 * em,
        holeRadius: 0.18 * em,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(1.15 * em, 0.3 * em, 0.65 * em, 0.3 * em),
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: foreground,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.04 * fontSize,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

/// "KAYIP" / "BULUNDU" rozeti: kırmızı / yeşil dolgu, beyaz yazı.
class ItemTypeBadge extends StatelessWidget {
  const ItemTypeBadge({
    super.key,
    required this.type,
    this.hole,
    this.large = false,
  });

  final ItemType type;
  final Color? hole;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TagBadge(
      label: type.tagLabel,
      background: type == ItemType.lost ? p.lost : p.found,
      foreground: p.onTag,
      hole: hole,
      large: large,
    );
  }
}

/// Logo işareti: turuncu, delikli küçük etiket (web `.brand-mark`, favicon).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 22, this.hole});

  /// Genişlik; yükseklik oranla belirlenir.
  final double size;

  /// Deliğin rengi: işaretin durduğu zemin. Verilmezse menü zemini.
  final Color? hole;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // favicon.svg: 24×14 etiket, uç 7, delik r=2.2 (merkez 7.5).
    final s = size / 24;
    return SizedBox(
      width: size,
      height: 14 * s,
      child: CustomPaint(
        painter: _TagPainter(
          fill: p.accent,
          hole: hole ?? p.navBg,
          notch: 7 * s,
          holeX: 7.5 * s,
          holeRadius: 2.2 * s,
          cornerRadius: 2 * s,
        ),
      ),
    );
  }
}

/// Fotoğrafsız ilanın yer tutucusu: türüne göre yeşil/kırmızı, hafif eğik
/// asılı etiket ve üstünde kategori simgesi (web `.placeholder-tag`).
class PlaceholderTag extends StatelessWidget {
  const PlaceholderTag({
    super.key,
    required this.type,
    required this.icon,
    this.width = 120,
  });

  final ItemType type;
  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final h = width * 0.58;
    return Transform.rotate(
      angle: -7 * math.pi / 180,
      alignment: Alignment(-1 + 2 * 0.14, 0),
      child: SizedBox(
        width: width,
        height: h,
        child: CustomPaint(
          painter: _TagPainter(
            fill: type == ItemType.lost ? p.lost : p.found,
            hole: typeTint(p, type),
            notch: width * 0.18,
            holeX: width * 0.1 + width * 0.0375,
            holeRadius: width * 0.0375,
            cornerRadius: 8,
          ),
          child: Padding(
            padding: EdgeInsets.only(left: width * 0.16),
            child: Center(
              child: Icon(icon, color: p.onTag, size: width * 0.3),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fotoğrafsız ilan zemininin tonu: açık temada türün açık tonu, koyu temada
/// gömük yüzey (web `.is-found` / `.is-lost`).
Color typeTint(AppPalette p, ItemType type) {
  if (p.paper.computeLuminance() > 0.5) {
    return type == ItemType.lost ? p.lostTint : p.foundTint;
  }
  return p.surface2;
}

/// Durum: nokta + metin, renk tek başına anlam taşımaz (web `.status`).
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final ItemStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg, dot) = switch (status) {
      ItemStatus.pending => (p.pendingTint, p.pending, p.pendingDot),
      ItemStatus.published => (p.foundTint, p.foundText, p.foundText),
      ItemStatus.rejected => (p.lostTint, p.lostText, p.lostText),
      ItemStatus.resolved ||
      ItemStatus.archived => (p.surface2, p.muted, p.muted),
    };
    return DecoratedBox(
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: 6),
            ),
            const SizedBox(width: 6),
            Text(
              status.label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kategori çipi: sessiz, çerçeveli, tam yuvarlak (web `.chip`).
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: p.surface,
        shape: StadiumBorder(side: BorderSide(color: p.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: p.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Web'de kategoriye verilen Bootstrap Icons adının Material karşılığı.
IconData categoryIcon(String? bootstrapIcon) => switch (bootstrapIcon) {
  'bi-phone' => Icons.smartphone_outlined,
  'bi-person-vcard' => Icons.badge_outlined,
  'bi-wallet2' => Icons.account_balance_wallet_outlined,
  'bi-key' => Icons.key_outlined,
  'bi-bag' => Icons.checkroom_outlined,
  'bi-backpack' => Icons.backpack_outlined,
  'bi-book' => Icons.menu_book_outlined,
  'bi-pencil' => Icons.edit_outlined,
  'bi-eyeglasses' => Icons.visibility_outlined,
  'bi-cup-straw' => Icons.local_drink_outlined,
  'bi-umbrella' => Icons.beach_access_outlined,
  'bi-three-dots' => Icons.more_horiz,
  _ => Icons.sell_outlined,
};
