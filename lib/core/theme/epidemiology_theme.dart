import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EpidemiologyTheme {
  // ── Primary palette (héritée de DossierAPP, adaptée au module antirabique) ──
  static const Color red950 = Color(0xFF08293F);
  static const Color redDeep = Color(0xFF0A3D68);
  static const Color redPrimary = Color(0xFF1A568C);
  static const Color redMedium = Color(0xFF2369A5);
  static const Color red400 = Color(0xFF3B82C4);
  static const Color redLight = Color(0xFFD9EAF7);
  static const Color red50 = Color(0xFFF3F8FC);
  static const Color redSurface = Color(0xFFF7FBFE);
  static const Color burgundy = Color(0xFF0F4E78);
  static const Color rosewood = Color(0xFF0A4D68);

  // ── Neutres chauds (médicaux, premium) ─────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFF8FAFC);
  static const Color warm50 = Color(0xFFF8FAFC);
  static const Color warm100 = Color(0xFFF1F5F9);
  static const Color warm150 = Color(0xFFE2E8F0);
  static const Color warm200 = Color(0xFFCBD5E1);
  static const Color warm300 = Color(0xFF94A3B8);
  static const Color warm400 = Color(0xFF64748B);
  static const Color warm500 = Color(0xFF475569);
  static const Color warm600 = Color(0xFF334155);
  static const Color warm700 = Color(0xFF1E293B);
  static const Color warm800 = Color(0xFF0F172A);
  static const Color warm900 = Color(0xFF020617);

  // ── Rétrocompatibilité (alias des couleurs renommées) ──────────────
  static const Color slate50 = warm50;
  static const Color slate100 = warm100;
  static const Color slate150 = warm150;
  static const Color slate200 = warm200;
  static const Color slate300 = warm300;
  static const Color slate400 = warm400;
  static const Color slate500 = warm500;
  static const Color slate600 = warm600;
  static const Color slate700 = warm700;
  static const Color slate800 = warm800;
  static const Color slate900 = warm900;
  static const Color green = success;
  static const Color greenLight = successLight;
  static const Color blue = indigo;
  static const Color blueLight = indigoLight;

  // ── Ombres (rétrocompatibilité) ────────────────────────────────────
  static List<BoxShadow> get shadowHero => [
    BoxShadow(color: redDeep.withValues(alpha: 0.30), blurRadius: 28, offset: const Offset(0, 10)),
    BoxShadow(color: redDeep.withValues(alpha: 0.15), blurRadius: 14, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> cardShadow({double blur = 14, double offsetY = 6, Color color = redDeep, double alpha = 0.10}) => [
    BoxShadow(color: color.withValues(alpha: alpha), blurRadius: blur, offset: Offset(0, offsetY)),
  ];

  // ── États sémantiques raffinés ─────────────────────────────────────
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFE6F5EF);
  static const Color successDark = Color(0xFF15803D);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3E2);
  static const Color warningDark = Color(0xFFB45309);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFFDECEC);
  static const Color dangerDark = Color(0xFFB91C1C);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFEFF6FF);
  static const Color infoDark = Color(0xFF1D4ED8);

  // ── Accents ────────────────────────────────────────────────────────
  static const Color teal = Color(0xFF059669);
  static const Color tealLight = Color(0xFFE6F5EF);
  static const Color emerald = Color(0xFF059669);
  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFFF8ED);
  static const Color orange = Color(0xFFEA580C);
  static const Color orangeLight = Color(0xFFFFF7ED);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color indigoLight = Color(0xFFEEF2FF);

  // ── Icon sizes (rétrocompatibilité) ────────────────────────────────
  static const double iconSm = 14;
  static const double iconMd = 18;
  static const double iconLg = 24;
  static const double iconXl = 28;

  // ── Dégradés (rétrocompatibilité) ─────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0A4D68), Color(0xFF1A568C), Color(0xFF2369A5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );
  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFF3F8FC), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFF7FBFE), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient alertGradient = LinearGradient(
    colors: [Color(0xFFFFEBEE), Color(0xFFFFF3E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color carmine = Color(0xFF0F4E78);
  static const Color redGradientStart = Color(0xFF0A4D68);
  static const Color redGradientEnd = Color(0xFF1A568C);

  // ── Design tokens ──────────────────────────────────────────────────
  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 22;
  static const double radiusXxl = 28;

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double spaceXxl = 24;
  static const double spaceXxxl = 32;
  static const double spaceHuge = 40;

  // ── Ombres premium multicouches ────────────────────────────────────
  static Color blackWith(double alpha) => const Color(0xFF000000).withValues(alpha: alpha);
  static Color warmShadow(double alpha) => const Color(0xFF3D291A).withValues(alpha: alpha);

  static List<BoxShadow> get shadowSm => [
    BoxShadow(color: blackWith(0.04), blurRadius: 6, offset: const Offset(0, 1)),
    BoxShadow(color: warmShadow(0.02), blurRadius: 3, offset: const Offset(0, 0)),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(color: blackWith(0.06), blurRadius: 10, offset: const Offset(0, 2)),
    BoxShadow(color: warmShadow(0.03), blurRadius: 5, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(color: blackWith(0.08), blurRadius: 20, offset: const Offset(0, 4)),
    BoxShadow(color: warmShadow(0.04), blurRadius: 10, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get shadowXl => [
    BoxShadow(color: blackWith(0.10), blurRadius: 30, offset: const Offset(0, 6)),
    BoxShadow(color: warmShadow(0.05), blurRadius: 15, offset: const Offset(0, 3)),
  ];

  static List<BoxShadow> heroShadow(Color accent) => [
    BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 10)),
    BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4)),
    BoxShadow(color: warmShadow(0.06), blurRadius: 8, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> shadowCard(Color accent) => [
    BoxShadow(color: blackWith(0.06), blurRadius: 14, offset: const Offset(0, 3)),
    BoxShadow(color: accent.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 6)),
    BoxShadow(color: warmShadow(0.02), blurRadius: 4, offset: const Offset(0, 1)),
  ];

  // ── Dégradés premium (subtils, dimensionnels, institutionnels) ────
  static LinearGradient dualGradient(Color c1, Color c2) => LinearGradient(
    colors: [c1, c2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [redDeep, redPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get primaryGradientWarm => const LinearGradient(
    colors: [Color(0xFF0A4D68), Color(0xFF1A568C), Color(0xFF2369A5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static LinearGradient get surfaceGradient => const LinearGradient(
    colors: [Color(0xFFFDFBFB), Color(0xFFFFF8F7), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient subtleOverlay(Color c) => LinearGradient(
    colors: [c.withValues(alpha: 0.06), Colors.transparent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get warmGlow => LinearGradient(
    colors: [const Color(0xFFFDF5F0).withValues(alpha: 0.5), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Typographie premium ────────────────────────────────────────────
  static TextStyle display({Color? color}) => GoogleFonts.cairo(
    fontSize: 34, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.5,
    color: color ?? warm900,
  );

  static TextStyle h1({Color? color}) => GoogleFonts.cairo(
    fontSize: 26, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.3,
    color: color ?? warm900,
  );

  static TextStyle h2({Color? color}) => GoogleFonts.cairo(
    fontSize: 20, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.2,
    color: color ?? warm900,
  );

  static TextStyle h3({Color? color}) => GoogleFonts.cairo(
    fontSize: 17, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.1,
    color: color ?? warm900,
  );

  static TextStyle subtitle({Color? color}) => GoogleFonts.cairo(
    fontSize: 14, fontWeight: FontWeight.w600, height: 1.3,
    color: color ?? warm700,
  );

  static TextStyle body({Color? color}) => GoogleFonts.cairo(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.55,
    color: color ?? warm700,
  );

  static TextStyle bodySm({Color? color}) => GoogleFonts.cairo(
    fontSize: 13, fontWeight: FontWeight.w500, height: 1.45,
    color: color ?? warm500,
  );

  static TextStyle caption({Color? color}) => GoogleFonts.cairo(
    fontSize: 11, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.02,
    color: color ?? warm400,
  );

  static TextStyle overline({Color? color}) => GoogleFonts.cairo(
    fontSize: 10, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: 0.06,
    color: color ?? warm400,
  );

  static TextStyle metric({Color? color}) => GoogleFonts.cairo(
    fontSize: 28, fontWeight: FontWeight.w800, height: 1.0, letterSpacing: -0.5,
    color: color ?? warm900,
  );

  static TextStyle label({Color? color}) => GoogleFonts.cairo(
    fontSize: 12, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.01,
    color: color ?? warm600,
  );

  // ── Section header ────────────────────────────────────────────────
  static Widget sectionHeader(String title, {IconData? icon, Widget? trailing, Color? iconColor, EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          if (icon case final iconValue?) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: (iconColor ?? redPrimary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(radiusSm),
              ),
              child: Icon(iconValue, size: 16, color: iconColor ?? redPrimary),
            ),
            const SizedBox(width: spaceMd),
          ],
          Expanded(child: Text(title, style: h3(color: warm900))),
          if (trailing case final Widget trailingWidget) trailingWidget,
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────
  static Widget emptyState(IconData icon, String message, {String? subtitle, Widget? action}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: spaceXxl, vertical: spaceHuge * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: warm100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: warm300),
            ),
            const SizedBox(height: spaceXl),
            Text(message, style: h3(color: warm500), textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: spaceSm),
              Text(subtitle, style: bodySm(color: warm400), textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: spaceXxl),
              action,
            ],
          ],
        ),
      ),
    );
  }

  // ── Loading shimmer ───────────────────────────────────────────────
  static Widget shimmerBox({double height = 20, double width = double.infinity, double radius = radiusMd}) {
    return Container(
      height: height, width: width,
      decoration: BoxDecoration(
        color: warm100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Progress indicator ────────────────────────────────────────────
  static Widget doseProgress({required int current, required int total, double height = 8}) {
    final ratio = total > 0 ? current / total : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              flex: (ratio * 100).round().clamp(0, 100),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF059669), const Color(0xFF16A34A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 100 - (ratio * 100).round().clamp(0, 100),
              child: Container(color: warm150),
            ),
          ],
        ),
      ),
    );
  }

  // ── Badge / Chip builder ─────────────────────────────────────────
  static Widget infoChip(IconData icon, String label, Color color, {double? iconSize, Color? bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: spaceSm, vertical: spaceXs),
      decoration: BoxDecoration(
        color: bgColor ?? color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.12), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize ?? iconSm, color: color),
          const SizedBox(width: spaceXs),
          Text(label, style: caption(color: color)),
        ],
      ),
    );
  }

  // ── Statut badge ──────────────────────────────────────────────────
  static Widget statutBadge(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  // ── Premium card wrapper ──────────────────────────────────────────
  static BoxDecoration premiumCard({Color bg = white, double radius = radiusXl, List<BoxShadow>? shadow, Border? border}) {
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow ?? shadowLg,
      border: border,
    );
  }

  // ── Theme data ────────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: warm50,
      fontFamily: 'Cairo',
      textTheme: GoogleFonts.cairoTextTheme(),
      colorScheme: ColorScheme.light(
        primary: redPrimary,
        secondary: burgundy,
        surface: white,
        surfaceContainerHighest: warm100,
        onPrimary: white,
        onSurface: warm900,
        error: danger,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: redPrimary,
        selectionColor: redPrimary.withValues(alpha: 0.18),
        selectionHandleColor: redPrimary,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: white,
        foregroundColor: warm900,
        titleTextStyle: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700, color: warm900, letterSpacing: -0.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
          textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
          textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: warm200),
          foregroundColor: warm700,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
          textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: warm200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: warm150),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: redPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        labelStyle: GoogleFonts.cairo(fontSize: 14, color: warm500),
        hintStyle: GoogleFonts.cairo(fontSize: 14, color: warm300),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: redPrimary,
        foregroundColor: white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      dividerTheme: const DividerThemeData(color: warm150, thickness: 1),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: warm200),
          ),
        ),
      ),
    );
  }
}
