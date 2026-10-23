import 'package:flutter/material.dart';

/// Extension utilitaire pour rendre l'interface responsive sur tous les téléphones et tablettes.
extension ResponsiveContext on BuildContext {
  /// Taille globale de l'écran (fenêtre de l'application)
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// Breakpoints pratiques
  bool get isSmallPhone => screenWidth < 360;
  bool get isTablet => screenWidth >= 600;
  bool get isDesktop => screenWidth >= 1024;

  /// Retourne une valeur proportionnelle à la largeur de l'écran avec bornes min/max
  double widthPercent(double percent, {double min = 0, double max = double.infinity}) {
    return (screenWidth * percent).clamp(min, max);
  }

  /// Retourne une valeur proportionnelle à la hauteur de l'écran avec bornes min/max
  double heightPercent(double percent, {double min = 0, double max = double.infinity}) {
    return (screenHeight * percent).clamp(min, max);
  }

  /// Sélectionne une valeur adaptée selon le type d'appareil
  T responsiveValue<T>({
    required T standard,
    T? smallPhone,
    T? compact,
    T? tablet,
    T? large,
  }) {
    if (isTablet && (large ?? tablet) != null) return (large ?? tablet)!;
    final small = smallPhone ?? compact;
    if (isSmallPhone && small != null) return small;
    return standard;
  }

  /// Adapte la taille de police (fontSize) pour éviter que les textes soient tronqués sur petit écran
  double fontSize(double baseSize) {
    if (isSmallPhone) return baseSize * 0.92;
    if (isTablet) return baseSize * 1.15;
    return baseSize;
  }

  /// Bordure symétrique rigoureusement identique en mode clair et sombre (1.0 px)
  /// Élimine à 100% les décalages de taille (2px) lors de l'activation du mode sombre
  Border symmetricBorder({
    bool isSelected = false,
    Color? borderColor,
    Color? lightBorder,
    Color? darkBorder,
    Color? selectedColor,
    double width = 1.0,
    double selectedWidth = 1.5,
  }) {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    if (isSelected) {
      return Border.all(
        color: selectedColor ?? const Color(0xFFF5A623),
        width: selectedWidth,
      );
    }
    return Border.all(
      color: borderColor ??
          (isDark
              ? (darkBorder ?? const Color(0xFF3D342D))
              : (lightBorder ?? const Color(0xFFE2D8CC))),
      width: width,
    );
  }

  /// Couleur de texte avec contraste optimal garanti en clair et en sombre
  Color adaptiveTextColor({Color? lightColor, Color? darkColor}) {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark
        ? (darkColor ?? const Color(0xFFFAF7F2))
        : (lightColor ?? const Color(0xFF1E1B18));
  }

  /// Couleur de texte secondaire (sous-titres, localisations) avec haute lisibilité
  Color adaptiveSubtextColor({Color? lightColor, Color? darkColor}) {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark
        ? (darkColor ?? const Color(0xFFC7BCB3))
        : (lightColor ?? const Color(0xFF6B6560));
  }
}


