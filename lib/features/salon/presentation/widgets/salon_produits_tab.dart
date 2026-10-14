import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_names.dart';

class SalonProduitsTab extends StatelessWidget {
  const SalonProduitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = [
      {
        'title': 'Lavage',
        'subtitle': 'Coupe taille de barbe...',
        'price': '5000F',
        'image': 'assets/images/produit_cat_img_1.jpg',
      },
      {
        'title': 'Coupe homme',
        'subtitle': 'Coupe taille de barbe...',
        'price': '3000F',
        'image': 'assets/images/produit_cat_img_2.jpg',
      },
      {
        'title': 'Brushing',
        'subtitle': 'Coiffure & Lissage',
        'price': '6000F',
        'image': 'assets/images/produit_cat_img_3.jpg',
      },
      {
        'title': 'Manucure & pédicure',
        'subtitle': 'Soins de main et des pieds',
        'price': '4000F',
        'image': 'assets/images/produit_cat_img_4.jpg',
      },
      {
        'title': 'Soins visage',
        'subtitle': 'Soin esthétique & Gommage',
        'price': '8000F',
        'image': 'assets/images/produit_cat_img_5.jpg',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...categories.map((c) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                context.push(
                  '${RouteNames.categorieProduits}?title=${Uri.encodeComponent(c['title']!)}',
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        c['image']!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 64,
                          height: 64,
                          color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0EBE1),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: isDark ? AppColors.darkTextSecondary : Colors.black38,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['title']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            c['subtitle']!,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'À partir de',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c['price']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.figmaActiveGold : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? AppColors.darkTextSecondary : Colors.black38,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
