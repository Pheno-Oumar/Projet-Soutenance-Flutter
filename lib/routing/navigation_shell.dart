import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/responsive.dart';
import '../features/compte/presentation/providers/compte_provider.dart';
import '../features/notification/presentation/providers/notification_provider.dart';
import '../features/panier/presentation/providers/panier_provider.dart';
import '../features/rendezvous/presentation/providers/rendezvous_panier_provider.dart';
import '../features/salon/presentation/providers/salon_provider.dart';
import 'route_names.dart';

class NavigationShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  /// Titre dynamique au centre de l'AppBar selon l'onglet actif du BottomNavigationBar
  String _getTitleForCurrentTab(int index) {
    switch (index) {
      case 0:
        return 'Accueil';
      case 1:
        return 'Nos salons'; // Correspond exactement au titre de la maquette Figma
      case 2:
        return "KADY'S";
      case 3:
        return 'Mon compte';
      default:
        return 'HAIR STYLE';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(panierCountProvider);
    final rdvCount = ref.watch(rdvPanierCountProvider);
    final unreadNotifs = ref.watch(unreadNotificationCountProvider);
    final isKadysTab = navigationShell.currentIndex == 2;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isKadysTab
          ? Colors.black
          : (isDark ? AppColors.darkBackground : AppColors.background),
      body: Column(
        children: [
          // ==============================================================
          // 1. APPBAR SUPÉRIEURE (Masquée sur l'onglet Kady's selon la maquette)
          // ==============================================================
          if (!isKadysTab)
            Container(
              color: isDark ? const Color(0xFF1E1A17) : AppColors.figmaBrown,
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.darkBorder : const Color(0xFF222834),
                        width: 0.8,
                      ),
                    ),
                  ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // B. MILIEU : Titre dynamique PARFAITEMENT AU CENTRE DE L'ÉCRAN SANS COLLISION
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 85),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _getTitleForCurrentTab(navigationShell.currentIndex),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.fontSize(18),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Ligne avec Logo à gauche et les Actions à droite
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // A. GAUCHE : Logo circulaire officiel HAIR STYLE
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF8A583E),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.content_cut_rounded,
                                color: AppColors.figmaActiveGold,
                                size: 24,
                              ),
                            ),
                          ),
                        ),

                        // C. DROITE : Les 2 icônes d'action (Panier et Rendez-vous)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Panier (shopping cart selon Figma, badge rose #C2185B)
                            _buildAppBarAction(
                              icon: Icons.shopping_cart_outlined,
                              badgeCount: cartCount,
                              badgeColor: AppColors.figmaBadgePink,
                              onTap: () => context.push(RouteNames.panier),
                            ),
                            const SizedBox(width: 10),

                            // 2. Rendez-vous (panier de prestations / rendez-vous par salon)
                            _buildAppBarAction(
                              icon: Icons.event_note_outlined,
                              badgeColor: AppColors.figmaBadgeGold,
                              badgeCount: rdvCount,
                              onTap: () => context.push(RouteNames.panierRendezVous),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==============================================================
          // 2. CORPS PRINCIPAL DE LA PAGE ACTIVE (persistant via GoRouter)
          // ==============================================================
          Expanded(
            child: navigationShell,
          ),

          // ==============================================================
          // 3. BOTTOM NAVIGATION BAR (Noire sur Kady's, Marron sur les autres)
          // ==============================================================
          Container(
            height: 78 + MediaQuery.paddingOf(context).bottom,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _NavigationNotchPainter(
                selectedIndex: navigationShell.currentIndex,
                backgroundColor: AppColors.figmaBrown,
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 78,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildBottomTab(context, ref: ref, index: 0, label: 'Accueil',
                        iconBuilder: (color) => Icon(Icons.home_rounded, size: 38, color: color)),
                      _buildBottomTab(context, ref: ref, index: 1, label: 'Salon',
                        iconBuilder: (color) => Image.asset(
                          'assets/images/menuiconsalon.png',
                          width: 42,
                          height: 38,
                          fit: BoxFit.contain,
                          color: color,
                          colorBlendMode: BlendMode.srcIn,
                        )),
                      _buildBottomTab(context, ref: ref, index: 2, label: "Kady's",
                        iconBuilder: (color) => SizedBox(
                          width: 38, height: 38,
                          child: Stack(alignment: Alignment.center, children: [
                            Icon(Icons.crop_square_rounded, size: 38, color: color),
                            Icon(Icons.play_arrow_rounded, size: 25, color: color),
                          ]))),
                      _buildBottomTab(context, ref: ref, index: 3, label: 'Profil',
                        iconBuilder: (color) => Icon(Icons.person_outline_rounded, size: 38, color: color),
                        badgeCount: unreadNotifs),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // HELPER : Icône d'action supérieure avec Badge (Container & Stack)
  // ==============================================================
  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onTap,
    Color badgeColor = AppColors.figmaBadgeRed,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.figmaIconLight,
            ),
            if (badgeCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.figmaBrown,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // HELPER : Élément d'onglet BottomNavigationBar (Container & Column)
  // ==============================================================
  Widget _buildBottomTab(
    BuildContext context, {
    required WidgetRef ref,
    required int index,
    required String label,
    required Widget Function(Color color) iconBuilder,
    int badgeCount = 0,
  }) {
    final isSelected = navigationShell.currentIndex == index;
    final itemColor = isSelected ? AppColors.figmaActiveGold : Colors.white;

    return Expanded(
      child: InkWell(
        onTap: () {
          final isCurrent = index == navigationShell.currentIndex;
          navigationShell.goBranch(
            index,
            initialLocation: isCurrent,
          );
          _refreshTab(ref, index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  iconBuilder(itemColor),
                  if (badgeCount > 0)
                    Positioned(
                      top: -2,
                      right: -5,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.figmaBrown,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            badgeCount > 9 ? '9+' : '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: itemColor,
                    fontSize: context.fontSize(12),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshTab(WidgetRef ref, int index) {
    switch (index) {
      case 0:
        ref.invalidate(kadysStoriesGroupsProvider);
        ref.invalidate(servicesTransversauxProvider(null));
        ref.invalidate(realisationsTransversalesProvider);
        ref.invalidate(produitsTransversauxProvider(null));
        ref.read(salonsListProvider.notifier).chargerSalons();
        break;
      case 1:
        ref.read(salonsListProvider.notifier).chargerSalons();
        break;
      case 2:
        break;
      case 3:
        ref.invalidate(clientProfileProvider);
        ref.invalidate(unreadNotificationCountProvider);
        break;
    }
  }
}

class _NavigationNotchPainter extends CustomPainter {
  final int selectedIndex;
  final Color backgroundColor;

  const _NavigationNotchPainter({
    required this.selectedIndex,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = backgroundColor,
    );

    final centerX = size.width * (selectedIndex + 0.5) / 4;
    final halfWidth = (size.width / 6.7).clamp(54.0, 83.0).toDouble();
    final bottomHalfWidth = halfWidth * 0.42;
    final depth = size.height;
    final notch = Path()
      ..moveTo(centerX - halfWidth, 0)
      ..cubicTo(
        centerX - halfWidth * 0.62,
        0,
        centerX - halfWidth * 0.70,
        depth * 0.58,
        centerX - bottomHalfWidth,
        depth * 0.84,
      )
      ..quadraticBezierTo(centerX, depth * 1.12, centerX + bottomHalfWidth, depth * 0.84)
      ..cubicTo(
        centerX + halfWidth * 0.70,
        depth * 0.58,
        centerX + halfWidth * 0.62,
        0,
        centerX + halfWidth,
        0,
      )
      ..close();

    canvas.drawPath(notch, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _NavigationNotchPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.backgroundColor != backgroundColor;
}
