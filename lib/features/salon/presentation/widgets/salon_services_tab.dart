import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_names.dart';

class SalonServicesTab extends StatelessWidget {
  const SalonServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final services = [
      {
        'title': 'Tresses collées',
        'category': 'Coiffure',
        'price': '5000 FCFA',
        'image': 'assets/images/service_img_1.jpg',
      },
      {
        'title': 'Coupe homme',
        'category': 'Coiffure & Barbe',
        'price': '5000 FCFA',
        'image': 'assets/images/service_img_2.jpg',
      },
      {
        'title': 'Brushing',
        'category': 'Coiffure',
        'price': '5000 FCFA',
        'image': 'assets/images/service_img_3.jpg',
      },
      {
        'title': 'Manucure & pédicure',
        'category': 'Soins esthétiques',
        'price': '5000 FCFA',
        'image': 'assets/images/service_img_5.jpg',
      },
      {
        'title': 'Soins profonds kératine',
        'category': 'Soin réparateur',
        'price': '15 000 FCFA',
        'image': 'assets/images/service_img_4.jpg',
      },
    ];

    return Column(
      children: services.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              context.push(
                '${RouteNames.serviceVariantes}?title=${Uri.encodeComponent(s['title']!)}',
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
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
                      s['image']!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['title']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          s['category']!,
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
                        s['price']!,
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
      }).toList(),
    );
  }
}
