import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../data/models/astuce_naturelle_model.dart';
import 'providers/recommandation_provider.dart';
import 'widgets/astuce_naturelle_card.dart';
import 'widgets/profil_capillaire_card.dart';
import 'widgets/routine_produit_card.dart';

class MesRecommandationsScreen extends ConsumerStatefulWidget {
  const MesRecommandationsScreen({super.key});

  @override
  ConsumerState<MesRecommandationsScreen> createState() =>
      _MesRecommandationsScreenState();
}

class _MesRecommandationsScreenState
    extends ConsumerState<MesRecommandationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recoState = ref.watch(derniereRecommandationProvider);
    final profilState = ref.watch(profilCapillaireProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final reco = recoState.valueOrNull;
    final profil = profilState.valueOrNull;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.compte);
            }
          },
        ),
        title: const Text(
          'Mes Recommandations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Historique des routines',
            icon: const Icon(Icons.history_rounded, color: Colors.white, size: 24),
            onPressed: () {
              context.push(RouteNames.historiqueRecommandations);
            },
          ),
        ],
      ),
      body: recoState.isLoading && reco == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.figmaBrown),
            )
          : RefreshIndicator(
              color: AppColors.figmaBrown,
              onRefresh: () async {
                await ref.read(derniereRecommandationProvider.notifier).rafraichir();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==============================================================
                    // 1. CARTE PROFIL CAPILLAIRE ÉPURÉE
                    // ==============================================================
                    ProfilCapillaireCard(
                      profil: profil,
                      onEditTap: () {
                        context.push(RouteNames.profilCapillaire);
                      },
                    ),
                    const SizedBox(height: 14),

                    // ==============================================================
                    // 2. COOLDOWN OU BOUTON DE GÉNÉRATION
                    // ==============================================================
                    if (reco != null && reco.isCooldownActive)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Routine active • Prochain diagnostic dans ${reco.joursRestantsAvantProchainDiagnostic} jours.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await ref.read(derniereRecommandationProvider.notifier).genererRoutine();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Votre routine capillaire personnalisée a été générée !'),
                                    backgroundColor: AppColors.figmaBrown,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().replaceAll('Exception: ', '')),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.figmaBrown,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Générer ma routine personnalisée',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // ==============================================================
                    // 3. BARRE D'ONGLETS ÉPURÉE (Produits vs Astuces Économiques)
                    // ==============================================================
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFEFE8DF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: isDark ? AppColors.darkTextSecondary : const Color(0xFF7E7369),
                        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        tabs: const [
                          Tab(text: 'Produits Conseillés'),
                          Tab(text: 'Astuces Maison (0 FCFA)'),
                        ],
                        onTap: (index) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ==============================================================
                    // 4. CONTENU DE L'ONGLET SÉLECTIONNÉ
                    // ==============================================================
                    if (_tabController.index == 0) ...[
                      // SECTION PRODUITS DE LA ROUTINE
                      if (reco != null && reco.produitLavage != null) ...[
                        RoutineProduitCard(
                          produit: reco.produitLavage!,
                          onTap: () {
                            context.push(
                              RouteNames.produitRecommandeDetail,
                              extra: reco.produitLavage,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (reco != null && reco.produitSoinProfond != null) ...[
                        RoutineProduitCard(
                          produit: reco.produitSoinProfond!,
                          onTap: () {
                            context.push(
                              RouteNames.produitRecommandeDetail,
                              extra: reco.produitSoinProfond,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (reco != null && reco.produitHydratation != null) ...[
                        RoutineProduitCard(
                          produit: reco.produitHydratation!,
                          onTap: () {
                            context.push(
                              RouteNames.produitRecommandeDetail,
                              extra: reco.produitHydratation,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (reco != null && reco.produitFinition != null) ...[
                        RoutineProduitCard(
                          produit: reco.produitFinition!,
                          onTap: () {
                            context.push(
                              RouteNames.produitRecommandeDetail,
                              extra: reco.produitFinition,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Conseils personnalisés
                      if (reco != null &&
                          reco.conseilsPersonnalises != null &&
                          reco.conseilsPersonnalises!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : const Color(0xFFEAE2D8),
                              width: 1.2,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conseils de nos spécialistes',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                reco.conseilsPersonnalises!,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: isDark ? const Color(0xFFDCD2C7) : const Color(0xFF4A3B32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      // SECTION ASTUCES MAISON & ÉCONOMIQUES (0 FCFA)
                      Text(
                        'Soins naturels & Recettes maison',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1E140C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Des alternatives efficaces avec des ingrédients du quotidien sans rien dépenser',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF7E7369),
                        ),
                      ),
                      const SizedBox(height: 14),

                      for (final astuce in AstuceNaturelleModel.astucesParDefaut) ...[
                        AstuceNaturelleCard(astuce: astuce),
                        const SizedBox(height: 12),
                      ],
                    ],

                    const SizedBox(height: 24),

                    // ==============================================================
                    // 5. LIEN SOBRE VERS L'HISTORIQUE
                    // ==============================================================
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          context.push(RouteNames.historiqueRecommandations);
                        },
                        icon: Icon(
                          Icons.history_rounded,
                          size: 18,
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        ),
                        label: Text(
                          'Consulter l\'historique de mes routines',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
