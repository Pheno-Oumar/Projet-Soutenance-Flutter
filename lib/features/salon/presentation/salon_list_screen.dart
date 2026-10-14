import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
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
  final Set<int> _favoriteSalons = {};

  // Salons officiels extraits exactement de la maquette Figma "Liste des salons.svg"
  final List<SalonItemData> _figmaSalons = const [
    SalonItemData(
      name: 'Beauty By Dika',
      imagePath: 'assets/images/salons_img_0.jpg',
      rating: '4.8',
      reviews: '124 avis',
      location: 'Bamako, Kalaban',
      slug: 'beauty-by-dika',
      initials: 'BD',
    ),
    SalonItemData(
      name: 'Mathy hair',
      imagePath: 'assets/images/salons_img_1.jpg',
      rating: '4.8',
      reviews: '124 avis',
      location: 'Bamako, Kalaban',
      slug: 'mathy-hair',
      initials: 'MH',
    ),
    SalonItemData(
      name: 'Hair Prestige',
      imagePath: 'assets/images/salons_img_2.jpg',
      rating: '4.8',
      reviews: '124 avis',
      location: 'Bamako, Kalaban',
      slug: 'hair-prestige',
      initials: 'HP',
    ),
    SalonItemData(
      name: "L'Atelier des Cheveux",
      imagePath: 'assets/images/salons_img_3.jpg',
      rating: '4.8',
      reviews: '124 avis',
      location: 'Bamako, Kalaban',
      slug: 'latelier-des-cheveux',
      initials: 'AC',
    ),
    SalonItemData(
      name: 'Adja Beauty',
      imagePath: 'assets/images/salons_img_4.jpg',
      rating: '4.8',
      reviews: '124 avis',
      location: 'Bamako, Kalaban',
      slug: 'adja-beauty',
      initials: 'AB',
    ),
    SalonItemData(
      name: 'Safoura Coiffure',
      imagePath: 'assets/images/salons_img_5.jpg',
      rating: '4.8',
      reviews: '124 avis',
      location: 'Bamako, Kalaban',
      slug: 'safoura-coiffure',
      initials: 'SC',
    ),
    SalonItemData(
      name: "Kady's Hair Lounge",
      imagePath: 'assets/images/salons_img_6.png',
      rating: '4.9',
      reviews: '156 avis',
      location: 'Bamako, ACI 2000',
      slug: 'kadys-hair',
      initials: 'KH',
    ),
    SalonItemData(
      name: 'Glow Afro Beauty',
      imagePath: 'assets/images/salons_img_0.jpg',
      rating: '4.7',
      reviews: '98 avis',
      location: 'Bamako, Badalabougou',
      slug: 'glow-afro',
      initials: 'GA',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SalonItemData> _getFilteredSalons() {
    if (_searchQuery.isEmpty) {
      return _figmaSalons;
    }
    final q = _searchQuery.toLowerCase();
    return _figmaSalons.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.location.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Si l'API Spring Boot renvoie des données dynamiques, on peut les synchroniser
    final apiState = ref.watch(salonsListProvider);
    final filteredSalons = _getFilteredSalons();

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
                        color: isDark ? AppColors.darkBorder : const Color(0xFFE0E4EB),
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFE0E4EB),
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
                            color: isDark ? AppColors.darkTextSecondary : Colors.black26,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun salon trouvé pour "$_searchQuery"',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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
    final isFavorite = _favoriteSalons.contains(index);

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
          // La bordure dorée apparaît au clic de l'utilisateur !
          border: Border.all(
            color: isSelected
                ? AppColors.figmaActiveGold
                : (isDark ? AppColors.darkBorder : const Color(0xFFE0E4EB)),
            width: isSelected ? 1.6 : 0.9,
          ),
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
              child: Image.asset(
                salon.imagePath,
                height: 95,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 95,
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.figmaCardBg,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.storefront_rounded,
                    color: isDark ? AppColors.darkTextSecondary : Colors.black38,
                    size: 32,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : Colors.black,
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
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '(${salon.reviews})',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.darkTextSecondary : Colors.black45,
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
                                  fontSize: 10.5,
                                  color: isDark ? AppColors.darkTextSecondary : Colors.black54,
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
                          setState(() {
                            if (_favoriteSalons.contains(index)) {
                              _favoriteSalons.remove(index);
                            } else {
                              _favoriteSalons.add(index);
                            }
                          });
                        },
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: isFavorite
                              ? const Color(0xFFE53935)
                              : (isDark ? AppColors.darkTextSecondary : Colors.black38),
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
