import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routing/route_names.dart';
import '../../panier/presentation/providers/panier_provider.dart';
import '../../salon/presentation/providers/salon_provider.dart';
import '../../salon/data/models/salon_model.dart';
import '../../rendezvous/data/models/rendezvous_panier_model.dart';
import '../../rendezvous/presentation/providers/rendezvous_panier_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Index des éléments sélectionnés au clic (pour afficher la bordure active)
  int? _selectedServiceIndex;
  int? _selectedSalonIndex;
  int? _selectedPrestationIndex;
  int? _selectedStoryIndex;
  int _selectedDistance = 5;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    final double dLat = (lat2 - lat1) * (math.pi / 180.0);
    final double dLon = (lon2 - lon1) * (math.pi / 180.0);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _getSalonDistance(SalonModel salon, {double userLat = 14.6937, double userLng = -17.4441}) {
    if (salon.distanceKm != null) {
      return salon.distanceKm!;
    }
    if (salon.latitude != null && salon.longitude != null) {
      return _calculateDistanceKm(userLat, userLng, salon.latitude!, salon.longitude!);
    }
    return 1.5 + ((salon.id * 3) % 15).toDouble();
  }

  void _onSearchSubmitted(String query) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      context.push('${RouteNames.recherche}?q=${Uri.encodeComponent(trimmed)}&dist=$_selectedDistance');
    } else {
      context.push('${RouteNames.recherche}?dist=$_selectedDistance');
    }
  }

  void _afficherSelecteurDistance(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.figmaActiveGold, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Rayon de recherche (Hibernate Spatial)',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Afficher les salons et prestations filtrés par MySQL Spatial :',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [1, 3, 5, 10, 20, 50].map((dist) {
                    final isSel = _selectedDistance == dist;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedDistance = dist);
                        // Appel de l'endpoint Hibernate Spatial / MySQL
                        ref.read(salonsListProvider.notifier).chargerSalonsNearby(
                          lat: 14.6937,
                          lng: -17.4441,
                          rayonKm: dist.toDouble(),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Rayon défini à $dist km — calcul spatial MySQL'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.figmaBrown,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.figmaActiveGold
                              : (isDark ? AppColors.darkSurfaceVariant : AppColors.figmaInputBg),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel
                                ? AppColors.figmaActiveGold
                                : (isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF)),
                          ),
                        ),
                        child: Text(
                          '$dist km',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : (isDark ? AppColors.darkTextPrimary : Colors.black87),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final salonsState = ref.watch(salonsListProvider);
    final storiesGroupsAsync = ref.watch(kadysStoriesGroupsProvider);
    final storiesMap = {for (var g in (storiesGroupsAsync.valueOrNull ?? [])) g.salonSlug: g};
    final servicesAsync = ref.watch(servicesTransversauxProvider(null));
    final realisationsAsync = ref.watch(realisationsTransversalesProvider);
    final produitsAsync = ref.watch(produitsTransversauxProvider(null));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      // Bouton flottant de l'Assistant IA avec l'icône exacte Figma (bulle avec 3 points)
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.assistantChat),
        backgroundColor: AppColors.figmaActiveGold,
        elevation: 5,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.sms_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 85),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ==============================================================
              // 1. CARROUSEL DES STORIES / SALONS (Scroll horizontal fluide)
              // ==============================================================
              if (salonsState.isLoading && salonsState.salons.isEmpty)
                _buildStoriesSkeleton()
              else if (salonsState.salons.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (int i = 0; i < salonsState.salons.length; i++) ...[
                        if (i > 0) const SizedBox(width: 14),
                        () {
                          final salon = salonsState.salons[i];
                          final group = storiesMap[salon.slug];
                          final hasStories = group != null && group.stories.isNotEmpty;
                          final logoUrl = salon.logoUrl ?? group?.salonLogoUrl;
                          final initials = salon.nom.length >= 2
                              ? salon.nom.substring(0, 2).toUpperCase()
                              : salon.nom.toUpperCase();
                          const colors = [
                            Color(0xFF3D291F),
                            Color(0xFF242B35),
                            Color(0xFF2B1A22),
                            Color(0xFF1A1E24),
                            Color(0xFF321E30),
                            Color(0xFF2E241E),
                          ];
                          final bgColor = colors[i % colors.length];
                          return _buildStoryItem(
                            index: i,
                            label: initials,
                            sublabel: salon.nom,
                            logoUrl: logoUrl,
                            hasActiveStories: hasStories,
                            bgColor: bgColor,
                            onTap: () {
                              setState(() => _selectedStoryIndex = i);
                              context.push(
                                '${RouteNames.story}?salon=${Uri.encodeComponent(salon.nom)}&initials=$initials&slug=${salon.slug}',
                              );
                            },
                          );
                        }(),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // ==============================================================
              // 2. TEXTFIELD DE RECHERCHE & SÉLECTEUR DE DISTANCE (Figma)
              // ==============================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: _onSearchSubmitted,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                            hintText: 'Coiffure, soin, salon, produit...',
                            hintStyle: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                              size: 20,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
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
                    const SizedBox(width: 10),

                    // Sélecteur de distance (Sucette / Pin 📍 + dynamique + flèche)
                    InkWell(
                      onTap: () => _afficherSelecteurDistance(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.figmaActiveGold,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.figmaActiveGold,
                              size: 17,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_selectedDistance km',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.figmaActiveGold,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==============================================================
              // 3. MEILLEURS SALONS
              // ==============================================================
              _buildSectionHeader(
                title: 'Meilleurs Salons',
                actionLabel: 'Voir tout',
                onActionTap: () => context.go(RouteNames.salons),
              ),
              const SizedBox(height: 10),
              () {
                final displayedSalons = salonsState.salons.where((s) {
                  final dist = _getSalonDistance(s);
                  return dist <= _selectedDistance;
                }).toList();

                if (salonsState.isLoading && displayedSalons.isEmpty) {
                  return _buildHorizontalSkeleton(height: 120, width: 180);
                } else if (displayedSalons.isEmpty) {
                  return _buildEmptyState(
                    'Aucun salon dans un rayon de $_selectedDistance km',
                    Icons.storefront_outlined,
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (int i = 0; i < displayedSalons.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        () {
                          final salon = displayedSalons[i];
                          final imgUrl = (salon.coverUrl != null && salon.coverUrl!.isNotEmpty)
                              ? salon.coverUrl!
                              : (salon.logoUrl != null && salon.logoUrl!.isNotEmpty)
                                  ? salon.logoUrl!
                                  : '';
                          final ratingStr = salon.noteMoyenne > 0
                              ? salon.noteMoyenne.toStringAsFixed(1)
                              : '-';
                          final distKm = _getSalonDistance(salon);
                          final loc = '${distKm.toStringAsFixed(1)} km • ${salon.adresse ?? 'Dakar'}';
                          return _buildSalonCard(
                            index: i,
                            imagePath: imgUrl,
                            rating: ratingStr,
                            title: salon.nom,
                            location: loc,
                            onTap: () {
                              setState(() => _selectedSalonIndex = i);
                              context.push('/salons/${salon.slug}');
                            },
                          );
                        }(),
                      ],
                    ],
                  ),
                );
              }(),

              const SizedBox(height: 18),

              // ==============================================================
              // 4. MEILLEURS SERVICES
              // ==============================================================
              _buildSectionHeader(
                title: 'Meilleurs Services',
                actionLabel: 'Explorer',
                onActionTap: () => context.push('${RouteNames.recherche}?dist=$_selectedDistance'),
              ),
              const SizedBox(height: 10),
              servicesAsync.when(
                loading: () => _buildHorizontalSkeleton(height: 52, width: 150),
                error: (_, _) => _buildEmptyState(
                  'Impossible de charger les prestations',
                  Icons.error_outline_rounded,
                ),
                data: (services) {
                  final activeServices = services.where((s) {
                    if (!s.statut) return false;
                    if (s.slugSalon != null && salonsState.salons.isNotEmpty) {
                      final salon = salonsState.salons.firstWhere(
                        (sal) => sal.slug == s.slugSalon,
                        orElse: () => const SalonModel(id: 0, nom: '', slug: ''),
                      );
                      if (salon.id != 0) {
                        final dist = _getSalonDistance(salon);
                        return dist <= _selectedDistance;
                      }
                    }
                    return true;
                  }).toList();

                  if (activeServices.isEmpty) {
                    return _buildEmptyState(
                      'Aucune prestation disponible dans ce rayon',
                      Icons.content_cut_rounded,
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        for (int i = 0; i < activeServices.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          () {
                            final s = activeServices[i];
                            final subtitle = s.variantes.isNotEmpty
                                ? '${s.variantes.length} styles • Dès ${s.minPrix.toInt()} F'
                                : (s.salonNom != null ? s.salonNom! : 'Prestation salon');
                            return _buildServiceCard(
                              index: i,
                              title: s.nom,
                              subtitle: subtitle,
                              onTap: () {
                                setState(() => _selectedServiceIndex = i);
                                if (s.variantes.length == 1) {
                                  final v = s.variantes.first;
                                  final title = Uri.encodeComponent(v.nom.isNotEmpty ? v.nom : s.nom);
                                  final price = Uri.encodeComponent('${v.prix.toInt()} FCFA');
                                  final image = Uri.encodeComponent(v.mainImage ?? s.imageUrl ?? '');
                                  final salon = Uri.encodeComponent(s.salonNom ?? 'Salon Partenaire');
                                  final slug = Uri.encodeComponent(s.slugSalon ?? '');
                                  final desc = Uri.encodeComponent(v.description ?? s.description ?? '');
                                  context.push(
                                    '${RouteNames.varianteDetail}?title=$title&price=$price&image=$image&salon=$salon&slug=$slug&varianteId=${v.id}&serviceId=${s.id}&duree=${v.dureeMinutes}&description=$desc',
                                  );
                                } else if (s.variantes.length > 1) {
                                  final title = Uri.encodeComponent(s.nom);
                                  final desc = Uri.encodeComponent(s.description ?? '');
                                  final salon = Uri.encodeComponent(s.salonNom ?? 'Salon Partenaire');
                                  final slug = Uri.encodeComponent(s.slugSalon ?? '');
                                  context.push(
                                    '${RouteNames.serviceVariantes}?serviceId=${s.id}&title=$title&slug=$slug&salon=$salon&desc=$desc',
                                  );
                                } else {
                                  final title = Uri.encodeComponent(s.nom);
                                  final price = Uri.encodeComponent(s.minPrix > 0 ? '${s.minPrix.toInt()} FCFA' : '5 000 FCFA');
                                  final image = Uri.encodeComponent(s.imageUrl ?? '');
                                  final salon = Uri.encodeComponent(s.salonNom ?? 'Salon Partenaire');
                                  final slug = Uri.encodeComponent(s.slugSalon ?? '');
                                  final desc = Uri.encodeComponent(s.description ?? '');
                                  context.push(
                                    '${RouteNames.varianteDetail}?title=$title&price=$price&image=$image&salon=$salon&slug=$slug&serviceId=${s.id}&description=$desc',
                                  );
                                }
                              },
                            );
                          }(),
                        ],
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // ==============================================================
              // 5. MEILLEURES PRESTATIONS RÉALISÉES
              // ==============================================================
              _buildSectionHeader(
                title: 'Meilleures Prestations Réalisées',
                actionLabel: 'Voir tout',
                onActionTap: () => context.push('${RouteNames.recherche}?dist=$_selectedDistance'),
              ),
              const SizedBox(height: 10),
              realisationsAsync.when(
                loading: () => _buildHorizontalSkeleton(height: 130, width: 190),
                error: (_, _) => _buildEmptyState(
                  'Impossible de charger les réalisations',
                  Icons.error_outline_rounded,
                ),
                data: (realisations) {
                  final activeRealisations =
                      realisations.where((r) => r.statutPublication).toList();
                  if (activeRealisations.isEmpty) {
                    return _buildEmptyState(
                      'Aucune réalisation publiée pour le moment',
                      Icons.photo_library_outlined,
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        for (int i = 0; i < activeRealisations.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          () {
                            final r = activeRealisations[i];
                            final imgUrl = (r.urlVideo != null && r.urlVideo!.isNotEmpty)
                                ? r.urlVideo!
                                : '';
                            final stylist =
                                '${r.coiffeurNomComplet ?? r.salonNom ?? 'Styliste'} • ${r.totalLikes} likes';
                            final priceLabel = r.salonNom ?? 'Prestation salon';
                            return _buildPrestationCard(
                              index: i,
                              imagePath: imgUrl,
                              title: r.titre,
                              stylist: stylist,
                              price: priceLabel,
                              onTap: () {
                                setState(() => _selectedPrestationIndex = i);
                                // Affiche les détails de la prestation (variante service)
                                final title = Uri.encodeComponent(r.titre);
                                final price = Uri.encodeComponent('5 000 FCFA');
                                final image = Uri.encodeComponent(imgUrl);
                                final salon = Uri.encodeComponent(r.salonNom ?? 'Salon Partenaire');
                                final slug = Uri.encodeComponent(r.salonSlug ?? '');
                                final desc = Uri.encodeComponent(r.description ?? 'Prestation ${r.titre} réalisée avec professionnalisme chez ${r.salonNom ?? "notre salon partenaire"}.');
                                context.push(
                                  '${RouteNames.varianteDetail}?title=$title&price=$price&image=$image&salon=$salon&slug=$slug&varianteId=${r.id}&description=$desc',
                                );
                              },
                              onReserver: () {
                                // Ajoute directement la prestation au panier de rendez-vous
                                ref.read(rendezvousPanierProvider.notifier).ajouterPrestation(
                                  slugSalon: r.salonSlug ?? 'salon',
                                  salonNom: r.salonNom ?? 'Salon Partenaire',
                                  prestation: LignePrestationPanierModel(
                                    varianteId: r.id,
                                    serviceNom: r.titre,
                                    varianteNom: r.titre,
                                    prix: 5000.0,
                                    dureeMinutes: 45,
                                    imageUrl: imgUrl.isNotEmpty ? imgUrl : null,
                                  ),
                                );
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${r.titre} ajoutée au panier rendez-vous !'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: AppColors.figmaBrown,
                                    action: SnackBarAction(
                                      label: 'Voir le panier',
                                      textColor: AppColors.figmaActiveGold,
                                      onPressed: () => context.push(RouteNames.panierRendezVous),
                                    ),
                                  ),
                                );
                              },
                            );
                          }(),
                        ],
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // ==============================================================
              // 6. MEILLEURS PRODUITS EN VENTE
              // ==============================================================
              _buildSectionHeader(
                title: 'Meilleurs Produits en Vente',
                actionLabel: null,
              ),
              const SizedBox(height: 10),
              produitsAsync.when(
                loading: () => _buildHorizontalSkeleton(height: 100, width: 210),
                error: (_, _) => _buildEmptyState(
                  'Impossible de charger les produits',
                  Icons.error_outline_rounded,
                ),
                data: (produits) {
                  final activeProduits = produits.where((p) => p.statut).toList();
                  if (activeProduits.isEmpty) {
                    return _buildEmptyState(
                      'Aucun produit disponible en vente actuellement',
                      Icons.shopping_bag_outlined,
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        for (int i = 0; i < activeProduits.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          () {
                            final p = activeProduits[i];
                            final imgUrl = (p.mainImage != null && p.mainImage!.isNotEmpty)
                                ? p.mainImage!
                                : '';
                            final category =
                                '${p.categorieNom ?? 'Soin'} • ${p.isEnRupture ? 'Rupture' : 'En stock'}';
                            final price = '${p.prixVente.toInt()} FCFA';

                            return _buildProductCard(
                              imagePath: imgUrl,
                              title: p.nom,
                              category: category,
                              price: price,
                              onTap: () {
                                final slug = Uri.encodeComponent(p.slugSalon ?? '');
                                final salon = Uri.encodeComponent(p.salonNom ?? 'Salon Partenaire');
                                final title = Uri.encodeComponent(p.nom);
                                final price = Uri.encodeComponent('${p.prixVente.toInt()} FCFA');
                                final image = Uri.encodeComponent(p.mainImage ?? '');
                                final brand = Uri.encodeComponent(p.categorieNom ?? 'Soin');
                                final desc = Uri.encodeComponent(p.description ?? '');
                                final stock = p.stock?.quantiteDisponible ?? 10;
                                context.push(
                                  '${RouteNames.produitDetail}?id=${p.id}&slug=$slug&salon=$salon&title=$title&price=$price&image=$image&brand=$brand&desc=$desc&stock=$stock',
                                );
                              },
                              onAddToCart: () {
                                if (p.isEnRupture) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${p.nom} est actuellement en rupture de stock.'),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                                final slug = (p.slugSalon != null && p.slugSalon!.isNotEmpty)
                                    ? p.slugSalon!
                                    : 'beauty-by-dika';
                                final salon = p.salonNom ?? 'Salon Partenaire';
                                try {
                                  ref.read(panierStateProvider.notifier).ajouterArticle(
                                    slugSalon: slug,
                                    salonNom: salon,
                                    produitId: p.id,
                                    produitNom: p.nom,
                                    prixUnitaire: p.prixVente,
                                    quantite: 1,
                                    imageUrl: p.mainImage,
                                  );
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${p.nom} ajouté au panier ($salon) !'),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: AppColors.figmaBrown,
                                      action: SnackBarAction(
                                        label: 'Voir',
                                        textColor: AppColors.figmaActiveGold,
                                        onPressed: () => context.push(RouteNames.panier),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur lors de l\'ajout au panier : $e'),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                            );
                          }(),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // HELPER : En-tête de section
  // ==============================================================
  Widget _buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : Colors.black,
                ),
              ),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.figmaActiveGold,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==============================================================
  // HELPER : Élément Story / Avatar Salon
  // ==============================================================
  Widget _buildStoryItem({
    required int index,
    required String label,
    required String sublabel,
    required Color bgColor,
    String? logoUrl,
    bool hasActiveStories = false,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedStoryIndex == index;
    final avatarSize = context.responsiveValue<double>(
      smallPhone: 52,
      standard: 58,
      tablet: 68,
    );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasActiveStories
                      ? const LinearGradient(
                          colors: [
                            AppColors.figmaActiveGold,
                            AppColors.figmaBadgePink,
                            Color(0xFFFF8A00),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: hasActiveStories
                      ? null
                      : Border.all(
                          color: isSelected
                              ? AppColors.figmaActiveGold
                              : const Color(0xFFD4AF37),
                          width: isSelected ? 2.5 : 1.5,
                        ),
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: hasActiveStories
                        ? Border.all(color: Colors.black, width: 1.5)
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: (logoUrl != null && logoUrl.startsWith('http'))
                      ? Image.network(
                          logoUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      : Text(
                          label,
                          style: TextStyle(
                            color: hasActiveStories ? AppColors.figmaBadgeGold : Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: avatarSize + 12,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                sublabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.adaptiveSubtextColor(),
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // HELPER : Carte Meilleurs Salons
  // ==============================================================
  Widget _buildSalonCard({
    required int index,
    required String imagePath,
    required String rating,
    required String title,
    required String location,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedSalonIndex == index;
    final cardWidth = context.responsiveValue<double>(
      smallPhone: 165,
      standard: (context.screenWidth * 0.46).clamp(170.0, 195.0),
      tablet: 220,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaCardBg,
          borderRadius: BorderRadius.circular(12),
          border: context.symmetricBorder(isSelected: isSelected),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 8,
                    child: _buildImage(
                      imagePath,
                      fallbackAsset: 'assets/images/accueil_img_0.png',
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.figmaRatingBg,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.figmaActiveGold,
                          size: 12,
                        ),
                        const SizedBox(width: 2.5),
                        Text(
                          rating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.fontSize(13),
                      fontWeight: FontWeight.w800,
                      color: context.adaptiveTextColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.figmaActiveGold,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: context.adaptiveSubtextColor(),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
  // HELPER : Carte Meilleurs Services
  // ==============================================================
  Widget _buildServiceCard({
    required int index,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedServiceIndex == index;
    final cardWidth = context.responsiveValue<double>(
      smallPhone: 130,
      standard: (context.screenWidth * 0.35).clamp(135.0, 160.0),
      tablet: 180,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaCardBg,
          borderRadius: BorderRadius.circular(10),
          border: context.symmetricBorder(isSelected: isSelected),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: context.fontSize(12.5),
                  fontWeight: FontWeight.w800,
                  color: context.adaptiveTextColor(),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.figmaActiveGold : context.adaptiveSubtextColor(),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // HELPER : Carte Prestation Réalisée
  // ==============================================================
  Widget _buildPrestationCard({
    required int index,
    required String imagePath,
    required String title,
    required String stylist,
    required String price,
    required VoidCallback onTap,
    required VoidCallback onReserver,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedPrestationIndex == index;
    final cardWidth = context.responsiveValue<double>(
      smallPhone: 175,
      standard: (context.screenWidth * 0.48).clamp(180.0, 215.0),
      tablet: 240,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaCardBg,
          borderRadius: BorderRadius.circular(12),
          border: context.symmetricBorder(isSelected: isSelected),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 8,
                child: _buildImage(
                  imagePath,
                  fallbackAsset: 'assets/images/accueil_img_3.png',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.fontSize(12.5),
                      fontWeight: FontWeight.w800,
                      color: context.adaptiveTextColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    stylist,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: context.adaptiveSubtextColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            price,
                            style: TextStyle(
                              fontSize: context.fontSize(11.5),
                              fontWeight: FontWeight.w800,
                              color: AppColors.figmaActiveGold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onReserver,
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.figmaBrown,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Réserver',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
  // HELPER : Carte Produit en Vente
  // ==============================================================
  Widget _buildProductCard({
    required String imagePath,
    required String title,
    required String category,
    required String price,
    VoidCallback? onTap,
    required VoidCallback onAddToCart,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardWidth = context.responsiveValue<double>(
      smallPhone: 195,
      standard: (context.screenWidth * 0.52).clamp(200.0, 235.0),
      tablet: 260,
    );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaCardBg,
          borderRadius: BorderRadius.circular(12),
          border: context.symmetricBorder(),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImage(
                    imagePath,
                    width: 52,
                    height: 52,
                    fallbackAsset: 'assets/images/accueil_img_5.png',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: context.fontSize(12),
                          fontWeight: FontWeight.w800,
                          color: context.adaptiveTextColor(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: context.fontSize(10),
                          color: context.adaptiveSubtextColor(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          price,
                          style: TextStyle(
                            fontSize: context.fontSize(11.5),
                            fontWeight: FontWeight.w800,
                            color: AppColors.figmaActiveGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: onAddToCart,
              borderRadius: BorderRadius.circular(7),
              child: Container(
                height: 28,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.figmaActiveGold,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_shopping_cart_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Ajouter au panier',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.fontSize(11),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // HELPER : Gestion unifiée des images (Réseau ou Assets locaux)
  // ==============================================================
  Widget _buildImage(
    String pathOrUrl, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    required String fallbackAsset,
  }) {
    Widget fallbackPlaceholder() => Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4A3428),
                AppColors.figmaBrown,
              ],
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.storefront_rounded,
            color: AppColors.figmaActiveGold,
            size: 26,
          ),
        );

    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Image.network(
        pathOrUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => fallbackPlaceholder(),
      );
    } else if (pathOrUrl.isNotEmpty && !pathOrUrl.contains('accueil_img')) {
      return Image.asset(
        pathOrUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => fallbackPlaceholder(),
      );
    } else {
      return fallbackPlaceholder();
    }
  }

  // ==============================================================
  // HELPER : État vide élégant avec icône et message
  // ==============================================================
  Widget _buildEmptyState(String message, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.figmaCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: AppColors.figmaActiveGold.withValues(alpha: 0.6)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: context.adaptiveSubtextColor(),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // HELPER : Squelettes de chargement horizontaux
  // ==============================================================
  Widget _buildStoriesSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          5,
          (index) => Container(
            width: 58,
            height: 58,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF3ECE4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalSkeleton({required double height, required double width}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(
          3,
          (index) => Container(
            width: width,
            height: height,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF3ECE4),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.figmaActiveGold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
