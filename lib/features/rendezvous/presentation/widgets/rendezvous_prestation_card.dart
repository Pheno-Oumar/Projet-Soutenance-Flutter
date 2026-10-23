import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
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
    final imgSize = context.responsiveValue(compact: 50.0, standard: 56.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(context.responsiveValue(compact: 10.0, standard: 12.0)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: context.symmetricBorder(),
      ),
      child: Row(
        children: [
          // Miniature de la prestation
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: imgSize,
              height: imgSize,
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
                    fontSize: context.fontSize(15),
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                  ),
                ),
                if (ligne.nomVariante != null && ligne.nomVariante!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    ligne.nomVariante!,
                    style: TextStyle(
                      fontSize: context.fontSize(12),
                      color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    priceStr,
                    style: TextStyle(
                      fontSize: context.fontSize(14),
                      fontWeight: FontWeight.w800,
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
