import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/commande_model.dart';

class CommandeArticlesWidget extends StatelessWidget {
  final List<LigneCommandeModel> articles;

  const CommandeArticlesWidget({
    super.key,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles (${articles.length})',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
          ),
        ),
        const SizedBox(height: 12),
        ...articles.map((item) => _buildArticleItem(item, isDark)),
      ],
    );
  }

  Widget _buildArticleItem(LigneCommandeModel item, bool isDark) {
    final prixStr = '${item.prixUnitaire.toInt()} FCFA';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFFDFBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFF0EBE5),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Image du produit
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 58,
              height: 58,
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.asset(
                  'assets/images/produit_cat_img_${item.id % 6}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF2EAE1),
                    alignment: Alignment.center,
                    child: const Icon(Icons.shopping_bag_outlined, color: AppColors.figmaBrown, size: 24),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Détails : Titre, Quantité, Prix Or
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.produitNom,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Quantité : ${item.quantite}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8C827A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  prixStr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.figmaActiveGold,
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
