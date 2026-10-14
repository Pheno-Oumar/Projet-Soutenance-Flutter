import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/reclamation_model.dart';

class ReclamationCardWidget extends StatelessWidget {
  final ReclamationModel reclamation;
  final VoidCallback onTap;

  const ReclamationCardWidget({
    super.key,
    required this.reclamation,
    required this.onTap,
  });

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    if (reclamation.isEnAttente) {
      bgColor = const Color(0xFF382A0A);
      textColor = const Color(0xFFE5A93C);
      label = 'En attente';
    } else if (reclamation.isEnCours) {
      bgColor = const Color(0xFF0D324D);
      textColor = const Color(0xFF38B6FF);
      label = 'En cours';
    } else if (reclamation.isResolue) {
      bgColor = const Color(0xFF143B22);
      textColor = const Color(0xFF4ADE80);
      label = 'Résolue';
    } else {
      bgColor = const Color(0xFF4A141A);
      textColor = const Color(0xFFF87171);
      label = 'Rejetée';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
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
          // Ligne 1: Référence de la réclamation + Badge Statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reclamation.referenceCode,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 6),

          // Ligne 2: Date • Type (ex: 12/04/2025 • Produits)
          Text(
            '${reclamation.dateCreation} • ${reclamation.typeLabel}',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextMuted : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Ligne 3: Bouton "Voir détails"
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
              ),
              child: Text(
                'Voir détails',
                style: TextStyle(
                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
