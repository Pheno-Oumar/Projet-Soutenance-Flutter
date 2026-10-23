import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../compte/presentation/providers/favoris_provider.dart';
import 'providers/salon_provider.dart';

class SalonItemData {
  final String name;
  final String imagePath;
  final String rating;
  final String reviews;
  final String location;
  final String slug;
  final String initials;

  const SalonItemData({
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.slug,
    required this.initials,
  });
}

class SalonListScreen extends ConsumerStatefulWidget {
  const SalonListScreen({super.key});

  @override
  ConsumerState<SalonListScreen> createState() => _SalonListScreenState();
}

class _SalonListScreenState extends ConsumerState<SalonListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedSalonIndex;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SalonItemData> _getFilteredSalons(List<dynamic> apiSalons) {
    final List<SalonItemData> baseSalons = apiSalons.map((s) {
      final image = (s.coverUrl != null && s.coverUrl.toString().isNotEmpty)
          ? s.coverUrl.toString()
          : (s.logoUrl != null && s.logoUrl.toString().isNotEmpty)
              ? s.logoUrl.toString()
              : 'assets/images/salons_img_0.jpg';

      final nomStr = s.nom.toString();
      final initials = nomStr.isNotEmpty
          ? (nomStr.trim().length >= 2
              ? nomStr.trim().substring(0, 2).toUpperCase()
              : nomStr.trim().toUpperCase())
          : 'SL';

      final note = (s.noteMoyenne != null && s.noteMoyenne > 0)
          ? (s.noteMoyenne as num).toDouble().toStringAsFixed(1)
          : '4.8';

      final avis = s.nombreAvis != null && s.nombreAvis > 0
          ? '${s.nombreAvis} avis'
          : 'Nouveau';

      return SalonItemData(
        name: nomStr,
        imagePath: image,
        rating: note,
        reviews: avis,
        location: s.adresse?.toString() ?? 'Dakar, Sénégal',
        slug: s.slug.toString(),
        initials: initials,
      );
    }).toList();

    if (_searchQuery.isEmpty) {
      return baseSalons;
    }
    final q = _searchQuery.toLowerCase();
    return baseSalons.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.location.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Données dynamiques du backend Spring Boot
    final apiState = ref.watch(salonsListProvider);
    final filteredSalons = _getFilteredSalons(apiState.salons);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==============================================================
          // 1. CHAMP TEXTFIELD DE RECHERCHE (Figma "Liste des salons.svg" y=145.5)
          // Immédiatement sous l'AppBar (10px d'espacement)
          // ==============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: SizedBox(
              height: 44,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                    ref.read(salonsListProvider.notifier).search(value.trim());
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                    hintText: 'Rechercher un salon, une ville...',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                      size: 21,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                              ref.read(salonsListProvider.notifier).search('');
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 19,
                              color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                            ),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.figmaActiveGold,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Indicateur de chargement discret si l'API actualise
            if (apiState.isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.figmaActiveGold,
                backgroundColor: Colors.transparent,
              ),

            // ==============================================================
            // 2. GRILLE 2 COLONNES DE SALONS (100% Column, Row, Container)
            // ==============================================================
            Expanded(
              child: filteredSalons.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 54,
                            color: context.adaptiveSubtextColor(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun salon trouvé pour "$_searchQuery"',
                            style: TextStyle(
                              fontSize: context.fontSize(14.5),
                              fontWeight: FontWeight.w600,
                              color: context.adaptiveSubtextColor(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.figmaActiveGold,
                      onRefresh: () =>
                          ref.read(salonsListProvider.notifier).chargerSalons(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: EdgeInsets.fromLTRB(
                            16, 4, 16, context.responsiveValue(compact: 85, standard: 90)),
                        child: Column(
                          children: [
                            for (int i = 0; i < filteredSalons.length; i += 2)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Colonne gauche
                                    Expanded(
                                      child: _buildSalonCard(
                                        salon: filteredSalons[i],
                                        index: i,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Colonne droite
                                    Expanded(
                                      child: i + 1 < filteredSalons.length
                                          ? _buildSalonCard(
                                              salon: filteredSalons[i + 1],
                                              index: i + 1,
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
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

  // ==============================================================
  // HELPER : Carte de Salon Figma (100% Container, Column, Row)
  // ==============================================================
  Widget _buildSalonCard({
    required SalonItemData salon,
    required int index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedSalonIndex == index;
    final isFavorite = ref.watch(favorisProvider).isSalonFav(salon.slug);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSalonIndex = index;
        });
        // Ouvre la page détails complète du salon (avec ses 5 onglets)
        context.push('/salons/${salon.slug}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: context.symmetricBorder(isSelected: isSelected),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. Image de l'intérieur du salon
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: AspectRatio(
                aspectRatio: 16 / 9.5,
                child: salon.imagePath.startsWith('http')
                    ? Image.network(
                        salon.imagePath,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/images/salons_img_0.jpg',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        salon.imagePath,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.figmaCardBg,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.storefront_rounded,
                            color: context.adaptiveSubtextColor(),
                            size: 32,
                          ),
                        ),
                      ),
              ),
            ),

            // B. Informations du salon
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du salon
                  Text(
                    salon.name,
                    style: TextStyle(
                      fontSize: context.fontSize(13),
                      fontWeight: FontWeight.w800,
                      color: context.adaptiveTextColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Ligne Avis & Étoiles
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.figmaActiveGold,
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        salon.rating,
                        style: TextStyle(
                          fontSize: context.fontSize(11),
                          fontWeight: FontWeight.w700,
                          color: context.adaptiveTextColor(),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '(${salon.reviews})',
                          style: TextStyle(
                            fontSize: context.fontSize(10),
                            color: context.adaptiveSubtextColor(),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Ligne Emplacement (📍 Sucette rouge) & Favori (Cœur)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sucette / Pin rouge 📍 + Ville, Quartier
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFE53935), // Rouge exact Figma
                              size: 13,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                salon.location,
                                style: TextStyle(
                                  fontSize: context.fontSize(10.5),
                                  color: context.adaptiveSubtextColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Cœur favori interactif
                      GestureDetector(
                        onTap: () {
                          ref.read(favorisProvider.notifier).toggleSalon(salon.slug);
                        },
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: isFavorite
                              ? const Color(0xFFE53935)
                              : context.adaptiveSubtextColor(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
