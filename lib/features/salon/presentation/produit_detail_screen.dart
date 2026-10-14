import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../panier/presentation/providers/panier_provider.dart';

class ProduitDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String price;
  final String image;
  final String brand;

  const ProduitDetailScreen({
    super.key,
    this.title = 'Oreal - Soin Capillaire',
    this.price = '5 000 FCFA',
    this.image = 'assets/images/details_d_un_produit_img_0.png',
    this.brand = 'L\'Oréal Professionnel',
  });

  @override
  ConsumerState<ProduitDetailScreen> createState() => _ProduitDetailScreenState();
}

class _ProduitDetailScreenState extends ConsumerState<ProduitDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;

  late final List<String> _images;

  @override
  void initState() {
    super.initState();
    _images = [
      widget.image,
      'assets/images/details_d_un_produit_img_1.png',
      'assets/images/details_d_un_produit_img_2.png',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: Stack(
        children: [
          // ==============================================================
          // CONTENU DÉFILANT (Hero + Miniatures + Infos remodelées + Description)
          // ==============================================================
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Grande photo principale (Hero)
                _buildHeroImage(isDark),

                const SizedBox(height: 14),

                // 2. Ligne de miniatures & indicateur 1/3
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Miniatures cliquables
                      for (int i = 0; i < 3 && i < _images.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImageIndex = i;
                              });
                            },
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedImageIndex == i
                                      ? AppColors.figmaActiveGold
                                      : (isDark ? AppColors.darkBorder : const Color(0xFFE0E4EB)),
                                  width: _selectedImageIndex == i ? 2.0 : 1.0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  _images[i],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF5EFE6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Indicateur de page (ex. 1/3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
                          borderRadius: BorderRadius.circular(10),
                          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                        ),
                        child: Text(
                          '${_selectedImageIndex + 1}/${_images.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 3. Section Titre & Description Remodelée (Comme demandé par l'utilisateur)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Marque & Catégorie
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.figmaActiveGold.withValues(alpha: 0.15)
                                  : AppColors.figmaBrown.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.brand,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B3820) : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '● En stock',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Nom du produit
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Prix
                      Text(
                        widget.price,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Note & Étoiles
                      Row(
                        children: [
                          for (int s = 0; s < 5; s++)
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.figmaActiveGold,
                              size: 17,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            '5',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(128 avis vérifiés)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Description remodelée avec "Voir plus"
                      Text(
                        'Un soin nourrissant qui hydrate, fortifie et redonne douceur et éclat aux cheveux. Idéal pour les cheveux secs et fragilisés. Sa formule riche en actifs réparateurs pénètre la fibre capillaire pour revitaliser la chevelure en profondeur.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4A4A4A),
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: _isDescriptionExpanded ? null : 3,
                        overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: const Text(
                          'Voir plus',
                          style: TextStyle(
                            color: AppColors.figmaActiveGold,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // ==============================================================
          // 4. BARRE D'ACTION FIXE AU BAS (Sélecteur Quantité + Ajouter au panier)
          // ==============================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Sélecteur de quantité [-]  1  [+]
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF3F5F7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E6EB),
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_quantity > 1) {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 18,
                                color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '$_quantity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : Colors.black,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Bouton Ajouter au panier
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(localPanierCountProvider.notifier).state += _quantity;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$_quantity x ${widget.title} ajouté au panier !'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: AppColors.figmaBrown,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.shopping_cart_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Ajouter au panier',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(bool isDark) {
    return SizedBox(
      height: 330,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _images[_selectedImageIndex],
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFF382319),
              alignment: Alignment.center,
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white38,
                size: 54,
              ),
            ),
          ),

          // Dégradé léger en haut pour les boutons
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
          ),

          // Boutons Retour et Favori
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bouton retour circulaire
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.figmaBrown.withValues(alpha: 0.85),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    // Bouton favori circulaire blanc
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _isFavorite
                              ? const Color(0xFFE53935)
                              : (isDark ? AppColors.darkTextPrimary : Colors.black87),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
