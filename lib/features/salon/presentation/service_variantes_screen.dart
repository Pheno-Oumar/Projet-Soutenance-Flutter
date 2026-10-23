import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routing/route_names.dart';
import '../../compte/presentation/providers/favoris_provider.dart';
import 'providers/salon_provider.dart';

class ServiceVariantesScreen extends ConsumerStatefulWidget {
  final String serviceTitle;
  final String serviceDescription;
  final String salonName;
  final String slugSalon;
  final int? serviceId;

  const ServiceVariantesScreen({
    super.key,
    this.serviceTitle = 'Tresses collées',
    this.serviceDescription =
        'La tresse africaine est une coiffure traditionnelle où les cheveux sont tressés serrés et près du cuir chevelu en intégrant progressivement de nouvelles mèches.',
    this.salonName = 'Beauty By Dika',
    this.slugSalon = 'beauty-by-dika',
    this.serviceId,
  });

  @override
  ConsumerState<ServiceVariantesScreen> createState() =>
      _ServiceVariantesScreenState();
}

class _ServiceVariantesScreenState
    extends ConsumerState<ServiceVariantesScreen> {
  final Set<int> _favoriteIndexes = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Récupérer les services dynamiques du salon pour en extraire les variantes réelles
    final servicesAsync = ref.watch(salonServicesProvider(widget.slugSalon));
    List<Map<String, dynamic>> variantesAffichees = [];

    if (widget.serviceId != null && servicesAsync.hasValue) {
      final matched = servicesAsync.value!.where((s) => s.id == widget.serviceId);
      if (matched.isNotEmpty) {
        final realVariantes = matched.first.variantes;
        variantesAffichees = realVariantes.map((v) {
          final formattedPrice =
              '${v.prix.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA';
          final photo = v.mainImage ?? 'assets/images/les_variantes_d_un_service_img_0.png';
          return {
            'id': v.id,
            'name': v.nom,
            'price': formattedPrice,
            'image': photo,
            'description': v.description ?? widget.serviceDescription,
            'duree': v.dureeMinutes,
          };
        }).toList();
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Service',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            16, 14, 16, context.responsiveValue(compact: 70, standard: 80)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================================================
            // 1. SECTION TITRE & DESCRIPTION DU SERVICE (Remodelée & Stylisée)
            // ==============================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
                borderRadius: BorderRadius.circular(14),
                border: context.symmetricBorder(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.serviceTitle,
                          style: TextStyle(
                            fontSize: context.fontSize(19),
                            fontWeight: FontWeight.w800,
                            color: context.adaptiveTextColor(),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.figmaActiveGold.withValues(alpha: 0.15)
                              : AppColors.figmaBrown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${variantesAffichees.length} styles',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.figmaActiveGold
                                : AppColors.figmaBrown,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.serviceDescription,
                    style: TextStyle(
                      fontSize: context.fontSize(12.5),
                      color: context.adaptiveSubtextColor(),
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==============================================================
            // 2. GRILLE 2 COLONNES DES VARIANTES (100% Column / Row / Container)
            // ==============================================================
            if (variantesAffichees.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.figmaCardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: context.symmetricBorder(),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.content_cut_rounded,
                      size: 36,
                      color: AppColors.figmaActiveGold.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune variante disponible pour cette prestation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: context.adaptiveSubtextColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              for (int i = 0; i < variantesAffichees.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                          child: _buildVarianteCard(
                              variantesAffichees[i], i)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: i + 1 < variantesAffichees.length
                            ? _buildVarianteCard(
                                variantesAffichees[i + 1], i + 1)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVarianteCard(Map<String, dynamic> item, int index) {
    final imagePath = item['image'].toString();
    final isNetwork = imagePath.startsWith('http');
    final varianteId = item['id'] as int?;
    final isFav = varianteId != null
        ? ref.watch(favorisProvider).isCoiffureFav(varianteId)
        : _favoriteIndexes.contains(index);

    return GestureDetector(
      onTap: () {
        final title = Uri.encodeComponent(item['name'].toString());
        final price = Uri.encodeComponent(item['price'].toString());
        final image = Uri.encodeComponent(imagePath);
        final salon = Uri.encodeComponent(widget.salonName);
        final slug = Uri.encodeComponent(widget.slugSalon);
        final desc = Uri.encodeComponent(item['description']?.toString() ?? '');
        final duree = item['duree']?.toString() ?? '30';
        final vId = item['id']?.toString() ?? '';
        final sId = widget.serviceId?.toString() ?? '';

        context.push(
          '${RouteNames.varianteDetail}?title=$title&price=$price&image=$image&salon=$salon&slug=$slug&varianteId=$vId&serviceId=$sId&duree=$duree&description=$desc',
        );
      },
      child: Container(
        height: 185,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF2E1C15),
          border: context.symmetricBorder(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo de la variante
              isNetwork
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset(
                        'assets/images/les_variantes_d_un_service_img_0.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFF382319),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.face_retouching_natural_rounded,
                          color: Colors.white38,
                          size: 32,
                        ),
                      ),
                    ),

              // Voile noir transparent dégradé pour la lisibilité
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // Cœur favori en haut à droite
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    if (varianteId != null) {
                      ref
                          .read(favorisProvider.notifier)
                          .toggleCoiffure(varianteId);
                    } else {
                      setState(() {
                        if (_favoriteIndexes.contains(index)) {
                          _favoriteIndexes.remove(index);
                        } else {
                          _favoriteIndexes.add(index);
                        }
                      });
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? const Color(0xFFE53935) : Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ),

              // Nom & Prix au bas de la carte
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Nom du style
                    Expanded(
                      child: Text(
                        item['name'].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.fontSize(12.5),
                          fontWeight: FontWeight.w700,
                          shadows: const [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Badge de prix avec bordure dorée Figma (Stroke en or)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.figmaActiveGold,
                          width: 1.1,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item['price'].toString(),
                          style: TextStyle(
                            color: AppColors.figmaActiveGold,
                            fontSize: context.fontSize(10),
                            fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
