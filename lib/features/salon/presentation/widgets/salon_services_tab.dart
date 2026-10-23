import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../routing/route_names.dart';
import '../providers/salon_provider.dart';

class SalonServicesTab extends ConsumerWidget {
  final String slugSalon;
  final String salonNom;

  const SalonServicesTab({
    super.key,
    this.slugSalon = 'beauty-by-dika',
    this.salonNom = 'Beauty By Dika',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final servicesAsync = ref.watch(salonServicesProvider(slugSalon));

    return servicesAsync.when(
      loading: () => _buildLoadingState(context, isDark),
      error: (_, _) => _buildEmptyState(context, isDark),
      data: (apiServices) {
        if (apiServices.isEmpty) {
          return _buildEmptyState(context, isDark);
        }

        return Column(
          children: apiServices.map((service) {
            final minPrice = service.minPrix > 0
                ? '${service.minPrix.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA'
                : 'Sur devis';

            final photoUrl = service.imageUrl;
            final isNetworkImage =
                photoUrl != null && photoUrl.startsWith('http');

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  final encodedTitle = Uri.encodeComponent(service.nom);
                  final encodedSlug = Uri.encodeComponent(slugSalon);
                  final encodedSalon = Uri.encodeComponent(salonNom);
                  final encodedDesc =
                      Uri.encodeComponent(service.description ?? '');

                  context.push(
                    '${RouteNames.serviceVariantes}?serviceId=${service.id}&title=$encodedTitle&slug=$encodedSlug&salon=$encodedSalon&desc=$encodedDesc',
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: context.symmetricBorder(),
                  ),
                  child: Row(
                    children: [
                      // Photo du service (Network Cloudinary ou Fallback Asset)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: isNetworkImage
                            ? Image.network(
                                photoUrl,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Image.asset(
                                  'assets/images/service_img_1.jpg',
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/service_img_1.jpg',
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 12),

                      // Nom du service et description/catégorie
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.nom,
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
                              service.description ??
                                  '${service.variantes.length} styles disponibles',
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

                      // Prix "À partir de"
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'À partir de',
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
                              minPrice,
                              style: TextStyle(
                                fontSize: context.fontSize(13),
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.figmaActiveGold
                                    : AppColors.figmaBrown,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
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
          }).toList(),
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isDark) {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 84,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
              borderRadius: BorderRadius.circular(12),
              border: context.symmetricBorder(),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.black12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.black12,
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
              Icons.content_cut_rounded,
              color: AppColors.figmaActiveGold,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Aucune prestation répertoriée',
            style: TextStyle(
              fontSize: context.fontSize(15),
              fontWeight: FontWeight.w800,
              color: context.adaptiveTextColor(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ce salon n\'a pas encore publié de catalogue de prestations.',
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
}
