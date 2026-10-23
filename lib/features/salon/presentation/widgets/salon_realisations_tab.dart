import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_names.dart';
import '../../data/models/realisation_salon_model.dart';
import '../providers/salon_provider.dart';

class SalonRealisationsTab extends ConsumerWidget {
  final String slugSalon;
  final String salonName;
  final String initials;

  const SalonRealisationsTab({
    super.key,
    this.slugSalon = 'beauty-by-dika',
    this.salonName = 'Beauty By Dika',
    this.initials = 'BD',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realisationsAsync = ref.watch(salonRealisationsProvider(slugSalon));

    return realisationsAsync.when(
      loading: () => _buildLoadingGrid(),
      error: (_, _) => _buildEmptyGrid(context),
      data: (realisations) {
        if (realisations.isEmpty) {
          return _buildEmptyGrid(context);
        }

        return Column(
          children: [
            for (int i = 0; i < realisations.length; i += 3)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(child: _buildDynamicCard(context, realisations[i], i)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: i + 1 < realisations.length
                          ? _buildDynamicCard(context, realisations[i + 1], i + 1)
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: i + 2 < realisations.length
                          ? _buildDynamicCard(context, realisations[i + 2], i + 2)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDynamicCard(
    BuildContext context,
    RealisationSalonModel item,
    int index,
  ) {
    final videoUrl = item.urlVideo;
    final isNetwork = videoUrl != null && videoUrl.startsWith('http');
    final viewsFormatted = item.totalVues >= 1000
        ? '${(item.totalVues / 1000).toStringAsFixed(1).replaceAll('.', ',')}K'
        : '${item.totalVues}';

    return GestureDetector(
      onTap: () {
        context.push(
          '${RouteNames.lireRealisation}?index=$index&salon=${Uri.encodeComponent(salonName)}&initials=${Uri.encodeComponent(initials)}&slug=${Uri.encodeComponent(slugSalon)}',
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 145,
          color: Colors.black12,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isNetwork)
                Image.network(
                  videoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildPlaceholder(),
                )
              else
                Image.asset(
                  videoUrl != null && videoUrl.isNotEmpty
                      ? videoUrl
                      : 'assets/images/realisation_img_${(index % 9) + 1}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildPlaceholder(),
                ),

              // Voile dégradé
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // Durée indicative en haut à droite
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    '0:35',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Vues réelles en bas à gauche
              Positioned(
                bottom: 6,
                left: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      viewsFormatted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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

  Widget _buildEmptyGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
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
              Icons.photo_library_outlined,
              color: AppColors.figmaActiveGold,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Aucune réalisation publiée',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Les coiffures et vidéos réalisées par ce salon apparaîtront ici.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF2E1C15),
      alignment: Alignment.center,
      child: const Icon(
        Icons.play_circle_fill_rounded,
        color: Colors.white54,
        size: 28,
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Column(
      children: List.generate(2, (r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: List.generate(3, (c) {
              return Expanded(
                child: Container(
                  height: 145,
                  margin: EdgeInsets.only(right: c < 2 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
