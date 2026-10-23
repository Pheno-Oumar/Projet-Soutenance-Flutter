import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routing/route_names.dart';
import '../../rendezvous/data/models/rendezvous_panier_model.dart';
import '../../rendezvous/presentation/providers/rendezvous_panier_provider.dart';

class VarianteDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String price;
  final String image;
  final String salonName;
  final int? varianteId;
  final int? serviceId;
  final String? slugSalon;
  final int? dureeMinutes;
  final String? description;

  const VarianteDetailScreen({
    super.key,
    this.title = 'Tresses africaine',
    this.price = '5 000 FCFA',
    this.image = 'assets/images/details_d_une_variante_img_0.png',
    this.salonName = 'Beauty By Dika',
    this.varianteId,
    this.serviceId,
    this.slugSalon,
    this.dureeMinutes,
    this.description,
  });

  @override
  ConsumerState<VarianteDetailScreen> createState() => _VarianteDetailScreenState();
}

class _VarianteDetailScreenState extends ConsumerState<VarianteDetailScreen> {
  int _selectedImageIndex = 0;
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;

  late final List<String> _images;

  @override
  void initState() {
    super.initState();
    final trimmed = widget.image.trim();
    _images = trimmed.isNotEmpty ? [trimmed] : ['assets/images/details_d_une_variante_img_0.png'];
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: Stack(
        children: [
          // ==============================================================
          // CONTENU DÉFILANT (Hero + Miniatures + Infos remodelées + Carte)
          // ==============================================================
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Grande photo principale (Hero)
                _buildHeroImage(isDark),

                if (_images.length > 1) ...[
                  const SizedBox(height: 14),

                  // 2. Ligne de miniatures & indicateur
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
                                width: context.responsiveValue<double>(smallPhone: 50, standard: 58, tablet: 72),
                                height: context.responsiveValue<double>(smallPhone: 50, standard: 58, tablet: 72),
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
                                  child: _buildThumbImage(_images[i], isDark),
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
                ],

                const SizedBox(height: 18),

                // 3. Section Titre & Description Remodelée (Comme demandé par l'utilisateur)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge de catégorie & Salon
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
                              widget.salonName,
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
                              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFEFE8DF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Coiffure protectrice',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Nom de la variante
                      Text(
                        widget.title,
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
                          widget.price,
                          style: TextStyle(
                            fontSize: context.fontSize(20),
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
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
                            '(128 avis vérifiés)',
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
                        (widget.description != null && widget.description!.trim().isNotEmpty)
                            ? widget.description!
                            : 'Des tresses soignées et élégantes, réalisées avec professionnalisme pour un style durable et confortable. Adaptées à tous types de cheveux avec des finitions impeccables et un confort optimal pour le cuir chevelu.',
                        style: TextStyle(
                          fontSize: context.fontSize(13),
                          color: context.adaptiveSubtextColor(),
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

                const SizedBox(height: 20),

                // 4. Carte d'informations pratiques (Durée 1h30 + Au salon)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFD3C8BE).withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: context.symmetricBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Durée
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.access_time_filled_rounded,
                                color: AppColors.figmaActiveGold,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Durée',
                                  style: TextStyle(
                                    fontSize: context.fontSize(11),
                                    color: context.adaptiveSubtextColor(),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '1h 30',
                                  style: TextStyle(
                                    fontSize: context.fontSize(13.5),
                                    fontWeight: FontWeight.w800,
                                    color: context.adaptiveTextColor(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Container(
                          width: 1,
                          height: 34,
                          color: isDark ? AppColors.darkBorder : Colors.black12,
                        ),

                        // Lieu
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFFE53935),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Salon',
                                  style: TextStyle(
                                    fontSize: context.fontSize(11),
                                    color: context.adaptiveSubtextColor(),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Au salon',
                                  style: TextStyle(
                                    fontSize: context.fontSize(13.5),
                                    fontWeight: FontWeight.w800,
                                    color: context.adaptiveTextColor(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // ==============================================================
          // 5. BOUTON D'ACTION FIXE AU BAS (Ajouter au rendez-vous)
          // ==============================================================
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
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final cleanedPrice = widget.price.replaceAll(RegExp(r'[^0-9.]'), '');
                      final parsedPrice = double.tryParse(cleanedPrice) ?? 5000.0;
                      final effectiveVarianteId = widget.varianteId ?? (widget.title.hashCode.abs() % 10000 + 1);

                      ref.read(rendezvousPanierProvider.notifier).ajouterPrestation(
                            slugSalon: widget.slugSalon ?? 'beauty-by-dika',
                            salonNom: widget.salonName,
                            prestation: LignePrestationPanierModel(
                              varianteId: effectiveVarianteId,
                              serviceId: widget.serviceId,
                              serviceNom: widget.title,
                              varianteNom: widget.title,
                              prix: parsedPrice,
                              dureeMinutes: widget.dureeMinutes ?? 45,
                              imageUrl: widget.image,
                            ),
                          );

                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.title} ajouté au panier rendez-vous !'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppColors.figmaBrown,
                          action: SnackBarAction(
                            label: 'Voir',
                            textColor: AppColors.figmaActiveGold,
                            onPressed: () => context.push(RouteNames.panierRendezVous),
                          ),
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
                        Icon(Icons.calendar_today_rounded, size: 18),
                        SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Ajouter au rendez-vous',
                              style: TextStyle(
                                fontSize: 14.5,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(bool isDark) {
    final heroHeight = context.heightPercent(0.38, min: 240.0, max: 420.0);
    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildThumbImage(_images[_selectedImageIndex], isDark),

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
