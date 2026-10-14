import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/prestation_model.dart';

class PrestationCardWidget extends StatelessWidget {
  final PrestationModel prestation;
  final VoidCallback onTap;

  const PrestationCardWidget({
    super.key,
    required this.prestation,
    required this.onTap,
  });

  Widget _buildStatusBadge() {
    if (prestation.isTerminee) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF164E2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '★ Terminée',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else if (prestation.isAnnulee) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFCDCDC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Annulée',
          style: TextStyle(
            color: Color(0xFFD32F2F),
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFE9E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          prestation.statutLabel,
          style: const TextStyle(
            color: Color(0xFF2E1C15),
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imagePath = prestation.primaryImageUrl;
    final title = prestation.primaryNomService;
    final dateStr = prestation.dateHeureDebut.contains('•')
        ? prestation.dateHeureDebut.split('•').first.trim()
        : prestation.dateHeureDebut;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Miniature image à gauche avec badge multi-variantes si applicable
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 82,
                      height: 82,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/images/service_img_0.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.figmaCardBg,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.content_cut_rounded,
                              color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (prestation.hasMultipleVariants)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.figmaBrown.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${prestation.variantsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // 2. Colonne centrale d'informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre principal
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (prestation.hasMultipleVariants)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF3E9DD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${prestation.variantsCount} services',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Salon + Date
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.figmaActiveGold : Colors.grey[500],
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${prestation.salonNom} • $dateStr',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Résumé des variantes si multiples
                    if (prestation.hasMultipleVariants) ...[
                      const SizedBox(height: 3),
                      Text(
                        prestation.lignes.map((l) => l.nomVariante.isNotEmpty ? l.nomVariante : l.nomService).join(' • '),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Badge de statut + Bouton "Voir les détails"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(),
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                                      .withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Voir les détails',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF1E1610) : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
