import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'providers/salon_provider.dart';
import 'widgets/salon_apropos_tab.dart';
import 'widgets/salon_coiffeurs_tab.dart';
import 'widgets/salon_header_widget.dart';
import 'widgets/salon_produits_tab.dart';
import 'widgets/salon_realisations_tab.dart';
import 'widgets/salon_services_tab.dart';

/// Écran principal des détails d'un salon.
/// Architecture modulaire : chaque onglet / section est isolé dans son propre composant.
class SalonDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  final int initialTabIndex;

  const SalonDetailScreen({
    super.key,
    required this.slug,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends ConsumerState<SalonDetailScreen> {
  // Onglet actif : 0 = A propos, 1 = Services, 2 = Réalisations, 3 = Produits, 4 = Coiffeurs
  late int _activeTabIndex;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
  }

  final List<String> _tabs = const [
    'A propos',
    'Services',
    'Realisations',
    'Produits',
    'Coiffeurs',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Récupération des données dynamiques du salon depuis l'API/Provider
    final salonAsync = ref.watch(salonDetailProvider(widget.slug));
    final salon = salonAsync.valueOrNull;

    final salonName = salon?.nom ?? 'Beauty By Dika';
    final locationText = salon?.adresse ?? 'Bamako, Kalaban';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================================================
            // 1. EN-TÊTE DU SALON (Cover, Logo, Note, Épingle 📍, Horaires)
            // ==============================================================
            SalonHeaderWidget(
              salonName: salonName,
              location: locationText,
              isFavorite: _isFavorite,
              onFavoriteToggle: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
              onBackPressed: () => context.pop(),
            ),

            const SizedBox(height: 14),

            // ==============================================================
            // 2. BARRE D'ONGLETS HORIZONTALE (5 onglets demandés)
            // ==============================================================
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isActive = _activeTabIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _activeTabIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                              : (isDark ? AppColors.darkSurface : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                                : (isDark ? AppColors.darkBorder : const Color(0xFFE0E4EB)),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : (isDark ? AppColors.darkTextPrimary : Colors.black87),
                            fontSize: 13,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // ==============================================================
            // 3. CONTENU DYNAMIQUE DE LA SECTION / DE L'ONGLET SÉLECTIONNÉ
            // ==============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTabContent(salonName),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Retourne le widget correspondant à l'onglet sélectionné
  Widget _buildTabContent(String salonName) {
    switch (_activeTabIndex) {
      case 0:
        return const SalonAproposTab();
      case 1:
        return const SalonServicesTab();
      case 2:
        return SalonRealisationsTab(salonName: salonName);
      case 3:
        return const SalonProduitsTab();
      case 4:
        return const SalonCoiffeursTab();
      default:
        return const SizedBox.shrink();
    }
  }
}
