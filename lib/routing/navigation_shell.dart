import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../features/notification/presentation/providers/notification_provider.dart';
import '../features/panier/presentation/providers/panier_provider.dart';
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
                    // B. MILIEU : Titre dynamique PARFAITEMENT AU CENTRE DE L'ÉCRAN
                    Center(
                      child: Text(
                        _getTitleForCurrentTab(navigationShell.currentIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
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

                            // 2. Rendez-vous (agenda / event note selon Figma, badge doré #D4AF37)
                            _buildAppBarAction(
                              icon: Icons.event_note_outlined,
                              badgeColor: AppColors.figmaBadgeGold,
                              badgeCount: 1, // Indicateur d'action active
                              onTap: () => context.push(RouteNames.mesRendezVous),
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
            decoration: BoxDecoration(
              color: isKadysTab
                  ? Colors.black
                  : (isDark ? const Color(0xFF1E1A17) : AppColors.figmaBrown),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: (isKadysTab || isDark)
                  ? Border(
                      top: BorderSide(
                        color: isDark ? AppColors.darkBorder : const Color(0xFF1E1E1E),
                        width: 0.8,
                      ),
                    )
                  : null,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Container(
                height: 78,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildBottomTab(
                      index: 0,
                      label: 'Accueil',
                      icon: Icons.home_rounded,
                      isDark: isDark,
                    ),
                    _buildBottomTab(
                      index: 1,
                      label: 'Salon',
                      icon: Icons.storefront_rounded,
                      isDark: isDark,
                    ),
                    _buildBottomTab(
                      index: 2,
                      label: "Kady's",
                      icon: Icons.play_circle_fill_rounded,
                      isDark: isDark,
                    ),
                    _buildBottomTab(
                      index: 3,
                      label: 'Compte',
                      icon: Icons.person_rounded,
                      badgeCount: unreadNotifs,
                      isDark: isDark,
                    ),
                  ],
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
  Widget _buildBottomTab({
    required int index,
    required String label,
    required IconData icon,
    int badgeCount = 0,
    bool isDark = false,
  }) {
    final isSelected = navigationShell.currentIndex == index;
    final itemColor = isSelected
        ? AppColors.figmaActiveGold
        : (isDark ? AppColors.darkTextSecondary : Colors.white);
    final isKadysTab = navigationShell.currentIndex == 2;

    return Expanded(
      child: InkWell(
        onTap: () {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
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
                  Icon(
                    icon,
                    size: 29, // Agrandissement selon maquette Figma (était 24)
                    color: itemColor,
                  ),
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
                            color: isKadysTab
                                ? Colors.black
                                : (isDark ? const Color(0xFF1E1A17) : AppColors.figmaBrown),
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
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
