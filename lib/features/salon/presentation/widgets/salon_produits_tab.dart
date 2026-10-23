import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../routing/route_names.dart';
import '../../data/models/produit_salon_model.dart';
import '../providers/salon_provider.dart';

class SalonProduitsTab extends ConsumerWidget {
  final String slugSalon;
  final String salonNom;

  const SalonProduitsTab({
    super.key,
    this.slugSalon = 'beauty-by-dika',
    this.salonNom = 'Beauty By Dika',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(salonCategoriesProvider(slugSalon));

    return categoriesAsync.when(
      loading: () => _buildLoadingSkeleton(context, isDark),
      error: (_, _) => _buildEmptyState(context, isDark),
      data: (apiCategories) {
        if (apiCategories.isEmpty) {
          return _buildEmptyState(context, isDark);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: apiCategories.map((cat) {
            return _buildCategoryItem(
              context: context,
              isDark: isDark,
              categorieId: cat.id,
              nom: cat.nom,
              description: cat.description ??
                  (cat.nombreProduits > 0
                      ? '${cat.nombreProduits} référence${cat.nombreProduits > 1 ? "s" : ""}'
                      : 'Boutique du salon'),
              imageUrl: cat.imageUrl,
              nombreProduits: cat.nombreProduits,
              produits: cat.produits,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required bool isDark,
    required int categorieId,
    required String nom,
    required String description,
    required String? imageUrl,
    required int nombreProduits,
    required List<ProduitSalonModel> produits,
  }) {
    // Calcul du prix minimal si des produits sont disponibles
    double? minPrix;
    if (produits.isNotEmpty) {
      minPrix = produits
          .map((p) => p.prixVente)
          .where((p) => p > 0)
          .fold<double?>(null, (prev, elem) => prev == null ? elem : (elem < prev ? elem : prev));
    }

    final priceLabel = minPrix != null && minPrix > 0
        ? '${minPrix.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} F'
        : (nombreProduits > 0 ? '$nombreProduits réf.' : '');

    final isNetwork = imageUrl != null && imageUrl.startsWith('http');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          final encodedTitle = Uri.encodeComponent(nom);
          final encodedDesc = Uri.encodeComponent(description);
          final encodedSlug = Uri.encodeComponent(slugSalon);
          final encodedSalon = Uri.encodeComponent(salonNom);

          context.push(
            '${RouteNames.categorieProduits}?id=$categorieId&title=$encodedTitle&desc=$encodedDesc&slug=$encodedSlug&salon=$encodedSalon',
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: context.symmetricBorder(),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: isNetwork
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholderImage(isDark),
                        )
                      : Image.asset(
                          imageUrl != null && imageUrl.isNotEmpty
                              ? imageUrl
                              : 'assets/images/produit_cat_img_1.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholderImage(isDark),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nom,
                      style: TextStyle(
                        fontSize: context.fontSize(14),
                        fontWeight: FontWeight.w800,
                        color: context.adaptiveTextColor(),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: context.fontSize(11.5),
                        color: context.adaptiveSubtextColor(),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (priceLabel.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      minPrix != null ? 'À partir de' : 'Catalogue',
                      style: TextStyle(
                        fontSize: context.fontSize(10.5),
                        color: context.adaptiveSubtextColor(),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        priceLabel,
                        style: TextStyle(
                          fontSize: context.fontSize(13),
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: context.adaptiveSubtextColor(),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: context.symmetricBorder(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.figmaActiveGold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.figmaActiveGold,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Aucun produit en vente',
            style: TextStyle(
              fontSize: context.fontSize(15),
              fontWeight: FontWeight.w800,
              color: context.adaptiveTextColor(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ce salon ne vend pas de produits capillaires pour le moment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.fontSize(12.5),
              color: context.adaptiveSubtextColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: 64,
      height: 64,
      color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0EBE1),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: AppColors.figmaBrown,
        size: 24,
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, bool isDark) {
    return Column(
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: context.symmetricBorder(),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 180,
                        height: 11,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBorder : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
