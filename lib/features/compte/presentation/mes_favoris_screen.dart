import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';

// Modèle Salon Favori
class FavoriSalonItem {
  final String id;
  final String nom;
  final double rating;
  final int avisCount;
  final String adresse;
  final String imagePath;
  final String fallbackImagePath;
  final String slug;
  bool isFavorite;

  FavoriSalonItem({
    required this.id,
    required this.nom,
    required this.rating,
    required this.avisCount,
    required this.adresse,
    required this.imagePath,
    required this.fallbackImagePath,
    required this.slug,
    this.isFavorite = true,
  });
}

// Modèle Coiffure Favorite
class FavoriCoiffureItem {
  final String id;
  final String nom;
  final String prix;
  final String imagePath;
  final String fallbackImagePath;
  bool isFavorite;

  FavoriCoiffureItem({
    required this.id,
    required this.nom,
    required this.prix,
    required this.imagePath,
    required this.fallbackImagePath,
    this.isFavorite = true,
  });
}

// Modèle Produit Favori
class FavoriProduitItem {
  final String id;
  final String nom;
  final String prix;
  final String imagePath;
  final String fallbackImagePath;
  bool isFavorite;

  FavoriProduitItem({
    required this.id,
    required this.nom,
    required this.prix,
    required this.imagePath,
    required this.fallbackImagePath,
    this.isFavorite = true,
  });
}

enum FavoriTab { salons, coiffures, produits }

class MesFavorisScreen extends ConsumerStatefulWidget {
  final FavoriTab initialTab;

  const MesFavorisScreen({
    super.key,
    this.initialTab = FavoriTab.salons,
  });

  @override
  ConsumerState<MesFavorisScreen> createState() => _MesFavorisScreenState();
}

class _MesFavorisScreenState extends ConsumerState<MesFavorisScreen> {
  late FavoriTab _currentTab;

  late List<FavoriSalonItem> _salons;
  late List<FavoriCoiffureItem> _coiffures;
  late List<FavoriProduitItem> _produits;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;

    _salons = [
      FavoriSalonItem(
        id: '1',
        nom: 'Beauty By Dika',
        rating: 4.8,
        avisCount: 124,
        adresse: 'Bamako, Kalaban',
        imagePath: 'assets/images/favoris_salon_img_0.jpeg',
        fallbackImagePath: 'assets/images/salons_img_0.jpg',
        slug: 'beauty-by-dika',
      ),
      FavoriSalonItem(
        id: '2',
        nom: 'Mathy hair',
        rating: 4.8,
        avisCount: 124,
        adresse: 'Bamako, Kalaban',
        imagePath: 'assets/images/favoris_salon_img_1.jpeg',
        fallbackImagePath: 'assets/images/salons_img_1.jpg',
        slug: 'mathy-hair',
      ),
      FavoriSalonItem(
        id: '3',
        nom: 'Hair Prestige',
        rating: 4.8,
        avisCount: 124,
        adresse: 'Bamako, Kalaban',
        imagePath: 'assets/images/favoris_salon_img_2.jpeg',
        fallbackImagePath: 'assets/images/salons_img_2.jpg',
        slug: 'hair-prestige',
      ),
      FavoriSalonItem(
        id: '4',
        nom: "L'Atelier des Cheveux",
        rating: 4.8,
        avisCount: 124,
        adresse: 'Bamako, Kalaban',
        imagePath: 'assets/images/favoris_salon_img_3.jpeg',
        fallbackImagePath: 'assets/images/salons_img_3.jpg',
        slug: 'latelier-des-cheveux',
      ),
      FavoriSalonItem(
        id: '5',
        nom: 'Adja Beauty',
        rating: 4.8,
        avisCount: 124,
        adresse: 'Bamako, Kalaban',
        imagePath: 'assets/images/favoris_salon_img_4.jpeg',
        fallbackImagePath: 'assets/images/salons_img_4.jpg',
        slug: 'adja-beauty',
      ),
      FavoriSalonItem(
        id: '6',
        nom: 'Safoura Coiffure',
        rating: 4.8,
        avisCount: 124,
        adresse: 'Bamako, Kalaban',
        imagePath: 'assets/images/favoris_salon_img_5.jpeg',
        fallbackImagePath: 'assets/images/salons_img_5.jpg',
        slug: 'safoura-coiffure',
      ),
    ];

