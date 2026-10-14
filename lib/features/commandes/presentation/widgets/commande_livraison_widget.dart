import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/commande_model.dart';

class CommandeLivraisonWidget extends StatelessWidget {
  final CommandeModel commande;

  const CommandeLivraisonWidget({
    super.key,
    required this.commande,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFFDFBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFF0EBE5),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lieu de livraison',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${commande.clientNom} • ${commande.clientTelephone}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8C827A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            commande.adresseLivraison,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2D2B2A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
