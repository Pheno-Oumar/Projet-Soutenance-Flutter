import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'details/prestation_detail_screen.dart';
import 'providers/prestation_provider.dart';
import 'widgets/prestation_card_widget.dart';
import 'widgets/prestation_salon_selector.dart';

class MesPrestationsScreen extends ConsumerWidget {
  const MesPrestationsScreen({super.key});

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
        : (isDark ? AppColors.darkSurface : const Color(0xFFF5EEE6));
    final textColor = isSelected
        ? (isDark ? const Color(0xFF1E1610) : Colors.white)
        : (isDark ? AppColors.darkTextSecondary : AppColors.figmaBrown);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: (!isSelected && isDark) ? Border.all(color: AppColors.darkBorder) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                        .withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mesPrestationsProvider);
    final notifier = ref.read(mesPrestationsProvider.notifier);
    final listeFiltree = state.prestationsFiltrees;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mes prestations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => notifier.chargerPrestations(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Rectangle de sélection du salon en haut
          PrestationSalonSelector(
            selectedSalon: state.currentSalon,
            salons: state.salonsDisponibles,
            totalPrestations: state.allPrestations.length,
            onSalonSelected: (slug) => notifier.selectionnerSalon(slug),
          ),

          // 2. Onglets de filtrage par statut (Tout, Terminées, Annulées) selon Figma
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterPill(
                  label: 'Tout',
                  isSelected: state.selectedStatutTab == 'TOUT',
                  isDark: isDark,
                  onTap: () => notifier.changerStatutTab('TOUT'),
                ),
                const SizedBox(width: 10),
                _buildFilterPill(
                  label: 'Terminées',
                  isSelected: state.selectedStatutTab == 'TERMINEE',
                  isDark: isDark,
                  onTap: () => notifier.changerStatutTab('TERMINEE'),
                ),
                const SizedBox(width: 10),
                _buildFilterPill(
                  label: 'Annulées',
                  isSelected: state.selectedStatutTab == 'ANNULEE',
                  isDark: isDark,
                  onTap: () => notifier.changerStatutTab('ANNULEE'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Liste des prestations
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => notifier.chargerPrestations(),
                    child: listeFiltree.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.45,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 72,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF6EFE7),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.content_cut_rounded,
                                            size: 32,
                                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Aucune prestation trouvée',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          state.selectedSalonSlug != null
                                              ? 'Aucune prestation dans cette catégorie pour le salon sélectionné.'
                                              : 'Vous n\'avez aucune prestation enregistrée dans cet onglet.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 24),
                            itemCount: listeFiltree.length,
                            itemBuilder: (context, index) {
                              final prestation = listeFiltree[index];
                              return PrestationCardWidget(
                                prestation: prestation,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PrestationDetailScreen(
                                        id: prestation.id,
                                        initialPrestation: prestation,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
