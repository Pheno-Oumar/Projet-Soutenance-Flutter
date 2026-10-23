import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routing/route_names.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'details/rendezvous_detail_screen.dart';
import 'providers/rendezvous_provider.dart';
import 'widgets/rendezvous_card_widget.dart';
import 'widgets/rendezvous_salon_selector.dart';

class MesRendezVousScreen extends ConsumerWidget {
  const MesRendezVousScreen({super.key});

  Widget _buildFilterPill(
    BuildContext context, {
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
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveValue(compact: 14.0, standard: 18.0),
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: context.symmetricBorder(isSelected: isSelected),
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
            fontSize: context.fontSize(12.5),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!authState.isAuthenticated) {
      return _buildGuestView(context, isDark);
    }

    final state = ref.watch(mesRendezVousProvider);
    final notifier = ref.read(mesRendezVousProvider.notifier);
    final listeFiltree = state.rendezVousFiltres;

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
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mes rendez-vous',
          style: TextStyle(
            fontSize: context.fontSize(18),
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
            color: Colors.white,
            onPressed: () => notifier.chargerRendezVous(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Sélecteur de salon en haut
          RendezvousSalonSelector(
            selectedSalon: state.currentSalon,
            salons: state.salonsDisponibles,
            totalRendezVous: state.allRendezVous.length,
            onSalonSelected: (slug) => notifier.selectionnerSalon(slug),
          ),

          // 2. Onglets de filtrage par statut
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterPill(
                  context,
                  label: 'À venir',
                  isSelected: state.selectedStatutTab == 'A_VENIR',
                  isDark: isDark,
                  onTap: () => notifier.changerStatutTab('A_VENIR'),
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context,
                  label: 'Passé',
                  isSelected: state.selectedStatutTab == 'PASSE',
                  isDark: isDark,
                  onTap: () => notifier.changerStatutTab('PASSE'),
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context,
                  label: 'Annulé',
                  isSelected: state.selectedStatutTab == 'ANNULE',
                  isDark: isDark,
                  onTap: () => notifier.changerStatutTab('ANNULE'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Liste des rendez-vous
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => notifier.chargerRendezVous(),
                    child: listeFiltree.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: context.heightPercent(0.45, min: 260, max: 400),
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
                                            border: context.symmetricBorder(),
                                          ),
                                          child: Icon(
                                            Icons.calendar_today_rounded,
                                            size: 32,
                                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Aucun rendez-vous trouvé',
                                          style: TextStyle(
                                            fontSize: context.fontSize(16),
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          state.selectedSalonSlug != null
                                              ? 'Aucun rendez-vous dans ce statut pour le salon sélectionné.'
                                              : 'Vous n\'avez aucun rendez-vous dans cette catégorie.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: context.fontSize(13),
                                            color: context.adaptiveSubtextColor(),
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
                            padding: EdgeInsets.only(
                              top: 4,
                              bottom: context.responsiveValue(compact: 70, standard: 80),
                            ),
                            itemCount: listeFiltree.length,
                            itemBuilder: (context, index) {
                              final rdv = listeFiltree[index];
                              return RendezVousCardWidget(
                                rdv: rdv,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RendezVousDetailScreen(
                                        id: rdv.id,
                                        initialRdv: rdv,
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

  Widget _buildGuestView(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mes rendez-vous',
          style: TextStyle(
            fontSize: context.fontSize(18),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event_note_rounded,
                    color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Suivez vos rendez-vous',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.fontSize(18),
                    fontWeight: FontWeight.w800,
                    color: context.adaptiveTextColor(),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Connectez-vous pour consulter vos rendez-vous confirmés, vos historiques et suivre vos prestations par salon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.fontSize(13.5),
                    color: context.adaptiveSubtextColor(),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => context.push(RouteNames.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Se connecter',
                      style: TextStyle(
                        fontSize: context.fontSize(14.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => context.push(RouteNames.register),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      side: BorderSide(
                        color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: context.fontSize(14.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

