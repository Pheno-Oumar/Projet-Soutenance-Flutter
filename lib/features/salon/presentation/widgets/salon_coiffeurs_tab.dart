import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_names.dart';

class SalonCoiffeursTab extends StatelessWidget {
  const SalonCoiffeursTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coiffeurs = [
      {
        'name': 'Dika Traoré',
        'role': 'Fondatrice & Maître Coiffeuse',
        'specialty': 'Spécialiste Tresses sculptées, Knotless & Nattes',
        'rating': '4.9 (82 avis)',
        'experience': '8 ans d\'expérience',
        'image': 'assets/images/realisation_img_5.png',
        'available': true,
      },
      {
        'name': 'Fatou Sow',
        'role': 'Coiffeuse Experte',
        'specialty': 'Box Braids, Tissages & Perruques invisibles',
        'rating': '4.8 (64 avis)',
        'experience': '5 ans d\'expérience',
        'image': 'assets/images/realisation_img_7.png',
        'available': true,
      },
      {
        'name': 'Mariam Keita',
        'role': 'Coloriste & Traitement Capillaire',
        'specialty': 'Soins Kératine, Botox & Balayage doré',
        'rating': '4.9 (45 avis)',
        'experience': '6 ans d\'expérience',
        'image': 'assets/images/realisation_img_3.png',
        'available': false,
      },
      {
        'name': 'Ibrahim Diallo',
        'role': 'Barbier Professionnel',
        'specialty': 'Coupes homme, Dégradés américains & Barbe prestige',
        'rating': '4.7 (38 avis)',
        'experience': '4 ans d\'expérience',
        'image': 'assets/images/service_img_2.jpg',
        'available': true,
      },
    ];

    return Column(
      children: coiffeurs.map((c) {
        final isAvailable = c['available'] as bool;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
                width: 0.9,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo du coiffeur avec badge de disponibilité
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        c['image'] as String,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 72,
                          height: 72,
                          color: const Color(0xFF2E1C15),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white70,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAvailable
                              ? const Color(0xFF2E7D32)
                              : Colors.black38,
                          border: Border.all(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Informations du coiffeur
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              c['name'] as String,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : AppColors.figmaInputBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.figmaActiveGold,
                                  size: 13,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  c['rating'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c['role'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        c['specialty'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Bouton de réservation avec ce coiffeur
                      InkWell(
                        onTap: () {
                          context.push(RouteNames.mesRendezVous);
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Prendre rendez-vous',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
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
        );
      }).toList(),
    );
  }
}
