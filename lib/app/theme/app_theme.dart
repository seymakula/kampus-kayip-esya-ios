import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Açık ve koyu tema; web projesinin tasarım diliyle aynı ("büronun bagaj
/// etiketi"): grafit / sıcak nötr zemin, turuncu birincil eylem, çizgiyle
/// ayrılan yüzeyler, gövdede Onest, başlıkta Bricolage Grotesque.
/// Ekranlar renkleri doğrudan değil, `Theme.of(context).colorScheme` ve
/// `context.palette` üzerinden kullanır.
abstract final class AppTheme {
  static final light = _build(Brightness.light, AppPalette.light);
  static final dark = _build(Brightness.dark, AppPalette.dark);

  static const bodyFont = 'Onest';
  static const displayFont = 'Bricolage Grotesque';

  /// Köşeler: buton, form, çip içi 6; kart ve panel 10.
  static const radiusSm = 6.0;
  static const radius = 10.0;

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final colors = ColorScheme(
      brightness: brightness,
      // Turuncu metin/simge tonu; turuncu dolgu düğme temasında ayrıca verilir.
      primary: p.accentText,
      onPrimary: brightness == Brightness.dark ? p.onAccent : p.surface,
      primaryContainer: p.surface2,
      onPrimaryContainer: p.accentText,
      secondary: p.link,
      onSecondary: p.paper,
      secondaryContainer: p.surface2,
      onSecondaryContainer: p.ink,
      tertiary: p.foundText,
      onTertiary: p.paper,
      error: p.lostText,
      onError: p.paper,
      errorContainer: p.lostTint,
      onErrorContainer: p.lostText,
      surface: p.paper,
      onSurface: p.ink,
      onSurfaceVariant: p.muted,
      surfaceContainerLowest: p.paper,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surface2,
      surfaceContainerHighest: p.surface2,
      outline: p.fieldLine,
      outlineVariant: p.line,
      inverseSurface: p.strongBg,
      onInverseSurface: p.strongFg,
      inversePrimary: p.accent,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      surfaceTint: const Color(0x00000000),
    );

    final text = _textTheme(brightness, p);
    final sm = BorderRadius.circular(radiusSm);
    final md = BorderRadius.circular(radius);
    OutlineInputBorder field(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: sm,
      borderSide: BorderSide(color: c, width: w),
    );
    final buttonText = text.labelLarge!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colors,
      extensions: [p],
      fontFamily: bodyFont,
      textTheme: text,
      scaffoldBackgroundColor: p.paper,
      canvasColor: p.paper,
      dividerColor: p.line,
      dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: p.navBg,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: const Color(0x00000000),
        shape: Border(bottom: BorderSide(color: p.line)),
        titleTextStyle: text.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: p.navBg,
        surfaceTintColor: const Color(0x00000000),
        elevation: 0,
        indicatorColor: p.surface2,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? p.accentText : p.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelMedium!.copyWith(
            color: s.contains(WidgetState.selected) ? p.ink : p.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.ink,
        unselectedLabelColor: p.muted,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall,
        dividerColor: p.line,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: p.accent, width: 3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: p.surface,
        surfaceTintColor: const Color(0x00000000),
        shape: RoundedRectangleBorder(
          borderRadius: md,
          side: BorderSide(color: p.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.paper,
        border: field(p.fieldLine),
        enabledBorder: field(p.fieldLine),
        focusedBorder: field(p.link, 2),
        errorBorder: field(p.lost),
        focusedErrorBorder: field(p.lost, 2),
        disabledBorder: field(p.line),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: TextStyle(color: p.muted),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (s) => TextStyle(
            color: s.contains(WidgetState.error)
                ? p.lostText
                : s.contains(WidgetState.focused)
                ? p.link
                : p.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        hintStyle: TextStyle(color: p.placeholder),
        helperStyle: TextStyle(color: p.muted),
        errorStyle: TextStyle(color: p.lostText),
        prefixIconColor: p.muted,
        suffixIconColor: p.muted,
      ),
      // Birincil: sinyal turuncusu, üstünde koyu metin.
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(64, 44)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: sm),
          ),
          textStyle: WidgetStatePropertyAll(buttonText),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? p.accent.withValues(alpha: 0.55)
                : s.contains(WidgetState.pressed)
                ? p.accentPress
                : p.accent,
          ),
          foregroundColor: WidgetStatePropertyAll(p.onAccent),
          iconColor: WidgetStatePropertyAll(p.onAccent),
          overlayColor: WidgetStatePropertyAll(
            p.onAccent.withValues(alpha: 0.08),
          ),
        ),
      ),
      // İkincil: çerçeveli, yüzey dolgulu.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: sm),
          textStyle: buttonText,
          foregroundColor: p.ink,
          backgroundColor: p.surface,
          side: BorderSide(color: p.fieldLine),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.link,
          textStyle: buttonText,
          shape: RoundedRectangleBorder(borderRadius: sm),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: p.ink),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: sm),
          ),
          side: WidgetStatePropertyAll(BorderSide(color: p.line)),
          textStyle: WidgetStatePropertyAll(
            text.labelLarge!.copyWith(fontWeight: FontWeight.w600),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.strongBg : p.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? p.muted
                : s.contains(WidgetState.selected)
                ? p.strongFg
                : p.ink,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.strongFg : p.muted,
          ),
        ),
      ),
      // Kategori çipi: sessiz, çerçeveli, tam yuvarlak; seçili olan dolu.
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.strongBg,
        disabledColor: p.surface2,
        side: BorderSide(color: p.line),
        shape: const StadiumBorder(),
        labelStyle: text.labelMedium!.copyWith(
          color: p.ink,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: text.labelMedium!.copyWith(
          color: p.strongFg,
          fontWeight: FontWeight.w600,
        ),
        checkmarkColor: p.strongFg,
        deleteIconColor: p.muted,
        iconTheme: IconThemeData(color: p.muted, size: 16),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.muted,
        textColor: p.ink,
        titleTextStyle: text.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: text.bodyMedium!.copyWith(color: p.muted),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: const Color(0x00000000),
        shape: RoundedRectangleBorder(
          borderRadius: md,
          side: BorderSide(color: p.line),
        ),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium!.copyWith(color: p.muted),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: const Color(0x00000000),
        modalBackgroundColor: p.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        ),
        dragHandleColor: p.lineStrong,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.strongBg,
        contentTextStyle: text.bodyMedium!.copyWith(color: p.strongFg),
        actionTextColor: p.accentText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: sm),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: p.accent,
        textColor: p.onAccent,
        textStyle: text.labelSmall!.copyWith(fontWeight: FontWeight.w700),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
        linearTrackColor: p.surface2,
        circularTrackColor: const Color(0x00000000),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accent : p.paper,
        ),
        checkColor: WidgetStatePropertyAll(p.onAccent),
        side: BorderSide(color: p.fieldLine),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accent : p.surface2,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onAccent : p.muted,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.link,
        selectionHandleColor: p.link,
        selectionColor: p.link.withValues(alpha: 0.3),
      ),
    );
  }

  /// 1.2 oranlı ölçek (12 / 14 / 16 / 19 / 23 / 28 / 40). Başlıklar Bricolage
  /// Grotesque 700–800 ve sıkı harf aralığı; arayüz yazıları Onest.
  static TextTheme _textTheme(Brightness brightness, AppPalette p) {
    TextStyle display(double size, FontWeight weight, double tracking) =>
        TextStyle(
          fontFamily: displayFont,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: size * tracking,
          height: 1.15,
          color: p.ink,
        );
    TextStyle body(double size, FontWeight weight, {double height = 1.5}) =>
        TextStyle(
          fontFamily: bodyFont,
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: p.ink,
        );

    return TextTheme(
      displayLarge: display(40, FontWeight.w800, -0.045),
      displayMedium: display(34, FontWeight.w800, -0.04),
      displaySmall: display(28, FontWeight.w800, -0.03),
      headlineLarge: display(28, FontWeight.w800, -0.03),
      headlineMedium: display(26, FontWeight.w800, -0.03),
      headlineSmall: display(23, FontWeight.w700, -0.02),
      titleLarge: display(19, FontWeight.w700, -0.01),
      titleMedium: body(16, FontWeight.w600, height: 1.35),
      titleSmall: body(14, FontWeight.w600, height: 1.35),
      bodyLarge: body(16, FontWeight.w400),
      bodyMedium: body(14, FontWeight.w400),
      bodySmall: body(12, FontWeight.w400).copyWith(color: p.muted),
      labelLarge: body(14, FontWeight.w600, height: 1.2),
      labelMedium: body(12, FontWeight.w600, height: 1.2),
      labelSmall: body(11, FontWeight.w600, height: 1.2),
    );
  }
}
