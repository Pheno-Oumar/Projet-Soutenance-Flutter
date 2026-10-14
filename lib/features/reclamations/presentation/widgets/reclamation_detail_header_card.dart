import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/reclamation_model.dart';

class ReclamationDetailHeaderCard extends StatelessWidget {
  final ReclamationModel reclamation;

  const ReclamationDetailHeaderCard({
    super.key,
    required this.reclamation,
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
      bgColor = const Color(0xFFF28B82).withValues(alpha: 0.85);
      textColor = Colors.white;
      label = 'Rejetée';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salon concerné',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${reclamation.salonNom} (${reclamation.salonAdresse.split(',').last.trim()})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Motif : ${reclamation.typeLabel} • ${reclamation.dateCreation}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildStatusBadge(),
        ],
      ),
    );
  }
}
