import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/rendezvous_model.dart';

class RendezVousPrestationCard extends StatelessWidget {
  final LigneRendezVousModel ligne;

  const RendezVousPrestationCard({
    super.key,
    required this.ligne,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imagePath = ligne.imageUrl ?? 'assets/images/rdv_dt_venir_2.jpeg';
    final serviceTitle = ligne.nomService ?? 'Soin capillaire';
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
          // Miniature de la prestation
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
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

          // Nom du service et prix
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
                if (ligne.nomVariante != null && ligne.nomVariante!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    ligne.nomVariante!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  priceStr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
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
