import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/commande_model.dart';

class CommandeRecapWidget extends StatelessWidget {
  final CommandeModel commande;

  const CommandeRecapWidget({
    super.key,
    required this.commande,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sousTotalStr = '${commande.sousTotal.toInt()} FCFA';
    final livraisonStr = '${commande.fraisLivraison.toInt()} FCFA';
    final totalStr = '${commande.montantTotal.toInt()} FCFA';

    return Container(
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
          _buildRow('Sous-total', sousTotalStr, isDark),
          const SizedBox(height: 10),
          _buildRow('Frais de livraison', livraisonStr, isDark),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E2),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total réglé',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
                ),
              ),
              Text(
                totalStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.figmaActiveGold,
                ),
              ),
            ],
          ),
          if (commande.statut == StatutCommande.recuperee) ...[
            const SizedBox(height: 6),
            Text(
              'Paiement : ${commande.modePaiement}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8C827A),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
          ),
        ),
      ],
    );
  }
}
