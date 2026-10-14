import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/prestation_model.dart';

class PrestationLigneCard extends StatelessWidget {
  final LignePrestationModel ligne;

  const PrestationLigneCard({
    super.key,
    required this.ligne,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imagePath = ligne.imageUrl ?? 'assets/images/prestation_soin.jpg';
    final serviceTitle = ligne.nomService;
    final priceStr = '${ligne.prix.toStringAsFixed(0)} FCFA';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Miniature de la variante
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 58,
              height: 58,
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
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Détails de la prestation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                  ),
                ),
                if (ligne.nomVariante.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    ligne.nomVariante,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      priceStr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      ),
                    ),
                    if (ligne.dureeMinutes > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${ligne.dureeMinutes} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
