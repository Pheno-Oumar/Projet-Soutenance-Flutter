import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'details/reclamation_detail_screen.dart';
import 'nouvelle_reclamation_screen.dart';
import 'providers/reclamation_provider.dart';
import 'widgets/reclamation_card_widget.dart';
import 'widgets/reclamation_salon_selector.dart';

class MesReclamationsScreen extends ConsumerWidget {
  const MesReclamationsScreen({super.key});

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
        : (isDark ? AppColors.darkSurface : const Color(0xFFEFE7DE));
    final textColor = isSelected
        ? (isDark ? const Color(0xFF1E1610) : Colors.white)
        : (isDark ? AppColors.darkTextSecondary : AppColors.figmaBrown);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    final state = ref.watch(mesReclamationsProvider);
    final notifier = ref.read(mesReclamationsProvider.notifier);
    final listeFiltree = state.reclamationsFiltrees;
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
          'Mes réclamations',
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
            onPressed: () => notifier.chargerReclamations(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Rectangle de sélection des salons en haut
          ReclamationSalonSelector(
            selectedSalon: state.currentSalon,
            salons: state.salonsDisponibles,
            totalReclamations: state.allReclamations.length,
            onSalonSelected: (slug) => notifier.selectionnerSalon(slug),
          ),

          // 2. Onglets de filtrage par statut
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterPill(
                  label: 'Tout',
                  isSelected: state.selectedStatutTab == 'TOUT',
                  isDark: isDark,
                  onTap: () => notifier.changerStatutTab('TOUT'),
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'En attente',
                  isSelected: state.selectedStatutTab == 'EN_ATTENTE',
                  isDark: isDark,
                  onTap: () => notifier.changerStatutTab('EN_ATTENTE'),
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'En cours',
                  isSelected: state.selectedStatutTab == 'EN_COURS',
                  isDark: isDark,
                  onTap: () => notifier.changerStatutTab('EN_COURS'),
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'Résolue',
                  isSelected: state.selectedStatutTab == 'RESOLUE',
                  isDark: isDark,
                  onTap: () => notifier.changerStatutTab('RESOLUE'),
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'Rejetée',
                  isSelected: state.selectedStatutTab == 'REJETEE',
                  isDark: isDark,
                  onTap: () => notifier.changerStatutTab('REJETEE'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Liste des réclamations
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => notifier.chargerReclamations(),
                    child: listeFiltree.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.40,
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
                                            Icons.report_problem_outlined,
                                            size: 32,
                                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Aucune réclamation trouvée',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          state.selectedSalonSlug != null
                                              ? 'Aucune réclamation dans ce statut pour le salon sélectionné.'
                                              : 'Vous n\'avez aucune réclamation dans cette catégorie.',
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
                            padding: const EdgeInsets.only(top: 4, bottom: 16),
                            itemCount: listeFiltree.length,
                            itemBuilder: (context, index) {
                              final rec = listeFiltree[index];
                              return ReclamationCardWidget(
                                reclamation: rec,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReclamationDetailScreen(
                                        id: rec.id,
                                        initialReclamation: rec,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ),

          // 4. Bouton inférieur "Ajouter une réclamation"
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NouvelleReclamationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    foregroundColor: isDark ? const Color(0xFF1E1610) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Ajouter une réclamation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF1E1610) : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
