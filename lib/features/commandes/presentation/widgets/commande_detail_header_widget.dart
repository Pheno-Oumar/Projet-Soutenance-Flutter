import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/commande_model.dart';
import 'commande_status_badge.dart';

class CommandeDetailHeaderWidget extends StatelessWidget {
  final CommandeModel commande;

  const CommandeDetailHeaderWidget({
    super.key,
    required this.commande,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr =
        '${commande.dateCommande.day.toString().padLeft(2, '0')}/${commande.dateCommande.month.toString().padLeft(2, '0')}/${commande.dateCommande.year}';
    final timeStr =
        '${commande.dateCommande.hour.toString().padLeft(2, '0')}:${commande.dateCommande.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFFDFBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFF0EBE5),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande ${commande.numeroCommande}',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Passée le $dateStr • $timeStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8C827A),
                  ),
                ),
              ],
            ),
          ),
          CommandeStatusBadge(statut: commande.statut),
        ],
      ),
    );
  }
}
