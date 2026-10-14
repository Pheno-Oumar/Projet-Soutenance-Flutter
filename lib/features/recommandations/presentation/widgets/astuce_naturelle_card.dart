import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/astuce_naturelle_model.dart';

class AstuceNaturelleCard extends StatelessWidget {
  final AstuceNaturelleModel astuce;

  const AstuceNaturelleCard({
    super.key,
    required this.astuce,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          // En-tête : Tag budget + Titre
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      astuce.titre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF221814),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      astuce.sousTitre,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF7E7369),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  astuce.type,
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ingrédients
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBg : const Color(0xFFFBF8F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingrédients nécessaires :',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  astuce.ingredients,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFE5DDD5) : const Color(0xFF382A22),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Préparation & Application
          Text(
            'Mode d\'emploi :',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF4A3B32),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            astuce.preparation,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF5A4D45),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // Bénéfice
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.spa_outlined,
                  size: 16,
                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    astuce.benefice,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
