import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/rendezvous_model.dart';

class RendezVousInfoCard extends StatelessWidget {
  final RendezVousModel rdv;

  const RendezVousInfoCard({
    super.key,
    required this.rdv,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0);
    final labelColor = isDark ? AppColors.darkTextSecondary : Colors.grey[600];
    final valueColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: context.symmetricBorder(),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveValue(compact: 12.0, standard: 16.0),
        vertical: 14,
      ),
      child: Column(
        children: [
          // Durée
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Durée',
                style: TextStyle(
                  fontSize: context.fontSize(14),
                  color: labelColor,
                ),
              ),
              Text(
                rdv.formattedDuree,
                style: TextStyle(
                  fontSize: context.fontSize(14),
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: dividerColor),
          ),

          // Coiffeuse
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Coiffeuse',
                style: TextStyle(
                  fontSize: context.fontSize(14),
                  color: labelColor,
                ),
              ),
              Text(
                rdv.coiffeurNomComplet,
                style: TextStyle(
                  fontSize: context.fontSize(14),
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: dividerColor),
          ),

          // Référence
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Référence',
                style: TextStyle(
                  fontSize: context.fontSize(14),
                  color: labelColor,
                ),
              ),
              Text(
                rdv.referenceCode,
                style: TextStyle(
                  fontSize: context.fontSize(14),
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
