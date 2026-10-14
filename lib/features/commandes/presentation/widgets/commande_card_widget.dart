import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/commande_model.dart';
import 'commande_status_badge.dart';

class CommandeCardWidget extends StatelessWidget {
  final CommandeModel commande;
  final VoidCallback onTapDetails;

  const CommandeCardWidget({
    super.key,
    required this.commande,
    required this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr =
        '${commande.dateCommande.day.toString().padLeft(2, '0')}/${commande.dateCommande.month.toString().padLeft(2, '0')}/${commande.dateCommande.year}';
    final montantStr = '${commande.montantTotal.toInt()} FCFA';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFFDFBF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFF0EBE5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Colonne gauche : Numéro, Date/Montant, Miniatures produits
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Numéro de commande
                Text(
                  commande.numeroCommande,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
                  ),
                ),
                const SizedBox(height: 3),

                // Date et Montant
                Text(
                  '$dateStr • $montantStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8C827A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                // Miniatures circulaires des produits commandés
                Row(
                  children: [
                    _buildProductThumbnail(
                      'assets/images/cmd_list_0.png',
                      fallback: 'assets/images/produit_cat_img_0.jpg',
                    ),
                    const SizedBox(width: 6),
                    _buildProductThumbnail(
                      'assets/images/cmd_list_1.png',
                      fallback: 'assets/images/produit_cat_img_1.jpg',
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFE6DD),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '+2',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.figmaBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Colonne droite : Badge de statut & Bouton Voir les détails
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommandeStatusBadge(statut: commande.statut),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onTapDetails,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.figmaBrown,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.figmaBrown.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Voir les détails',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductThumbnail(String path, {String? fallback}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 3,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Image.asset(
            fallback ?? 'assets/images/produit_cat_img_0.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFFF2EAE1),
              child: const Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.figmaBrown),
            ),
          ),
        ),
      ),
    );
  }
}
