import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';

class CategorieProduitsScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryDescription;

  const CategorieProduitsScreen({
    super.key,
    this.categoryTitle = 'Lavage',
    this.categoryDescription =
        'Le lavage consiste à nettoyer le cuir chevelu en éliminant les impuretés, l\'excès de sébum, la transpiration et les résidus de produits de coiffage.',
  });

  @override
  State<CategorieProduitsScreen> createState() => _CategorieProduitsScreenState();
}

class _CategorieProduitsScreenState extends State<CategorieProduitsScreen> {
  final Set<int> _favoriteIndexes = {};

  final List<Map<String, String>> _produits = const [
    {
      'name': 'Oreal',
      'brand': 'L\'Oréal Professionnel',
      'price': '5 000 FCFA',
      'image': 'assets/images/les_produits_d_une_categorie_img_0.png',
    },
    {
      'name': 'Bare',
      'brand': 'Head & Shoulders',
      'price': '6 000 FCFA',
      'image': 'assets/images/les_produits_d_une_categorie_img_1.png',
    },
    {
      'name': 'Najel',
      'brand': 'Najel Soin Purifiant',
      'price': '8 000 FCFA',
      'image': 'assets/images/les_produits_d_une_categorie_img_2.png',
    },
    {
      'name': 'Palmolive',
      'brand': 'Palmolive Naturals',
      'price': '4 000 FCFA',
      'image': 'assets/images/les_produits_d_une_categorie_img_3.png',
    },
    {
      'name': 'Kérastase',
      'brand': 'Kérastase Paris',
      'price': '7 000 FCFA',
      'image': 'assets/images/les_produits_d_une_categorie_img_4.png',
    },
    {
      'name': 'Soin visage',
      'brand': 'La Rosée Cosmétique',
      'price': '12 000 FCFA',
      'image': 'assets/images/les_produits_d_une_categorie_img_5.png',
    },
    {
      'name': 'Oreal',
      'brand': 'L\'Oréal Professionnel',
      'price': '5 000 FCFA',
      'image': 'assets/images/les_produits_d_une_categorie_img_0.png',
    },
    {
      'name': 'Bare',
      'brand': 'Head & Shoulders',
      'price': '6 000 FCFA',
      'image': 'assets/images/les_produits_d_une_categorie_img_1.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================================================
            // 1. SECTION TITRE & DESCRIPTION REMODELÉE (Nom & Description)
            // ==============================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
                  width: 1.0,
                ),
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
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.figmaBrown.withValues(alpha: isDark ? 0.25 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '8 références',
                          style: TextStyle(
                            color: AppColors.figmaBrown,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.categoryDescription,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF555555),
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==============================================================
            // 2. GRILLE 2 COLONNES DES PRODUITS (100% Column / Row / Container)
            // ==============================================================
            for (int i = 0; i < _produits.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(child: _buildProduitCard(i, isDark)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: i + 1 < _produits.length
                          ? _buildProduitCard(i + 1, isDark)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProduitCard(int index, bool isDark) {
    final item = _produits[index];
    final isFav = _favoriteIndexes.contains(index);

    return GestureDetector(
      onTap: () {
        context.push(
          '${RouteNames.produitDetail}?title=${Uri.encodeComponent(item['name']!)}&price=${Uri.encodeComponent(item['price']!)}&image=${Uri.encodeComponent(item['image']!)}',
        );
      },
      child: Container(
        height: 185,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppColors.darkSurface : const Color(0xFFF0EBE1),
          border: isDark ? Border.all(color: AppColors.darkBorder, width: 1.0) : null,
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
              Image.asset(
                item['image']!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFE8DFD5),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.black38,
                    size: 32,
                  ),
                ),
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
                        _favoriteIndexes.remove(index);
                      } else {
                        _favoriteIndexes.add(index);
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
                        item['name']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          shadows: [
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

                    // Badge de prix avec bordure dorée Figma (Stroke en or)
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
                      child: Text(
                        item['price']!,
                        style: const TextStyle(
                          color: AppColors.figmaActiveGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
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
}
