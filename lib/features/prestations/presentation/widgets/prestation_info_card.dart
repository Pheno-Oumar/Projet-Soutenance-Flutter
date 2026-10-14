import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/prestation_model.dart';

class PrestationInfoCard extends StatelessWidget {
  final PrestationModel prestation;

  const PrestationInfoCard({
    super.key,
    required this.prestation,
  });

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.figmaActiveGold : const Color(0xFF8D6E63),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: valueColor ?? (isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coiffeur = prestation.coiffeurComplet ?? 'Équipe ${prestation.salonNom}';
    final totalStr = '${prestation.montantTotal.toStringAsFixed(0)} FCFA';
    final dividerColor = isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0);

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
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.tag_rounded,
            label: 'Référence',
            value: prestation.referenceCode,
            valueColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
            isBold: true,
            isDark: isDark,
          ),
          Divider(height: 14, thickness: 0.8, color: dividerColor),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date & heure',
            value: prestation.dateHeureFin != null
                ? '${prestation.dateHeureDebut} → ${prestation.dateHeureFin!.contains('•') ? prestation.dateHeureFin!.split('•').last.trim() : prestation.dateHeureFin}'
                : prestation.dateHeureDebut,
            isDark: isDark,
          ),
          Divider(height: 14, thickness: 0.8, color: dividerColor),
          _buildInfoRow(
            icon: Icons.storefront_rounded,
            label: 'Salon',
            value: prestation.salonNom,
            isDark: isDark,
          ),
          Divider(height: 14, thickness: 0.8, color: dividerColor),
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Coiffeur',
            value: coiffeur,
            isDark: isDark,
          ),
          Divider(height: 14, thickness: 0.8, color: dividerColor),
          _buildInfoRow(
            icon: Icons.payment_rounded,
            label: 'Mode de règlement',
            value: prestation.modePaiement ?? 'Au salon',
            isDark: isDark,
          ),
          Divider(height: 14, thickness: 0.8, color: dividerColor),
          _buildInfoRow(
            icon: Icons.monetization_on_outlined,
            label: 'Montant total',
            value: totalStr,
            valueColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
            isBold: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
