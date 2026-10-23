import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../data/models/astuce_naturelle_model.dart';
import '../data/models/produit_conseil_model.dart';
import 'widgets/astuce_naturelle_card.dart';

class DetailsProduitRecommandeScreen extends StatefulWidget {
  final ProduitConseilModel produit;

  const DetailsProduitRecommandeScreen({
    super.key,
    required this.produit,
  });

  @override
  State<DetailsProduitRecommandeScreen> createState() =>
      _DetailsProduitRecommandeScreenState();
}

class _DetailsProduitRecommandeScreenState
    extends State<DetailsProduitRecommandeScreen> {
  bool isFavorited = false;

  Color _getEtapeColor(String etape, bool isDark) {
    switch (etape.toUpperCase()) {
      case 'LAVAGE':
        return isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);
      case 'SOIN_PROFOND':
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100);
      case 'HYDRATATION':
        return isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
      case 'FINITION':
        return isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown;
      default:
        return AppColors.figmaBrown;
    }
  }

  AstuceNaturelleModel? _getAstuceAlternative(ProduitConseilModel p) {
    if (p.alternativeNaturelleNom != null && p.alternativeNaturelleNom!.trim().isNotEmpty) {
      return AstuceNaturelleModel(
        titre: p.alternativeNaturelleNom!.trim(),
        sousTitre: 'Alternative sur mesure conseillée pour cette étape',
        type: '0 FCFA • Maison',
        ingredients: (p.alternativeNaturelleIngredients != null && p.alternativeNaturelleIngredients!.trim().isNotEmpty)
            ? p.alternativeNaturelleIngredients!.trim()
            : 'Ingrédients naturels accessibles du quotidien',
        preparation: (p.alternativeNaturelleRecette != null && p.alternativeNaturelleRecette!.trim().isNotEmpty)
            ? p.alternativeNaturelleRecette!.trim()
            : 'Préparer et appliquer avec soin sur vos cheveux selon vos besoins.',
        benefice: 'Soin maison 100% naturel, économique et sans risque d\'agression chimique.',
      );
    }

    switch (p.etapeRoutine.toUpperCase()) {
      case 'LAVAGE':
        return AstuceNaturelleModel.astucesParDefaut[2]; // Eau de riz fortifiante
      case 'SOIN_PROFOND':
        return AstuceNaturelleModel.astucesParDefaut[1]; // Masque avocat & banane
      case 'HYDRATATION':
        return AstuceNaturelleModel.astucesParDefaut[0]; // Bain tiède nourrissant
      case 'FINITION':
        return AstuceNaturelleModel.astucesParDefaut[3]; // Scellage karité
      default:
        return AstuceNaturelleModel.astucesParDefaut[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.produit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final etapeColor = _getEtapeColor(p.etapeRoutine, isDark);
    final score = p.scoreAffinite ?? 95;
    final alternativeNaturelle = _getAstuceAlternative(p);

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
        title: const Text(
          'Détail du Soin',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorited ? Colors.redAccent : Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFavorited = !isFavorited;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorited
                        ? 'Ajouté à vos soins favoris'
                        : 'Retiré de vos favoris',
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.figmaBrown,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================================================
            // 1. IMAGE DU PRODUIT
            // ==============================================================
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 240,
                  color: isDark ? AppColors.darkCardBg : Colors.white,
                  child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                      ? (p.imageUrl!.startsWith('http')
                          ? Image.network(
                              p.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => _buildFallbackHero(),
                            )
                          : Image.asset(
                              p.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => _buildFallbackHero(),
                            ))
                      : _buildFallbackHero(),
                ),

                // Étape en bas à gauche
                Positioned(
                  bottom: 14,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: etapeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      p.etapeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Score en haut à droite
                Positioned(
                  top: 14,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$score% match',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ==============================================================
            // 2. NOM ET MARQUE
            // ==============================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.marque.toUpperCase(),
                    style: TextStyle(
                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.nom,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E140C),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),

            // ==============================================================
            // 3. RITUEL D'APPLICATION
            // ==============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Container(
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
                      'Rituel & Application',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E140C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.modeUtilisation,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? const Color(0xFFDCD2C7) : const Color(0xFF4A3E36),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==============================================================
            // 4. DESCRIPTION DU SOIN
            // ==============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Container(
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
                      'Bienfaits & Description',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E140C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? const Color(0xFFDCD2C7) : const Color(0xFF4A3E36),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==============================================================
            // 5. ALTERNATIVE NATURELLE MAISON (0 FCFA)
            // ==============================================================
            if (alternativeNaturelle != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                child: Text(
                  'Alternative Naturelle Maison (0 FCFA)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E140C),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: AstuceNaturelleCard(astuce: alternativeNaturelle),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),

      // ==============================================================
      // 6. BOUTON TROUVER UN SALON
      // ==============================================================
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : const Color(0xFFEAE2D8),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                context.push(RouteNames.salons);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.figmaBrown,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Trouver un salon partenaire',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackHero() {
    return const Center(
      child: Icon(
        Icons.spa_rounded,
        size: 64,
        color: Color(0xFFC8B7A6),
      ),
    );
  }
}
