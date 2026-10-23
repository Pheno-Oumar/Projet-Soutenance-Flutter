import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routing/route_names.dart';
import '../../panier/presentation/providers/panier_provider.dart';
import 'providers/salon_provider.dart';

class ProduitDetailScreen extends ConsumerStatefulWidget {
  final int? produitId;
  final String? slugSalon;
  final String? salonNom;
  final String title;
  final String price;
  final String image;
  final String brand;
  final String? description;
  final int? stock;

  const ProduitDetailScreen({
    super.key,
    this.produitId,
    this.slugSalon,
    this.salonNom,
    this.title = 'Oreal - Soin Capillaire',
    this.price = '5 000 FCFA',
    this.image = 'assets/images/details_d_un_produit_img_0.png',
    this.brand = 'L\'Oréal Professionnel',
    this.description,
    this.stock,
  });

  @override
  ConsumerState<ProduitDetailScreen> createState() => _ProduitDetailScreenState();
}

class _ProduitDetailScreenState extends ConsumerState<ProduitDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;

  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _initImages();
  }

  void _initImages() {
    if (widget.image.trim().isNotEmpty) {
      _images = [widget.image.trim()];
    } else {
      _images = [
        'assets/images/details_d_un_produit_img_0.png',
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Si slug et produitId sont fournis, interroge le backend pour les données complètes
    final slug = widget.slugSalon;
    final id = widget.produitId;

    String displayTitle = widget.title;
    String displayPrice = widget.price;
    String displayBrand = widget.brand;
    String displayDesc = widget.description != null && widget.description!.isNotEmpty
        ? widget.description!
        : 'Un soin nourrissant qui hydrate, fortifie et redonne douceur et éclat aux cheveux. Idéal pour les cheveux secs et fragilisés. Sa formule riche en actifs réparateurs pénètre la fibre capillaire pour revitaliser la chevelure en profondeur.';
    int displayStock = widget.stock ?? 10;
    bool isRupture = displayStock <= 0;

    if (slug != null && slug.isNotEmpty && id != null) {
      final detailAsync = ref.watch(salonProduitDetailProvider((slug: slug, produitId: id)));
      detailAsync.whenData((prod) {
        displayTitle = prod.nom;
        displayPrice =
            '${prod.prixVente.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA';
        if (prod.categorieNom != null) displayBrand = prod.categorieNom!;
        if (prod.description != null && prod.description!.isNotEmpty) {
          displayDesc = prod.description!;
        }
        displayStock = prod.quantiteEnStock;
        isRupture = prod.isEnRupture;

        if (prod.imagesUrls.isNotEmpty && _images.length <= 1) {
          _images = prod.imagesUrls;
        } else if (prod.imageUrl != null && _images.length <= 1) {
          _images = [prod.imageUrl!];
        }
      });
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: Stack(
        children: [
          // CONTENU DÉFILANT (Hero + Miniatures + Infos + Description)
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Grande photo principale (Hero)
                _buildHeroImage(isDark),

                const SizedBox(height: 14),

                // 2. Ligne de miniatures & indicateur
                if (_images.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        for (int i = 0; i < 4 && i < _images.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImageIndex = i;
                                });
                              },
                              child: Container(
                                width: context.responsiveValue<double>(
                                    smallPhone: 50, standard: 58, tablet: 72),
                                height: context.responsiveValue<double>(
                                    smallPhone: 50, standard: 58, tablet: 72),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedImageIndex == i
                                        ? AppColors.figmaActiveGold
                                        : (isDark
                                            ? AppColors.darkBorder
                                            : const Color(0xFFE0E4EB)),
                                    width: _selectedImageIndex == i ? 2.0 : 1.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _buildThumbImage(_images[i], isDark),
                                ),
                              ),
                            ),
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
                            borderRadius: BorderRadius.circular(10),
                            border: context.symmetricBorder(),
                          ),
                          child: Text(
                            '${_selectedImageIndex + 1}/${_images.length}',
                            style: TextStyle(
                              fontSize: context.fontSize(12),
                              fontWeight: FontWeight.w700,
                              color: context.adaptiveSubtextColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 18),

                // 3. Section Titre & Description Remodelée
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Marque & Catégorie + Stock
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
                              displayBrand,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.figmaActiveGold
                                    : AppColors.figmaBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isRupture
                                  ? (isDark
                                      ? const Color(0xFF3E1E1E)
                                      : const Color(0xFFFFEBEE))
                                  : (isDark
                                      ? const Color(0xFF1B3820)
                                      : const Color(0xFFE8F5E9)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isRupture
                                  ? '● Rupture de stock'
                                  : '● En stock ($displayStock)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isRupture
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Nom du produit
                      Text(
                        displayTitle,
                        style: TextStyle(
                          fontSize: context.fontSize(22),
                          fontWeight: FontWeight.w800,
                          color: context.adaptiveTextColor(),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Prix
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          displayPrice,
                          style: TextStyle(
                            fontSize: context.fontSize(20),
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.figmaActiveGold
                                : AppColors.figmaBrown,
                          ),
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
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w800,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(Avis vérifiés)',
                            style: TextStyle(
                              fontSize: context.fontSize(12),
                              color: context.adaptiveSubtextColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Description remodelée avec "Voir plus"
                      Text(
                        displayDesc,
                        style: TextStyle(
                          fontSize: context.fontSize(13),
                          color: context.adaptiveSubtextColor(),
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: _isDescriptionExpanded ? null : 3,
                        overflow:
                            _isDescriptionExpanded ? null : TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: Text(
                          _isDescriptionExpanded ? 'Voir moins' : 'Voir plus',
                          style: const TextStyle(
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

          // BARRE D'ACTION FIXE AU BAS (Sélecteur Quantité + Ajouter au panier)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                    width: 1.0,
                  ),
                ),
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
                    // Sélecteur de quantité
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.figmaInputBg,
                        borderRadius: BorderRadius.circular(14),
                        border: context.symmetricBorder(),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: isRupture
                                ? null
                                : () {
                                    if (_quantity > 1) {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 18,
                                color: _quantity > 1 && !isRupture
                                    ? (isDark
                                        ? AppColors.darkTextPrimary
                                        : Colors.black87)
                                    : (isDark
                                        ? Colors.white24
                                        : Colors.black26),
                              ),
                            ),
                          ),
                          Text(
                            '$_quantity',
                            style: TextStyle(
                              fontSize: context.fontSize(15),
                              fontWeight: FontWeight.w800,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                          GestureDetector(
                            onTap: isRupture
                                ? null
                                : () {
                                    if (_quantity < displayStock) {
                                      setState(() {
                                        _quantity++;
                                      });
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: !isRupture && _quantity < displayStock
                                    ? (isDark
                                        ? AppColors.darkTextPrimary
                                        : Colors.black87)
                                    : (isDark
                                        ? Colors.white24
                                        : Colors.black26),
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
                          onPressed: isRupture
                              ? null
                              : () {
                                  final cleanPrice = displayPrice
                                      .replaceAll(RegExp(r'[^0-9]'), '');
                                  final prixNumerique =
                                      double.tryParse(cleanPrice) ?? 5000.0;
                                  final effectiveSlug = (widget.slugSalon != null &&
                                          widget.slugSalon!.isNotEmpty)
                                      ? widget.slugSalon!
                                      : 'beauty-by-dika';
                                  final effectiveSalonNom = (widget.salonNom != null &&
                                          widget.salonNom!.isNotEmpty)
                                      ? widget.salonNom!
                                      : 'Beauty By Dika';
                                  final effectiveProduitId =
                                      widget.produitId ?? 1;

                                  ref.read(panierStateProvider.notifier).ajouterArticle(
                                    slugSalon: effectiveSlug,
                                    salonNom: effectiveSalonNom,
                                    produitId: effectiveProduitId,
                                    produitNom: displayTitle,
                                    prixUnitaire: prixNumerique,
                                    quantite: _quantity,
                                    imageUrl: _images.isNotEmpty
                                        ? _images[_selectedImageIndex]
                                        : widget.image,
                                  );

                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '$_quantity x $displayTitle ajouté au panier ($effectiveSalonNom) !'),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: AppColors.figmaBrown,
                                      action: SnackBarAction(
                                        label: 'Voir',
                                        textColor: AppColors.figmaActiveGold,
                                        onPressed: () => context.push(RouteNames.panier),
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.figmaActiveGold
                                : AppColors.figmaBrown,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade400,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart_outlined, size: 18),
                              const SizedBox(width: 8),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    isRupture ? 'Article épuisé' : 'Ajouter au panier',
                                    style: TextStyle(
                                      fontSize: context.fontSize(14),
                                      fontWeight: FontWeight.w700,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(bool isDark) {
    final heroHeight = context.heightPercent(0.38, min: 240.0, max: 420.0);
    final currentImg = _images.isNotEmpty && _selectedImageIndex < _images.length
        ? _images[_selectedImageIndex]
        : widget.image;
    final isNetwork = currentImg.startsWith('http');

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isNetwork)
            Image.network(
              currentImg,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildHeroPlaceholder(),
            )
          else
            Image.asset(
              currentImg.isNotEmpty
                  ? currentImg
                  : 'assets/images/details_d_un_produit_img_0.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildHeroPlaceholder(),
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

  Widget _buildThumbImage(String path, bool isDark) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF5EFE6),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF5EFE6),
      ),
    );
  }

  Widget _buildHeroPlaceholder() {
    return Container(
      color: const Color(0xFF382319),
      alignment: Alignment.center,
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.white38,
        size: 54,
      ),
    );
  }
}
