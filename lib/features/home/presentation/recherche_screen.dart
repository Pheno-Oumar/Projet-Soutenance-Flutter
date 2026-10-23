import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routing/route_names.dart';
import '../../panier/presentation/providers/panier_provider.dart';
import '../../salon/presentation/providers/salon_provider.dart';
import '../../salon/data/models/service_salon_model.dart';
import '../../salon/data/models/produit_salon_model.dart';
import '../../salon/data/models/salon_model.dart';
import '../../rendezvous/data/models/rendezvous_panier_model.dart';
import '../../rendezvous/presentation/providers/rendezvous_panier_provider.dart';

class RechercheScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  final int? initialDistance;

  const RechercheScreen({
    super.key,
    this.initialQuery,
    this.initialDistance,
  });

  @override
  ConsumerState<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends ConsumerState<RechercheScreen> {
  late final TextEditingController _searchController;
  int _selectedPillIndex = 0; // 0: Tous, 1: Salons, 2: Services, 3: Produits
  int? _selectedResultIndex; // Index de la carte cliquée
  late int _selectedDistance;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _selectedDistance = widget.initialDistance ?? 5;
  }

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
                  'Afficher les résultats filtrés par MySQL Spatial :',
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
                            content: Text('Résultats filtrés dans un rayon de $dist km (MySQL Spatial)'),
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
    final queryText = _searchController.text.trim();
    final q = queryText.toLowerCase();

    final salonsState = ref.watch(salonsListProvider);
    final servicesAsync = ref.watch(servicesTransversauxProvider(queryText.isNotEmpty ? queryText : null));
    final produitsAsync = ref.watch(produitsTransversauxProvider(null));

    // Filtrage dynamique Salons par mot-clé et par rayon kilométrique
    final filteredSalons = salonsState.salons.where((s) {
      final matchesQuery = q.isEmpty ||
          s.nom.toLowerCase().contains(q) ||
          (s.adresse != null && s.adresse!.toLowerCase().contains(q)) ||
          (s.description != null && s.description!.toLowerCase().contains(q));
      if (!matchesQuery) return false;
      final dist = _getSalonDistance(s);
      return dist <= _selectedDistance;
    }).toList();

    // Filtrage dynamique Services par mot-clé et par rayon kilométrique du salon
    final servicesList = servicesAsync.value ?? <ServiceSalonModel>[];
    final filteredServices = servicesList.where((s) {
      if (!s.statut) return false;
      final matchesQuery = q.isEmpty ||
          s.nom.toLowerCase().contains(q) ||
          (s.description != null && s.description!.toLowerCase().contains(q)) ||
          (s.salonNom != null && s.salonNom!.toLowerCase().contains(q));
      if (!matchesQuery) return false;
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

    // Filtrage dynamique Produits par mot-clé et par rayon kilométrique du salon
    final produitsList = produitsAsync.value ?? <ProduitSalonModel>[];
    final filteredProduits = produitsList.where((p) {
      if (!p.statut) return false;
      final matchesQuery = q.isEmpty ||
          p.nom.toLowerCase().contains(q) ||
          (p.description != null && p.description!.toLowerCase().contains(q)) ||
          (p.categorieNom != null && p.categorieNom!.toLowerCase().contains(q)) ||
          (p.salonNom != null && p.salonNom!.toLowerCase().contains(q));
      if (!matchesQuery) return false;
      if (p.slugSalon != null && salonsState.salons.isNotEmpty) {
        final salon = salonsState.salons.firstWhere(
          (sal) => sal.slug == p.slugSalon,
          orElse: () => const SalonModel(id: 0, nom: '', slug: ''),
        );
        if (salon.id != 0) {
          final dist = _getSalonDistance(salon);
          return dist <= _selectedDistance;
        }
      }
      return true;
    }).toList();

    final totalCount = filteredSalons.length + filteredServices.length + filteredProduits.length;
    final isLoading = salonsState.isLoading || servicesAsync.isLoading || produitsAsync.isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ==============================================================
            // 1. BARRE SUPÉRIEURE DE RECHERCHE & FILTRE DISTANCE
            // ==============================================================
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  // Bouton retour circulaire marron Figma
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.figmaBrown,
                        shape: BoxShape.circle,
                        border: context.symmetricBorder(),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Champ de recherche direct en TextField
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontSize: context.fontSize(14),
                          fontWeight: FontWeight.w700,
                          color: context.adaptiveTextColor(),
                        ),
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                          hintText: 'Rechercher salon, service, produit...',
                          hintStyle: TextStyle(
                            color: context.adaptiveSubtextColor(),
                            fontSize: context.fontSize(13.5),
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: context.adaptiveSubtextColor(),
                                  ),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: AppColors.figmaActiveGold,
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Bouton de filtre distance dynamique
                  InkWell(
                    onTap: () => _afficherSelecteurDistance(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                        borderRadius: BorderRadius.circular(10),
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
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_selectedDistance km >',
                            style: TextStyle(
                              fontSize: context.fontSize(12.5),
                              fontWeight: FontWeight.w800,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sous-titre récapitulatif
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Text(
                isLoading
                    ? 'Recherche en cours...'
                    : '$totalCount résultat${totalCount > 1 ? 's' : ''} trouvé${totalCount > 1 ? 's' : ''}${queryText.isNotEmpty ? ' pour "$queryText"' : ''}',
                style: TextStyle(
                  color: context.adaptiveSubtextColor(),
                  fontSize: context.fontSize(12.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                thickness: 0.8,
              ),
            ),

            // ==============================================================
            // 2. PILLS DE FILTRES HORIZONTAUX DYNAMIQUES
            // ==============================================================
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterPill(index: 0, label: 'Tous ($totalCount)'),
                    const SizedBox(width: 10),
                    _buildFilterPill(index: 1, label: 'Salons (${filteredSalons.length})'),
                    const SizedBox(width: 10),
                    _buildFilterPill(index: 2, label: 'Services (${filteredServices.length})'),
                    const SizedBox(width: 10),
                    _buildFilterPill(index: 3, label: 'Produits (${filteredProduits.length})'),
                  ],
                ),
              ),
            ),

            // ==============================================================
            // 3. RÉSULTATS DÉTAILLÉS SCROLLABLES OU ÉTAT VIDE
            // ==============================================================
            Expanded(
              child: isLoading && totalCount == 0
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.figmaActiveGold),
                      ),
                    )
                  : totalCount == 0
                      ? _buildEmptyResultsState(queryText)
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            context.responsiveValue(compact: 70, standard: 80),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // A. SALONS CORRESPONDANTS
                              if ((_selectedPillIndex == 0 || _selectedPillIndex == 1) &&
                                  filteredSalons.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Salons correspondants (${filteredSalons.length})',
                                    style: TextStyle(
                                      fontSize: context.fontSize(16),
                                      fontWeight: FontWeight.w800,
                                      color: context.adaptiveTextColor(),
                                    ),
                                  ),
                                ),
                                for (int i = 0; i < filteredSalons.length; i++) ...[
                                  () {
                                    final salon = filteredSalons[i];
                                    final fallbackImg = 'assets/images/recherche_img_0.png';
                                    final imgUrl = salon.coverUrl ?? salon.logoUrl ?? fallbackImg;
                                    final ratingStr = salon.noteMoyenne > 0
                                        ? '★ ${salon.noteMoyenne.toStringAsFixed(1)} • ${salon.nombreAvis} avis'
                                        : '★ Nouveau';
                                    final distKm = _getSalonDistance(salon);
                                    final distStr = '${distKm.toStringAsFixed(1)} km';
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildSalonResultCard(
                                        index: i,
                                        imagePath: imgUrl,
                                        title: salon.nom,
                                        location: '$distStr • ${salon.adresse ?? 'Dakar'}',
                                        rating: ratingStr,
                                        onTap: () {
                                          setState(() => _selectedResultIndex = i);
                                          context.push('/salons/${salon.slug}');
                                        },
                                      ),
                                    );
                                  }(),
                                ],
                                const SizedBox(height: 8),
                              ],

                              // B. SERVICES & PRESTATIONS
                              if ((_selectedPillIndex == 0 || _selectedPillIndex == 2) &&
                                  filteredServices.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Services & Prestations (${filteredServices.length})',
                                    style: TextStyle(
                                      fontSize: context.fontSize(16),
                                      fontWeight: FontWeight.w800,
                                      color: context.adaptiveTextColor(),
                                    ),
                                  ),
                                ),
                                for (int i = 0; i < filteredServices.length; i++) ...[
                                  () {
                                    final s = filteredServices[i];
                                    final fallbackImg = 'assets/images/recherche_img_${(i % 2) + 1}.png';
                                    final imgUrl = s.imageUrl ?? fallbackImg;
                                    final subtitle = s.salonNom != null
                                        ? '${s.salonNom} • ${s.variantes.length} styles'
                                        : '${s.variantes.length} variantes disponibles';
                                    final price = s.minPrix > 0
                                        ? 'Dès ${s.minPrix.toInt()} FCFA'
                                        : 'Sur devis';

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildPrestationResultCard(
                                        index: 100 + i,
                                        imagePath: imgUrl,
                                        title: s.nom,
                                        subtitle: subtitle,
                                        price: price,
                                        onTap: () {
                                          setState(() => _selectedResultIndex = 100 + i);
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
                                        onReserver: () {
                                          final v = s.variantes.isNotEmpty ? s.variantes.first : null;
                                          final effectiveVarianteId = v?.id ?? s.id;
                                          final effectiveNom = v?.nom.isNotEmpty == true ? v!.nom : s.nom;
                                          final effectivePrix = v?.prix ?? (s.minPrix > 0 ? s.minPrix : 5000.0);
                                          final effectiveDuree = v?.dureeMinutes ?? 45;
                                          final effectiveImg = v?.mainImage ?? s.imageUrl;

                                          ref.read(rendezvousPanierProvider.notifier).ajouterPrestation(
                                            slugSalon: s.slugSalon ?? 'salon',
                                            salonNom: s.salonNom ?? 'Salon Partenaire',
                                            prestation: LignePrestationPanierModel(
                                              varianteId: effectiveVarianteId,
                                              serviceId: s.id,
                                              serviceNom: s.nom,
                                              varianteNom: effectiveNom,
                                              prix: effectivePrix,
                                              dureeMinutes: effectiveDuree,
                                              imageUrl: effectiveImg,
                                            ),
                                          );
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${s.nom} ajoutée au panier rendez-vous !'),
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
                                      ),
                                    );
                                  }(),
                                ],
                                const SizedBox(height: 8),
                              ],

                              // C. PRODUITS DISPONIBLES À PROXIMITÉ
                              if ((_selectedPillIndex == 0 || _selectedPillIndex == 3) &&
                                  filteredProduits.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Produits disponibles à proximité (${filteredProduits.length})',
                                    style: TextStyle(
                                      fontSize: context.fontSize(16),
                                      fontWeight: FontWeight.w800,
                                      color: context.adaptiveTextColor(),
                                    ),
                                  ),
                                ),
                                for (int i = 0; i < filteredProduits.length; i++) ...[
                                  () {
                                    final p = filteredProduits[i];
                                    final fallbackImg = 'assets/images/recherche_img_${(i % 2) + 3}.png';
                                    final imgUrl = p.mainImage ?? fallbackImg;
                                    final subtitle = p.salonNom != null
                                        ? 'Chez ${p.salonNom}'
                                        : (p.categorieNom ?? 'Produit de beauté');
                                    final price = '${p.prixVente.toInt()} FCFA';

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildProductResultCard(
                                        imagePath: imgUrl,
                                        title: p.nom,
                                        subtitle: subtitle,
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
                                          if (p.slugSalon != null) {
                                            ref.read(panierStateProvider.notifier).ajouterArticle(
                                              slugSalon: p.slugSalon!,
                                              salonNom: p.salonNom,
                                              produitId: p.id,
                                              produitNom: p.nom,
                                              prixUnitaire: p.prixVente,
                                              quantite: 1,
                                              imageUrl: p.mainImage,
                                            );
                                          }
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${p.nom} ajouté au panier !'),
                                              duration: const Duration(seconds: 2),
                                              backgroundColor: AppColors.figmaBrown,
                                              action: SnackBarAction(
                                                label: 'Voir',
                                                textColor: AppColors.figmaActiveGold,
                                                onPressed: () => context.push(RouteNames.panier),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }(),
                                ],
                              ],
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
  // HELPER : Filtre Pill (Tous, Salons, Services, Produits)
  // ==============================================================
  Widget _buildFilterPill({required int index, required String label}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedPillIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPillIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveValue(compact: 13.0, standard: 16.0),
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
              : (isDark ? AppColors.darkSurface : AppColors.figmaCardBg),
          borderRadius: BorderRadius.circular(20),
          border: context.symmetricBorder(isSelected: isSelected),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown),
            fontSize: context.fontSize(12.5),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // HELPER : Carte Salon
  // ==============================================================
  Widget _buildSalonResultCard({
    required int index,
    required String imagePath,
    required String title,
    required String location,
    required String rating,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedResultIndex == index;
    final imgSize = context.responsiveValue(compact: 64.0, standard: 72.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
          borderRadius: BorderRadius.circular(14),
          border: context.symmetricBorder(isSelected: isSelected),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(
                imagePath,
                width: imgSize,
                height: imgSize,
                fallbackAsset: 'assets/images/recherche_img_0.png',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.fontSize(14.5),
                      fontWeight: FontWeight.w800,
                      color: context.adaptiveTextColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.figmaActiveGold,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: context.fontSize(12),
                            fontWeight: FontWeight.w600,
                            color: AppColors.figmaActiveGold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rating,
                    style: TextStyle(
                      fontSize: context.fontSize(12),
                      fontWeight: FontWeight.w700,
                      color: AppColors.figmaActiveGold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveValue(compact: 10.0, standard: 14.0),
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Voir salon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.fontSize(12),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // HELPER : Carte Prestation
  // ==============================================================
  Widget _buildPrestationResultCard({
    required int index,
    required String imagePath,
    required String title,
    required String subtitle,
    required String price,
    required VoidCallback onTap,
    required VoidCallback onReserver,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedResultIndex == index;
    final imgSize = context.responsiveValue(compact: 58.0, standard: 64.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
          borderRadius: BorderRadius.circular(14),
          border: context.symmetricBorder(isSelected: isSelected),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(
                imagePath,
                width: imgSize,
                height: imgSize,
                fallbackAsset: 'assets/images/recherche_img_1.png',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    subtitle,
                    style: TextStyle(
                      fontSize: context.fontSize(11.5),
                      color: context.adaptiveSubtextColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      price,
                      style: TextStyle(
                        fontSize: context.fontSize(13.5),
                        fontWeight: FontWeight.w800,
                        color: AppColors.figmaActiveGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onReserver,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveValue(compact: 10.0, standard: 14.0),
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Réserver',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.fontSize(12),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // HELPER : Carte Produit
  // ==============================================================
  Widget _buildProductResultCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required String price,
    VoidCallback? onTap,
    required VoidCallback onAddToCart,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imgSize = context.responsiveValue(compact: 60.0, standard: 68.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
          borderRadius: BorderRadius.circular(14),
          border: context.symmetricBorder(),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(
                imagePath,
                width: imgSize,
                height: imgSize,
                fallbackAsset: 'assets/images/recherche_img_4.png',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    subtitle,
                    style: TextStyle(
                      fontSize: context.fontSize(11.5),
                      color: context.adaptiveSubtextColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      price,
                      style: TextStyle(
                        fontSize: context.fontSize(13.5),
                        fontWeight: FontWeight.w800,
                        color: AppColors.figmaActiveGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onAddToCart,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveValue(compact: 10.0, standard: 14.0),
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.figmaActiveGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '+ Panier',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.fontSize(12),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
    Widget placeholder() => Container(
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
            size: 24,
          ),
        );

    final cleanUrl = pathOrUrl.replaceAll('http://localhost:8080', 'http://10.0.2.2:8080');
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return Image.network(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => placeholder(),
      );
    } else if (cleanUrl.isNotEmpty && !cleanUrl.contains('accueil_img') && !cleanUrl.contains('detail_salon')) {
      return Image.asset(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => placeholder(),
      );
    } else {
      return placeholder();
    }
  }

  // ==============================================================
  // HELPER : État vide quand aucun résultat ne correspond
  // ==============================================================
  Widget _buildEmptyResultsState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.figmaActiveGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 38,
                color: AppColors.figmaActiveGold,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aucun résultat trouvé',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: context.adaptiveTextColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              query.isNotEmpty
                  ? 'Aucun salon, prestation ou produit ne correspond à "$query".'
                  : 'Aucune donnée disponible pour le moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.adaptiveSubtextColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
