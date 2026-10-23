import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/rendezvous_model.dart';

class RendezVousCardWidget extends StatelessWidget {
  final RendezVousModel rdv;
  final VoidCallback onTap;

  const RendezVousCardWidget({
    super.key,
    required this.rdv,
    required this.onTap,
  });

  Widget _buildStatusBadge(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    if (rdv.isAVenir) {
      bgColor = const Color(0xFF164E2E);
      textColor = Colors.white;
      label = 'À venir';
    } else if (rdv.isPasse) {
      bgColor = const Color(0xFFD9D9D9);
      textColor = const Color(0xFF333333);
      label = 'Passé';
    } else if (rdv.isAnnule) {
      bgColor = const Color(0xFFFCDCDC);
      textColor = const Color(0xFFD32F2F);
      label = 'Annulé';
    } else {
      bgColor = const Color(0xFFE0E0E0);
      textColor = const Color(0xFF333333);
      label = rdv.statutLabel;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveValue(compact: 10.0, standard: 14.0),
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: context.fontSize(12),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final serviceName = rdv.lignes.isNotEmpty
        ? (rdv.lignes.first.nomService ?? 'Soin capillaire')
        : 'Soin capillaire';
    final dateStr = rdv.dateHeureFormatee;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: EdgeInsets.all(context.responsiveValue(compact: 12.0, standard: 16.0)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: context.symmetricBorder(),
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
          // Ligne 1: Référence et Badge Statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rdv.referenceCode,
                style: TextStyle(
                  fontSize: context.fontSize(15),
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                ),
              ),
              _buildStatusBadge(context),
            ],
          ),
          const SizedBox(height: 6),

          // Ligne 2: Date et heure
          Text(
            dateStr,
            style: TextStyle(
              fontSize: context.fontSize(13),
              color: isDark ? AppColors.darkTextMuted : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),

          // Ligne 3: Service / Prestation
          Text(
            serviceName,
            style: TextStyle(
              fontSize: context.fontSize(15),
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF2E1C15),
            ),
          ),
          const SizedBox(height: 14),

          // Ligne 4: Bouton "Voir détails"
          SizedBox(
            width: double.infinity,
            height: context.responsiveValue(compact: 36.0, standard: 38.0),
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Voir détails',
                  style: TextStyle(
                    color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    fontSize: context.fontSize(13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