    _coiffures = [
      FavoriCoiffureItem(
        id: '1',
        nom: 'Tresses collées',
        prix: '5 000 FCFA',
        imagePath: 'assets/images/favoris_coiffure_img_0.png',
        fallbackImagePath: 'assets/images/service_img_0.jpg',
      ),
      FavoriCoiffureItem(
        id: '2',
        nom: 'Brushing',
        prix: '6 000 FCFA',
        imagePath: 'assets/images/favoris_coiffure_img_1.png',
        fallbackImagePath: 'assets/images/service_img_1.jpg',
      ),
      FavoriCoiffureItem(
        id: '3',
        nom: 'Coupe homme',
        prix: '8 000 FCFA',
        imagePath: 'assets/images/favoris_coiffure_img_2.jpeg',
        fallbackImagePath: 'assets/images/service_img_2.jpg',
      ),
      FavoriCoiffureItem(
        id: '4',
        nom: 'Manucure\n& Pédicure',
        prix: '4 000 FCFA',
        imagePath: 'assets/images/favoris_coiffure_img_3.jpeg',
        fallbackImagePath: 'assets/images/service_img_3.jpg',
      ),
      FavoriCoiffureItem(
        id: '5',
        nom: 'Tresses\nafricaines',
        prix: '7 000 FCFA',
        imagePath: 'assets/images/favoris_coiffure_img_4.jpeg',
        fallbackImagePath: 'assets/images/service_img_4.jpg',
      ),
      FavoriCoiffureItem(
        id: '6',
        nom: 'Soin visage',
        prix: '12 000 FCFA',
        imagePath: 'assets/images/favoris_coiffure_img_5.jpeg',
        fallbackImagePath: 'assets/images/service_img_5.jpg',
      ),
    ];

