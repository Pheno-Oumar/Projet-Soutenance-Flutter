import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routing/route_names.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../salon/data/models/salon_model.dart';
import '../../salon/presentation/providers/salon_provider.dart';
import 'providers/favoris_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAuth = ref.watch(authStateProvider).isAuthenticated;
    final favState = ref.watch(favorisProvider);
    final salonsState = ref.watch(salonsListProvider);

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
              padding: EdgeInsets.only(
                left: 14,
                right: 14,
                top: 8,
                bottom: context.responsiveValue(compact: 70.0, standard: 80.0),
              ),
              child: _buildCurrentTabContent(isDark, isAuth, favState, salonsState),
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
          border: context.symmetricBorder(
            isSelected: isSelected,
            selectedColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? const Color(0xFF1E1610) : Colors.white)
                : (isDark ? AppColors.darkTextSecondary : AppColors.figmaBrown),
            fontSize: context.fontSize(13),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent(
    bool isDark,
    bool isAuth,
    FavorisState favState,
    SalonsListState salonsState,
  ) {
    switch (_currentTab) {
      case FavoriTab.salons:
        return _buildSalonsContent(isDark, isAuth, favState, salonsState);
      case FavoriTab.coiffures:
        return _buildCoiffuresContent(isDark, isAuth, favState);
      case FavoriTab.produits:
        return _buildProduitsContent(isDark, isAuth, favState);
    }
  }

  // ==============================================================
  // TAB 1 : GRILLE SALONS FAVORIS
  // ==============================================================
  Widget _buildSalonsContent(
    bool isDark,
    bool isAuth,
    FavorisState favState,
    SalonsListState salonsState,
  ) {
    if (isAuth) {
      final remoteAsync = ref.watch(favorisRemoteSalonsProvider);
      return remoteAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.figmaActiveGold),
            ),
          ),
        ),
        error: (_, _) => _buildEmptyState('Impossible de charger vos salons favoris'),
        data: (remoteList) {
          if (remoteList.isEmpty) {
            return _buildEmptyState('Aucun salon dans vos favoris');
          }

          // Construire les cartes depuis remoteList
          final items = remoteList.map((m) {
            final slug = (m['salonSlug'] ?? m['slug'] ?? '').toString();
            final nom = (m['salonNom'] ?? m['nom'] ?? 'Salon').toString();
            final logo = m['salonLogoUrl'] as String?;

            // Essayer de trouver les détails supplémentaires dans salonsState
            final matchedSalon = salonsState.salons.cast<SalonModel?>().firstWhere(
                  (s) => s?.slug == slug,
                  orElse: () => null,
                );

            final image = matchedSalon?.coverUrl ?? matchedSalon?.logoUrl ?? logo ?? 'assets/images/favoris_salon_img_0.jpeg';
            final rating = matchedSalon != null && matchedSalon.noteMoyenne > 0
                ? matchedSalon.noteMoyenne.toStringAsFixed(1)
                : '4.8';
            final avisCount = matchedSalon?.nombreAvis ?? 12;
            final adresse = matchedSalon?.adresse ?? 'Dakar, Sénégal';

            return _FavoriSalonData(
              slug: slug,
              nom: nom,
              imagePath: image,
              rating: rating,
              avisCount: avisCount,
              adresse: adresse,
            );
          }).toList();

          return _renderSalonsGrid(items, isDark);
        },
      );
    } else {
      // Mode invité : Salons matchés avec salonSlugs
      final guestSalons = salonsState.salons
          .where((s) => favState.isSalonFav(s.slug))
          .map((s) => _FavoriSalonData(
                slug: s.slug,
                nom: s.nom,
                imagePath: s.coverUrl ?? s.logoUrl ?? 'assets/images/favoris_salon_img_0.jpeg',
                rating: s.noteMoyenne > 0 ? s.noteMoyenne.toStringAsFixed(1) : '4.8',
                avisCount: s.nombreAvis,
                adresse: s.adresse ?? 'Dakar, Sénégal',
              ))
          .toList();

      if (guestSalons.isEmpty) {
        return _buildEmptyState('Aucun salon dans vos favoris');
      }

      return _renderSalonsGrid(guestSalons, isDark);
    }
  }

  Widget _renderSalonsGrid(List<_FavoriSalonData> items, bool isDark) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final item1 = items[i];
      final item2 = (i + 1 < items.length) ? items[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Expanded(child: _buildSalonCard(item1, isDark)),
              const SizedBox(width: 12),
              Expanded(
                child: item2 != null ? _buildSalonCard(item2, isDark) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildSalonCard(_FavoriSalonData item, bool isDark) {
    return GestureDetector(
      onTap: () {
        context.push('/salons/${item.slug}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: context.symmetricBorder(),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: context.responsiveValue(compact: 96.0, standard: 107.0),
                width: double.infinity,
                child: _buildImage(
                  item.imagePath,
                  fallbackAsset: 'assets/images/salons_img_0.jpg',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nom,
                    style: TextStyle(
                      fontSize: context.fontSize(13.5),
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFEBC416)),
                      const SizedBox(width: 4),
                      Text(
                        item.rating,
                        style: TextStyle(
                          fontSize: context.fontSize(11.5),
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        ' (${item.avisCount} avis)',
                        style: TextStyle(
                          fontSize: context.fontSize(11),
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8C827A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: Color(0xFFF24822)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.adresse,
                          style: TextStyle(
                            fontSize: context.fontSize(11),
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF8C827A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(favorisProvider.notifier).toggleSalon(item.slug);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.nom} retiré des favoris'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 17,
                          color: Color(0xFFF24822),
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
  // TAB 2 : GRILLE COIFFURES FAVORITES
  // ==============================================================
  Widget _buildCoiffuresContent(bool isDark, bool isAuth, FavorisState favState) {
    if (isAuth) {
      final remoteAsync = ref.watch(favorisRemoteCoiffuresProvider);
      return remoteAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.figmaActiveGold),
            ),
          ),
        ),
        error: (_, _) => _buildEmptyState('Impossible de charger vos coiffures favorites'),
        data: (remoteList) {
          if (remoteList.isEmpty) {
            return _buildEmptyState('Aucune coiffure dans vos favoris');
          }

          final items = remoteList.map((m) {
            final varianteId = (m['varianteId'] ?? m['id'] ?? 0) as int;
            final nom = (m['varianteNom'] ?? m['serviceNom'] ?? 'Coiffure').toString();
            final slug = m['salonSlug'] as String?;
            final salonNom = m['salonNom'] as String?;
            final rawPrix = m['prix'];
            final prixStr = rawPrix != null ? '${(rawPrix as num).toInt()} FCFA' : 'Sur devis';

            return _FavoriCoiffureData(
              id: varianteId,
              nom: nom,
              prix: prixStr,
              salonSlug: slug,
              salonNom: salonNom,
              imagePath: 'assets/images/favoris_coiffure_img_${varianteId % 5}.png',
            );
          }).toList();

          return _renderCoiffuresGrid(items);
        },
      );
    } else {
      // Mode invité
      final servicesAsync = ref.watch(servicesTransversauxProvider(null));
      final allServices = servicesAsync.value ?? [];
      final guestCoiffures = <_FavoriCoiffureData>[];

      for (final s in allServices) {
        for (final v in s.variantes) {
          if (favState.isCoiffureFav(v.id)) {
            guestCoiffures.add(
              _FavoriCoiffureData(
                id: v.id,
                nom: '${s.nom} - ${v.nom}',
                prix: '${v.prix.toInt()} FCFA',
                salonSlug: s.slugSalon,
                salonNom: s.salonNom,
                imagePath: s.imageUrl ?? 'assets/images/favoris_coiffure_img_0.png',
              ),
            );
          }
        }
      }

      if (guestCoiffures.isEmpty) {
        return _buildEmptyState('Aucune coiffure dans vos favoris');
      }

      return _renderCoiffuresGrid(guestCoiffures);
    }
  }

  Widget _renderCoiffuresGrid(List<_FavoriCoiffureData> items) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final c1 = items[i];
      final c2 = (i + 1 < items.length) ? items[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(child: _buildCoiffureCard(c1)),
              const SizedBox(width: 12),
              Expanded(
                child: c2 != null ? _buildCoiffureCard(c2) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildCoiffureCard(_FavoriCoiffureData item) {
    return GestureDetector(
      onTap: () {
        if (item.salonSlug != null) {
          context.push('/salons/${item.salonSlug}');
        } else {
          context.push(RouteNames.salons);
        }
      },
      child: Container(
        height: context.responsiveValue(compact: 140.0, standard: 150.0),
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
              _buildImage(
                item.imagePath,
                fallbackAsset: 'assets/images/service_img_0.jpg',
              ),
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
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    ref.read(favorisProvider.notifier).toggleCoiffure(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.nom} retirée des favoris'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFF44336),
                      size: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 8,
                bottom: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        item.nom,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.fontSize(12.5),
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.prix,
                          style: TextStyle(
                            color: const Color(0xFFECC870),
                            fontSize: context.fontSize(10),
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
      ),
    );
  }

  // ==============================================================
  // TAB 3 : GRILLE PRODUITS FAVORIS
  // ==============================================================
  Widget _buildProduitsContent(bool isDark, bool isAuth, FavorisState favState) {
    if (isAuth) {
      final remoteAsync = ref.watch(favorisRemoteProduitsProvider);
      return remoteAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.figmaActiveGold),
            ),
          ),
        ),
        error: (_, _) => _buildEmptyState('Impossible de charger vos produits favoris'),
        data: (remoteList) {
          if (remoteList.isEmpty) {
            return _buildEmptyState('Aucun produit dans vos favoris');
          }

          final items = remoteList.map((m) {
            final produitId = (m['produitId'] ?? m['id'] ?? 0) as int;
            final nom = (m['produitNom'] ?? m['nom'] ?? 'Produit').toString();
            final slug = m['salonSlug'] as String?;
            final salonNom = m['salonNom'] as String?;
            final image = m['imageUrl'] as String?;
            final rawPrix = m['prixVente'] ?? m['prix'];
            final prixStr = rawPrix != null ? '${(rawPrix as num).toInt()} FCFA' : 'Sur demande';

            return _FavoriProduitData(
              id: produitId,
              nom: nom,
              prix: prixStr,
              salonSlug: slug,
              salonNom: salonNom,
              imagePath: image ?? 'assets/images/favoris_produit_img_${produitId % 5}.png',
            );
          }).toList();

          return _renderProduitsGrid(items);
        },
      );
    } else {
      // Mode invité
      final produitsAsync = ref.watch(produitsTransversauxProvider(null));
      final allProduits = produitsAsync.value ?? [];
      final guestProduits = allProduits
          .where((p) => favState.isProduitFav(p.id))
          .map((p) => _FavoriProduitData(
                id: p.id,
                nom: p.nom,
                prix: '${p.prixVente.toInt()} FCFA',
                salonSlug: p.slugSalon,
                salonNom: p.salonNom,
                imagePath: p.mainImage ?? 'assets/images/favoris_produit_img_0.png',
              ))
          .toList();

      if (guestProduits.isEmpty) {
        return _buildEmptyState('Aucun produit dans vos favoris');
      }

      return _renderProduitsGrid(guestProduits);
    }
  }

  Widget _renderProduitsGrid(List<_FavoriProduitData> items) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final p1 = items[i];
      final p2 = (i + 1 < items.length) ? items[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(child: _buildProduitCard(p1)),
              const SizedBox(width: 12),
              Expanded(
                child: p2 != null ? _buildProduitCard(p2) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildProduitCard(_FavoriProduitData item) {
    return GestureDetector(
      onTap: () {
        if (item.salonSlug != null) {
          context.push('/salons/${item.salonSlug}/produits/${item.id}');
        } else {
          context.push(RouteNames.salons);
        }
      },
      child: Container(
        height: context.responsiveValue(compact: 140.0, standard: 150.0),
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
              _buildImage(
                item.imagePath,
                fallbackAsset: 'assets/images/produit_cat_img_0.jpg',
              ),
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
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    ref.read(favorisProvider.notifier).toggleProduit(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.nom} retiré des favoris'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFF44336),
                      size: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 8,
                bottom: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        item.nom,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.fontSize(12.5),
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.prix,
                          style: TextStyle(
                            color: const Color(0xFFECC870),
                            fontSize: context.fontSize(10),
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
      ),
    );
  }

  // ==============================================================
  // HELPER : Gestion unifiée des images
  // ==============================================================
  Widget _buildImage(
    String pathOrUrl, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    required String fallbackAsset,
  }) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Image.network(
        pathOrUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    } else {
      return Image.asset(
        pathOrUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }
  }

  // ==============================================================
  // HELPER : État vide
  // ==============================================================
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

class _FavoriSalonData {
  final String slug;
  final String nom;
  final String imagePath;
  final String rating;
  final int avisCount;
  final String adresse;

  const _FavoriSalonData({
    required this.slug,
    required this.nom,
    required this.imagePath,
    required this.rating,
    required this.avisCount,
    required this.adresse,
  });
}

class _FavoriCoiffureData {
  final int id;
  final String nom;
  final String prix;
  final String? salonSlug;
  final String? salonNom;
  final String imagePath;

  const _FavoriCoiffureData({
    required this.id,
    required this.nom,
    required this.prix,
    this.salonSlug,
    this.salonNom,
    required this.imagePath,
  });
}

class _FavoriProduitData {
  final int id;
  final String nom;
  final String prix;
  final String? salonSlug;
  final String? salonNom;
  final String imagePath;

  const _FavoriProduitData({
    required this.id,
    required this.nom,
    required this.prix,
    this.salonSlug,
    this.salonNom,
    required this.imagePath,
  });
}
