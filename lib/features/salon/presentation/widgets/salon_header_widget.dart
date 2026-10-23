import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class SalonHeaderWidget extends StatelessWidget {
  final String salonName;
  final String location;
  final String coverImage;
  final String logoImage;
  final String rating;
  final String reviewsCount;
  final String status;
  final String hours;
  final String initials;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onBackPressed;

  const SalonHeaderWidget({
    super.key,
    this.salonName = 'Beauty By Dika',
    this.location = 'Bamako, Kalaban',
    this.coverImage = 'assets/images/detail_img_0.jpg',
    this.logoImage = 'assets/images/detail_img_1.jpg',
    this.rating = '4.8',
    this.reviewsCount = '124 avis',
    this.status = 'Ouvert',
    this.hours = '08:00-20:00',
    this.initials = 'BD',
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onBackPressed,
  });

  Widget _buildImage(
    String? path, {
    required BoxFit fit,
    required Widget errorFallback,
  }) {
    if (path == null || path.trim().isEmpty) {
      return errorFallback;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (_, _, _) => errorFallback,
      );
    }
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (_, _, _) => errorFallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.heightPercent(0.32, min: 250.0, max: 320.0),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Image de couverture du salon
          _buildImage(
            coverImage,
            fit: BoxFit.cover,
            errorFallback: Container(
              color: const Color(0xFF382319),
              alignment: Alignment.center,
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),

          // 2. Dégradé sombre pour la lisibilité
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // 3. Boutons Retour et Favori en haut
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
                      onTap: onBackPressed,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.figmaBrown.withValues(alpha: 0.85),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    // Bouton favori circulaire
                    GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.figmaBrown.withValues(alpha: 0.85),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? const Color(0xFFE53935)
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Bloc d'informations au bas du header (Logo, Nom, Note, Ouvert)
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Logo circulaire avec bordure blanche
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildImage(
                      logoImage,
                      fit: BoxFit.cover,
                      errorFallback: Container(
                        color: const Color(0xFF2E1C15),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: AppColors.figmaActiveGold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Nom du salon + Note + Emplacement
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          salonName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.fontSize(17),
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.figmaActiveGold,
                            size: 15,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$rating ($reviewsCount)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.fontSize(12),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFFE53935), // Rouge exact Figma
                            size: 13,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.fontSize(11.5),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Badge Ouvert & Horaires
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.figmaBrown.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white24,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            status,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.fontSize(11),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hours,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: context.fontSize(10.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
