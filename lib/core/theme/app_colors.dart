import 'package:flutter/material.dart';

/// Palette de couleurs élégante et premium inspirée de l'univers de la coiffure afro & moderne.
class AppColors {
  // Couleurs de marque principales
  static const Color primary = Color(0xFFC88A34); // Or ambré chaleureux
  static const Color primaryLight = Color(0xFFF3D292);
  static const Color primaryDark = Color(0xFF8F580E);

  // Couleurs secondaires & d'accent
  static const Color secondary = Color(0xFF2C2420); // Brun expresso luxueux
  static const Color accent = Color(0xFFE05638); // Terracotta dynamique
  static const Color gold = Color(0xFFFFD166);

  // Fonds et surfaces
  static const Color background = Color(0xFFFBF8F5); // Blanc cassé doux
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4ECE4);

  // Textes & contrastes
  static const Color textPrimary = Color(0xFF1E1B18);
  static const Color textSecondary = Color(0xFF6B6560);
  static const Color textMuted = Color(0xFF9E9790);
  static const Color textLight = Color(0xFFFFFFFF);

  // États & indicateurs
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);

  // Bordures & séparateurs
  static const Color border = Color(0xFFE7DFD5);
  static const Color divider = Color(0xFFF0EAE1);

  // Badge notification / panier
  static const Color badge = Color(0xFFE53935);

  // Couleurs extraites de la maquette Figma
  static const Color figmaBrown = Color(0xFF5C3826); // Fond AppBar, BottomBar & Boutons "Réserver"
  static const Color figmaActiveGold = Color(0xFFF5A623); // Onglet actif, boutons "+ Panier", prix & étoiles
  static const Color figmaIconLight = Color(0xFFE0E4EB); // Icônes de l'AppBar
  static const Color figmaBadgePink = Color(0xFFC2185B); // Badge Panier & badge "STORY"
  static const Color figmaBadgeGold = Color(0xFFD4AF37); // Badge Rendez-vous & bordures or stories
  static const Color figmaBadgeRed = Color(0xFFE53935); // Badge Notification

  // Couleurs de surface et cartes de la page Accueil & Recherche Figma
  static const Color figmaCardBg = Color(0xFFEEE1D6); // Fond beige chaleureux des cartes
  static const Color figmaInputBg = Color(0xFFFAF8F5); // Fond barre de recherche & sélecteur 5km
  static const Color figmaBorder = Color(0xFFE0E4EB); // Bordure discrète
  static const Color figmaMutedText = Color(0xFF717A88); // Textes secondaires
  static const Color figmaRatingBg = Color(0xA6000000); // Fond sombre transparent pour ★ 4.9

  // ==============================================================
  // PALETTE DARK THEME (Élégant, chaud et raffiné)
  // ==============================================================
  static const Color darkBackground = Color(0xFF141211); // Fond principal sombre chaleureux
  static const Color darkSurface = Color(0xFF1E1A17); // Surfaces / cartes sombres
  static const Color darkSurfaceVariant = Color(0xFF2B2521); // Cartes secondaires / surélévations
  static const Color darkCardBg = Color(0xFF26201C); // Fond de carte sombre
  static const Color darkBorder = Color(0xFF3D342D); // Bordures sombres subtiles
  static const Color darkDivider = Color(0xFF332B25); // Séparateurs sombres
  static const Color darkTextPrimary = Color(0xFFF9F6F0); // Texte principal clair
  static const Color darkTextSecondary = Color(0xFFB8ADA4); // Texte secondaire
  static const Color darkTextMuted = Color(0xFF8A7F77); // Texte estompé
  static const Color darkInputBg = Color(0xFF1F1A17); // Fond des champs de saisie sombres
}
