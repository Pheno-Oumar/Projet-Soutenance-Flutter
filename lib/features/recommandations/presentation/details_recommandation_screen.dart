import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../data/models/astuce_naturelle_model.dart';
import '../data/models/recommandation_capillaire_model.dart';
import 'providers/recommandation_provider.dart';
import 'widgets/astuce_naturelle_card.dart';
import 'widgets/routine_produit_card.dart';

class DetailsRecommandationScreen extends ConsumerWidget {
  final int id;
  final RecommandationCapillaireModel? initialRecommandation;

  const DetailsRecommandationScreen({
    super.key,
    required this.id,
    this.initialRecommandation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recoAsync = ref.watch(detailRecommandationProvider(id));
    final reco = initialRecommandation ?? recoAsync.valueOrNull;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (reco == null && recoAsync.isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAF7F2),
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          title: const Text('Détails recommandation'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.figmaBrown),
        ),
      );
    }

    final data = reco!;
    final dateFormatee = DateFormat('dd MMMM yyyy', 'fr_FR').format(data.dateRecommandation);

    final profileParts = [
      data.typeCheveux,
      data.porosite,
      data.cuirChevelu,
      data.longueur,
    ].where((s) => s != null && s.isNotEmpty).toList();

    final profileSummary = profileParts.isNotEmpty
        ? profileParts.join(' • ')
        : 'Diagnostic capillaire';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAF7F2),
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
          data.reference,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================================================
            // 1. CARTE RÉSUMÉ DU DIAGNOSTIC
            // ==============================================================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFEAE2D8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Diagnostic du $dateFormatee',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E140C),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: isDark ? 0.25 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${data.scoreGlobal}% match',
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profileSummary,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==============================================================
            // 2. PRODUITS DE LA ROUTINE
            // ==============================================================
            Text(
              'Soins Recommandés',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E140C),
              ),
            ),
            const SizedBox(height: 12),

            if (data.produitLavage != null) ...[
              RoutineProduitCard(
                produit: data.produitLavage!,
                onTap: () {
                  context.push(
                    RouteNames.produitRecommandeDetail,
                    extra: data.produitLavage,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            if (data.produitSoinProfond != null) ...[
              RoutineProduitCard(
                produit: data.produitSoinProfond!,
                onTap: () {
                  context.push(
                    RouteNames.produitRecommandeDetail,
                    extra: data.produitSoinProfond,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            if (data.produitHydratation != null) ...[
              RoutineProduitCard(
                produit: data.produitHydratation!,
                onTap: () {
                  context.push(
                    RouteNames.produitRecommandeDetail,
                    extra: data.produitHydratation,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            if (data.produitFinition != null) ...[
              RoutineProduitCard(
                produit: data.produitFinition!,
                onTap: () {
                  context.push(
                    RouteNames.produitRecommandeDetail,
                    extra: data.produitFinition,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            // ==============================================================
            // 3. CONSEILS PERSONNALISÉS
            // ==============================================================
            if (data.conseilsPersonnalises != null &&
                data.conseilsPersonnalises!.isNotEmpty) ...[
              const SizedBox(height: 10),
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
                      'Conseils & Rituel d\'application',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.conseilsPersonnalises!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: isDark ? const Color(0xFFDCD2C7) : const Color(0xFF4A3B32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ==============================================================
            // 4. RECETTES NATURELLES COMPLÉMENTAIRES (0 FCFA)
            // ==============================================================
            Text(
              'Astuces Naturelles & Maison (0 FCFA)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E140C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complétez votre routine avec des ingrédients naturels accessibles',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF7E7369),
              ),
            ),
            const SizedBox(height: 12),

            for (final astuce in AstuceNaturelleModel.astucesParDefaut.take(3)) ...[
              AstuceNaturelleCard(astuce: astuce),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
