import 'package:flutter/material.dart';

/// Web projesinin tasarım token'ları (`DESIGN.md`, `site.css`): grafit zemin,
/// sinyal turuncusu eylem rengi, kayıp/bulundu için ayrı dolgu ve metin tonları.
/// Ekranlar renkleri buradan değil, `context.palette` ya da
/// `Theme.of(context).colorScheme` üzerinden okur.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.paper,
    required this.surface,
    required this.surface2,
    required this.navBg,
    required this.line,
    required this.lineStrong,
    required this.fieldLine,
    required this.ink,
    required this.muted,
    required this.placeholder,
    required this.strongBg,
    required this.strongFg,
    required this.accent,
    required this.accentPress,
    required this.onAccent,
    required this.accentText,
    required this.link,
    required this.lost,
    required this.lostText,
    required this.lostTint,
    required this.found,
    required this.foundText,
    required this.foundTint,
    required this.pending,
    required this.pendingTint,
    required this.pendingDot,
  });

  /// Sayfa zemini.
  final Color paper;

  /// Kart, panel, form kartı.
  final Color surface;

  /// Yükseltilmiş / gömük alan, fotoğraf zemini.
  final Color surface2;

  /// Üst ve alt menü.
  final Color navBg;

  /// Ayırıcı çizgi, kart kenarı.
  final Color line;
  final Color lineStrong;

  /// Form alanı kenarı.
  final Color fieldLine;

  final Color ink;
  final Color muted;
  final Color placeholder;

  /// Seçili durum dolgusu (seçili sekme, segment).
  final Color strongBg;
  final Color strongFg;

  /// Birincil eylem dolgusu ve üzerindeki metin. Turuncu üzerinde beyaz yok.
  final Color accent;
  final Color accentPress;
  final Color onAccent;

  /// Turuncu metin/simge (açık temada daha koyu ton, kontrast için).
  final Color accentText;

  final Color link;

  /// Kayıp: dolgu (üstünde beyaz), metin tonu ve açık zemin.
  final Color lost;
  final Color lostText;
  final Color lostTint;

  /// Bulundu: dolgu (üstünde beyaz), metin tonu ve açık zemin.
  final Color found;
  final Color foundText;
  final Color foundTint;

  /// Onay bekliyor.
  final Color pending;
  final Color pendingTint;
  final Color pendingDot;

  /// Etiket dolgusu üzerindeki metin (kayıp/bulundu).
  Color get onTag => const Color(0xFFFFFFFF);

  static const dark = AppPalette(
    paper: Color(0xFF121212),
    surface: Color(0xFF1C1C1E),
    surface2: Color(0xFF26262A),
    navBg: Color(0xFF18181A),
    line: Color(0xFF2E2E32),
    lineStrong: Color(0xFF46464C),
    fieldLine: Color(0xFF6E6E75),
    ink: Color(0xFFECECEC),
    muted: Color(0xFFA9A9AE),
    placeholder: Color(0xFF8E8E94),
    strongBg: Color(0xFFECECEC),
    strongFg: Color(0xFF121212),
    accent: Color(0xFFFF7A2F),
    accentPress: Color(0xFFE8661C),
    onAccent: Color(0xFF141414),
    accentText: Color(0xFFFF7A2F),
    link: Color(0xFF8CC0FF),
    lost: Color(0xFFC4372F),
    lostText: Color(0xFFFF8F85),
    lostTint: Color(0xFF3A1719),
    found: Color(0xFF1B7A4B),
    foundText: Color(0xFF5FD39A),
    foundTint: Color(0xFF11301F),
    pending: Color(0xFFFFC861),
    pendingTint: Color(0xFF3A2C0E),
    pendingDot: Color(0xFFFFB020),
  );

  static const light = AppPalette(
    paper: Color(0xFFF4F3F1),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEBE9E6),
    navBg: Color(0xFFFFFFFF),
    line: Color(0xFFE2DFDB),
    lineStrong: Color(0xFFCFCAC4),
    fieldLine: Color(0xFF8C8781),
    ink: Color(0xFF1C1A18),
    muted: Color(0xFF5B5752),
    placeholder: Color(0xFF6B665F),
    strongBg: Color(0xFF1C1A18),
    strongFg: Color(0xFFFFFFFF),
    accent: Color(0xFFFF7A2F),
    accentPress: Color(0xFFE8661C),
    onAccent: Color(0xFF141414),
    accentText: Color(0xFFB84A0C),
    link: Color(0xFF0B5CC4),
    lost: Color(0xFFC4372F),
    lostText: Color(0xFFB42318),
    lostTint: Color(0xFFFDECEA),
    found: Color(0xFF1B7A4B),
    foundText: Color(0xFF15703F),
    foundTint: Color(0xFFE3F4EA),
    pending: Color(0xFF7A4A00),
    pendingTint: Color(0xFFFFF2D6),
    pendingDot: Color(0xFFFFB020),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      paper: l(paper, other.paper),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      navBg: l(navBg, other.navBg),
      line: l(line, other.line),
      lineStrong: l(lineStrong, other.lineStrong),
      fieldLine: l(fieldLine, other.fieldLine),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      placeholder: l(placeholder, other.placeholder),
      strongBg: l(strongBg, other.strongBg),
      strongFg: l(strongFg, other.strongFg),
      accent: l(accent, other.accent),
      accentPress: l(accentPress, other.accentPress),
      onAccent: l(onAccent, other.onAccent),
      accentText: l(accentText, other.accentText),
      link: l(link, other.link),
      lost: l(lost, other.lost),
      lostText: l(lostText, other.lostText),
      lostTint: l(lostTint, other.lostTint),
      found: l(found, other.found),
      foundText: l(foundText, other.foundText),
      foundTint: l(foundTint, other.foundTint),
      pending: l(pending, other.pending),
      pendingTint: l(pendingTint, other.pendingTint),
      pendingDot: l(pendingDot, other.pendingDot),
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// Etkin temanın paleti. Uygulama teması verilmemişse (bazı testler)
  /// parlaklığa göre açık ya da koyu palet döner.
  AppPalette get palette {
    final theme = Theme.of(this);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light);
  }
}
