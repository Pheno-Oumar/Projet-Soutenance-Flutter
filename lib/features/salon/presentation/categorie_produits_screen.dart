import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routing/route_names.dart';
import '../data/models/produit_salon_model.dart';
import 'providers/salon_provider.dart';

class CategorieProduitsScreen extends ConsumerStatefulWidget {
  final int? categorieId;
  final String? slugSalon;
  final String? salonNom;
  final String categoryTitle;
  final String categoryDescription;

  const CategorieProduitsScreen({
    super.key,
    this.categorieId,
    this.slugSalon,
    this.salonNom,
    this.categoryTitle = 'Lavage',
    this.categoryDescription =
        'Le lavage consiste à nettoyer le cuir chevelu en éliminant les impuretés, l\'excès de sébum, la transpiration et les résidus de produits de coiffage.',
  });

  @override
  ConsumerState<CategorieProduitsScreen> createState() => _CategorieProduitsScreenState();
}

class _CategorieProduitsScreenState extends ConsumerState<CategorieProduitsScreen> {
  final Set<int> _favoriteIndexes = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slug = widget.slugSalon;

    final AsyncValue<List<ProduitSalonModel>> produitsAsync = (slug != null && slug.isNotEmpty)
        ? ref.watch(salonProduitsProvider((slug: slug, categorieId: widget.categorieId)))
        : ref.watch(produitsTransversauxProvider(widget.categorieId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: _buildAppBar(isDark),
      body: produitsAsync.when(
        loading: () => _buildLoadingBody(isDark),
        error: (_, _) => _buildEmptyBody(isDark),
        data: (produits) {
          if (produits.isEmpty) {
            return _buildEmptyBody(isDark);
          }
          return _buildContent(
            isDark: isDark,
            count: produits.length,
            child: _buildDynamicGrid(produits, isDark),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Produit',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildContent({
    required bool isDark,
    required int count,
    required Widget child,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 14, 16, context.responsiveValue(compact: 70, standard: 80)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Titre & Description Remodelée
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
              borderRadius: BorderRadius.circular(14),
              border: context.symmetricBorder(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.categoryTitle,
                        style: TextStyle(
                          fontSize: context.fontSize(19),
                          fontWeight: FontWeight.w800,
                          color: context.adaptiveTextColor(),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.figmaBrown.withValues(alpha: isDark ? 0.25 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count référence${count > 1 ? "s" : ""}',
                        style: const TextStyle(
                          color: AppColors.figmaBrown,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.categoryDescription.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.categoryDescription,
                    style: TextStyle(
                      fontSize: context.fontSize(12.5),
                      color: context.adaptiveSubtextColor(),
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Grille des produits
          child,

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDynamicGrid(List<ProduitSalonModel> produits, bool isDark) {
    return Column(
      children: [
        for (int i = 0; i < produits.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: _buildDynamicProduitCard(produits[i], isDark)),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < produits.length
                      ? _buildDynamicProduitCard(produits[i + 1], isDark)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDynamicProduitCard(ProduitSalonModel produit, bool isDark) {
    final isFav = _favoriteIndexes.contains(produit.id);
    final photoUrl = produit.mainImage;
    final isNetwork = photoUrl != null && photoUrl.startsWith('http');
    final formattedPrice =
        '${produit.prixVente.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA';

    return GestureDetector(
      onTap: () {
        final encodedTitle = Uri.encodeComponent(produit.nom);
        final encodedPrice = Uri.encodeComponent(formattedPrice);
        final encodedImage = Uri.encodeComponent(photoUrl ?? '');
        final encodedBrand = Uri.encodeComponent(produit.categorieNom ?? widget.categoryTitle);
        final encodedDesc = Uri.encodeComponent(produit.description ?? '');
        final encodedSlug = Uri.encodeComponent(widget.slugSalon ?? '');
        final encodedSalon = Uri.encodeComponent(widget.salonNom ?? '');

        context.push(
          '${RouteNames.produitDetail}?id=${produit.id}&slug=$encodedSlug&salon=$encodedSalon&title=$encodedTitle&price=$encodedPrice&image=$encodedImage&brand=$encodedBrand&desc=$encodedDesc&stock=${produit.quantiteEnStock}',
        );
      },
      child: Container(
        height: 185,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppColors.darkSurface : const Color(0xFFF0EBE1),
          border: context.symmetricBorder(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo du produit
              if (isNetwork)
                Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildCardPlaceholder(),
                )
              else
                Image.asset(
                  photoUrl != null && photoUrl.isNotEmpty
                      ? photoUrl
                      : 'assets/images/les_produits_d_une_categorie_img_0.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildCardPlaceholder(),
                ),

              // Voile noir transparent dégradé pour la lisibilité
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // Cœur favori en haut à droite
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isFav) {
                        _favoriteIndexes.remove(produit.id);
                      } else {
                        _favoriteIndexes.add(produit.id);
                      }
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? const Color(0xFFE53935) : Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ),

              // Badge Rupture de stock si épuisé
              if (produit.isEnRupture)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Épuisé',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              // Nom & Prix au bas de la carte
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Nom du produit
                    Expanded(
                      child: Text(
                        produit.nom,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.fontSize(13),
                          fontWeight: FontWeight.w700,
                          shadows: const [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Badge de prix avec bordure dorée Figma
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.figmaActiveGold,
                          width: 1.1,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formattedPrice,
                          style: TextStyle(
                            color: AppColors.figmaActiveGold,
                            fontSize: context.fontSize(10),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBody(bool isDark) {
    return _buildContent(
      isDark: isDark,
      count: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaCardBg,
          borderRadius: BorderRadius.circular(14),
          border: context.symmetricBorder(),
        ),
        child: Column(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 36,
              color: AppColors.figmaActiveGold.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucun produit disponible dans cette catégorie',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: context.adaptiveSubtextColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPlaceholder() {
    return Container(
      color: const Color(0xFFE8DFD5),
      alignment: Alignment.center,
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.black38,
        size: 32,
      ),
    );
  }

  Widget _buildLoadingBody(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 18),
          for (int i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 185,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 185,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
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
