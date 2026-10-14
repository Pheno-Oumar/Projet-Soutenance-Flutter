import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/produit_conseil_model.dart';

class RoutineProduitCard extends StatelessWidget {
  final ProduitConseilModel produit;
  final VoidCallback onTap;

  const RoutineProduitCard({
    super.key,
    required this.produit,
    required this.onTap,
  });

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

  Color _getEtapeBgColor(String etape, bool isDark) {
    final color = _getEtapeColor(etape, isDark);
    return isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.10);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final etapeColor = _getEtapeColor(produit.etapeRoutine, isDark);
    final etapeBg = _getEtapeBgColor(produit.etapeRoutine, isDark);
    final score = produit.scoreAffinite ?? 95;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.figmaActiveGold.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFEAE2D8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : const Color(0xFF5C3826).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vignette Image Produit
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 88,
                  height: 98,
                  color: isDark ? AppColors.darkCardBg : const Color(0xFFF9F6F0),
                  child: produit.imageUrl != null && produit.imageUrl!.isNotEmpty
                      ? (produit.imageUrl!.startsWith('http')
                          ? Image.network(
                              produit.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildFallbackImage(isDark),
                            )
                          : Image.asset(
                              produit.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildFallbackImage(isDark),
                            ))
                      : _buildFallbackImage(isDark),
                ),
              ),
              const SizedBox(width: 14),

              // Contenu texte & badges très lisibles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge d'étape + Score d'affinité
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: etapeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              produit.etapeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: etapeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$score% match',
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Nom du produit
                    Text(
                      produit.nom,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF221814),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Marque
                    Text(
                      produit.marque,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF7E7369),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Action "Voir le rituel"
                    Row(
                      children: [
                        Text(
                          'Voir le rituel & détails',
                          style: TextStyle(
                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage(bool isDark) {
    return Center(
      child: Icon(
        Icons.spa_rounded,
        size: 36,
        color: isDark ? const Color(0xFF6B584E) : const Color(0xFFC8B7A6),
      ),
    );
  }
}
