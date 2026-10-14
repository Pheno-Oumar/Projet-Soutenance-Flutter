import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/route_names.dart';

class SalonRealisationsTab extends StatelessWidget {
  final String salonName;
  final String initials;

  const SalonRealisationsTab({
    super.key,
    this.salonName = 'Beauty By Dika',
    this.initials = 'BD',
  });

  @override
  Widget build(BuildContext context) {
    final realisations = [
      {'image': 'assets/images/realisation_img_1.png', 'time': '0:32', 'views': '12,4K'},
      {'image': 'assets/images/realisation_img_2.png', 'time': '0:45', 'views': '8,7K'},
      {'image': 'assets/images/realisation_img_3.png', 'time': '0:37', 'views': '15,2K'},
      {'image': 'assets/images/realisation_img_4.png', 'time': '0:28', 'views': '9,6K'},
      {'image': 'assets/images/realisation_img_5.png', 'time': '0:41', 'views': '11,9K'},
      {'image': 'assets/images/realisation_img_6.png', 'time': '0:33', 'views': '7,4K'},
      {'image': 'assets/images/realisation_img_7.png', 'time': '0:52', 'views': '18,3K'},
      {'image': 'assets/images/realisation_img_8.png', 'time': '0:46', 'views': '10,7K'},
      {'image': 'assets/images/realisation_img_9.png', 'time': '0:29', 'views': '6,8K'},
    ];

    return Column(
      children: [
        for (int i = 0; i < realisations.length; i += 3)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(child: _buildRealisationCard(context, realisations[i], i)),
                const SizedBox(width: 8),
                Expanded(
                  child: i + 1 < realisations.length
                      ? _buildRealisationCard(context, realisations[i + 1], i + 1)
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: i + 2 < realisations.length
                      ? _buildRealisationCard(context, realisations[i + 2], i + 2)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRealisationCard(
    BuildContext context,
    Map<String, String> item,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        context.push(
          '${RouteNames.lireRealisation}?index=$index&salon=${Uri.encodeComponent(salonName)}&initials=${Uri.encodeComponent(initials)}',
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
              Image.asset(
                item['image']!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFF2E1C15),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white54,
                    size: 28,
                  ),
                ),
              ),
              // Voile noir transparent / dégradé pour que les écritures (vues, durée) soient bien visibles
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
              // Durée de la vidéo en haut à droite
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    item['time']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Vues de la vidéo en bas à gauche
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
                      item['views']!,
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
}