    _produits = [
      FavoriProduitItem(
        id: '1',
        nom: 'Oreal',
        prix: '5 000 FCFA',
        imagePath: 'assets/images/favoris_produit_img_0.png',
        fallbackImagePath: 'assets/images/produit_cat_img_0.jpg',
      ),
      FavoriProduitItem(
        id: '2',
        nom: 'Bare',
        prix: '6 000 FCFA',
        imagePath: 'assets/images/favoris_produit_img_1.png',
        fallbackImagePath: 'assets/images/produit_cat_img_1.jpg',
      ),
      FavoriProduitItem(
        id: '3',
        nom: 'Najel',
        prix: '8 000 FCFA',
        imagePath: 'assets/images/favoris_produit_img_2.png',
        fallbackImagePath: 'assets/images/produit_cat_img_2.jpg',
      ),
      FavoriProduitItem(
        id: '4',
        nom: 'Palmolive',
        prix: '4 000 FCFA',
        imagePath: 'assets/images/favoris_produit_img_3.png',
        fallbackImagePath: 'assets/images/produit_cat_img_3.jpg',
      ),
      FavoriProduitItem(
        id: '5',
        nom: 'Kérastase',
        prix: '7 000 FCFA',
        imagePath: 'assets/images/favoris_produit_img_4.png',
        fallbackImagePath: 'assets/images/produit_cat_img_4.jpg',
      ),
      FavoriProduitItem(
        id: '6',
        nom: 'Sérum soin',
        prix: '12 000 FCFA',
        imagePath: 'assets/images/favoris_produit_img_5.png',
        fallbackImagePath: 'assets/images/produit_cat_img_5.jpg',
      ),
    ];
  }

  void _toggleSalonFavorite(FavoriSalonItem item) {
    setState(() {
      item.isFavorite = !item.isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item.isFavorite
              ? '${item.nom} ajouté aux favoris'
              : '${item.nom} retiré des favoris',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleCoiffureFavorite(FavoriCoiffureItem item) {
    setState(() {
      item.isFavorite = !item.isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item.isFavorite
              ? '${item.nom.replaceAll('\n', ' ')} ajoutée aux favoris'
              : '${item.nom.replaceAll('\n', ' ')} retirée des favoris',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleProduitFavorite(FavoriProduitItem item) {
    setState(() {
      item.isFavorite = !item.isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item.isFavorite
              ? '${item.nom} ajouté aux favoris'
              : '${item.nom} retiré des favoris',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mes favoris',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 14),

          // ==============================================================
          // 1. ONGLET PILULES (Salons | Coiffures | Produits)
          // ==============================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildPillTab(
                  label: 'Salons',
                  isSelected: _currentTab == FavoriTab.salons,
                  isDark: isDark,
                  onTap: () => setState(() => _currentTab = FavoriTab.salons),
                ),
                const SizedBox(width: 10),
                _buildPillTab(
                  label: 'Coiffures',
                  isSelected: _currentTab == FavoriTab.coiffures,
                  isDark: isDark,
                  onTap: () => setState(() => _currentTab = FavoriTab.coiffures),
                ),
                const SizedBox(width: 10),
                _buildPillTab(
                  label: 'Produits',
                  isSelected: _currentTab == FavoriTab.produits,
                  isDark: isDark,
                  onTap: () => setState(() => _currentTab = FavoriTab.produits),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ==============================================================
          // 2. CONTENU DU TAB SÉLECTIONNÉ
          // ==============================================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: _buildCurrentTabContent(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTab({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
              : (isDark ? AppColors.darkSurface : const Color(0xFFEEE1D6)),
          borderRadius: BorderRadius.circular(16),
          border: (!isSelected && isDark) ? Border.all(color: AppColors.darkBorder) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? const Color(0xFF1E1610) : Colors.white)
                : (isDark ? AppColors.darkTextSecondary : AppColors.figmaBrown),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent(bool isDark) {
    switch (_currentTab) {
      case FavoriTab.salons:
        return _buildSalonsGrid(isDark);
      case FavoriTab.coiffures:
        return _buildCoiffuresGrid();
      case FavoriTab.produits:
        return _buildProduitsGrid();
    }
  }

  // ==============================================================
  // TAB 1 : GRILLE SALONS (Carte blanche, bordure fine, photo en haut)
  // ==============================================================
  Widget _buildSalonsGrid(bool isDark) {
    final activeSalons = _salons.where((s) => s.isFavorite).toList();

    if (activeSalons.isEmpty) {
      return _buildEmptyState('Aucun salon dans vos favoris');
    }

    // 2 colonnes
    final rows = <Widget>[];
    for (int i = 0; i < activeSalons.length; i += 2) {
      final salon1 = activeSalons[i];
      final salon2 = (i + 1 < activeSalons.length) ? activeSalons[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Expanded(child: _buildSalonCard(salon1, isDark)),
              const SizedBox(width: 12),
              Expanded(
                child: salon2 != null ? _buildSalonCard(salon2, isDark) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildSalonCard(FavoriSalonItem item, bool isDark) {
    return GestureDetector(
      onTap: () {
        context.push('/salons/${item.slug}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE8E2DC),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image en haut
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 107,
                width: double.infinity,
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.asset(
                    item.fallbackImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFF2EAE1),
                      alignment: Alignment.center,
                      child: const Icon(Icons.storefront_rounded, color: AppColors.figmaBrown, size: 30),
                    ),
                  ),
                ),
              ),
            ),

            // Contenu texte
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du salon
                  Text(
                    item.nom,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Étoile + Note + Avis
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFEBC416)),
                      const SizedBox(width: 4),
                      Text(
                        '${item.rating}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        ' (${item.avisCount} avis)',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8C827A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Adresse + Cœur favori rouge
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: Color(0xFFF24822)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.adresse,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF8C827A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleSalonFavorite(item),
                        child: Icon(
                          item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 17,
                          color: const Color(0xFFF24822),
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

  // ==============================================================
  // TAB 2 : GRILLE COIFFURES (Carte pleine photo avec badge or)
  // ==============================================================
  Widget _buildCoiffuresGrid() {
    final activeCoiffures = _coiffures.where((c) => c.isFavorite).toList();

    if (activeCoiffures.isEmpty) {
      return _buildEmptyState('Aucune coiffure dans vos favoris');
    }

    final rows = <Widget>[];
    for (int i = 0; i < activeCoiffures.length; i += 2) {
      final coiffure1 = activeCoiffures[i];
      final coiffure2 = (i + 1 < activeCoiffures.length) ? activeCoiffures[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(child: _buildCoiffureCard(coiffure1)),
              const SizedBox(width: 12),
              Expanded(
                child: coiffure2 != null ? _buildCoiffureCard(coiffure2) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildCoiffureCard(FavoriCoiffureItem item) {
    return GestureDetector(
      onTap: () {
        context.push(RouteNames.serviceVariantes);
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image de fond
              Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.asset(
                  item.fallbackImagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF382319),
                    alignment: Alignment.center,
                    child: const Icon(Icons.face_3_outlined, color: AppColors.figmaActiveGold, size: 30),
                  ),
                ),
              ),

              // Voile dégradé noir en bas pour la lisibilité
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.4, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              // Cœur favori rouge en haut à droite
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleCoiffureFavorite(item),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: const Color(0xFFF44336),
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Nom et Badge Prix en bas
              Positioned(
                left: 10,
                right: 8,
                bottom: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Nom de la coiffure
                    Expanded(
                      child: Text(
                        item.nom,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Badge Prix avec contour doré et fond sombre
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111622).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF5A623),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        item.prix,
                        style: const TextStyle(
                          color: Color(0xFFECC870),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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

  // ==============================================================
  // TAB 3 : GRILLE PRODUITS (Carte pleine photo avec badge or)
  // ==============================================================
  Widget _buildProduitsGrid() {
    final activeProduits = _produits.where((p) => p.isFavorite).toList();

    if (activeProduits.isEmpty) {
      return _buildEmptyState('Aucun produit dans vos favoris');
    }

    final rows = <Widget>[];
    for (int i = 0; i < activeProduits.length; i += 2) {
      final produit1 = activeProduits[i];
      final produit2 = (i + 1 < activeProduits.length) ? activeProduits[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(child: _buildProduitCard(produit1)),
              const SizedBox(width: 12),
              Expanded(
                child: produit2 != null ? _buildProduitCard(produit2) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildProduitCard(FavoriProduitItem item) {
    return GestureDetector(
      onTap: () {
        context.push(RouteNames.produitDetail);
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image du produit
              Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.asset(
                  item.fallbackImagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFFF9FAFB),
                    alignment: Alignment.center,
                    child: const Icon(Icons.shopping_bag_outlined, color: AppColors.figmaBrown, size: 30),
                  ),
                ),
              ),

              // Voile dégradé noir en bas
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.4, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              // Cœur favori rouge en haut à droite
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleProduitFavorite(item),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: const Color(0xFFF44336),
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Nom du produit et Badge Prix en bas
              Positioned(
                left: 10,
                right: 8,
                bottom: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Nom
                    Expanded(
                      child: Text(
                        item.nom,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Badge Prix avec contour doré et fond sombre
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111622).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF5A623),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        item.prix,
                        style: const TextStyle(
                          color: Color(0xFFECC870),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFBF4ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 34,
              color: AppColors.figmaBrown,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E1C15),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Explorez nos salons et prestations pour ajouter vos coups de cœur ici !',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(RouteNames.salons),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.figmaBrown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            child: const Text(
              'Découvrir des salons',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
