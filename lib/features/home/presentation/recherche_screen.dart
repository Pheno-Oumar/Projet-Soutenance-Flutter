import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../../panier/presentation/providers/panier_provider.dart';

class RechercheScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const RechercheScreen({
    super.key,
    this.initialQuery,
  });

  @override
  ConsumerState<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends ConsumerState<RechercheScreen> {
  late final TextEditingController _searchController;
  int _selectedPillIndex = 0; // 0: Tous, 1: Salons, 2: Services, 3: Produits
  int? _selectedResultIndex; // Index de la carte cliquée

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? 'Tresses & Soins');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

                  // Champ de recherche direct en TextField (le rectangle lui-même EST le champ)
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : Colors.black,
                        ),
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                          hintText: 'Rechercher...',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                            fontSize: 13.5,
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
                                    color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                                  ),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.figmaActiveGold,
                              width: 1.4,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.figmaActiveGold,
                              width: 1.4,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.figmaActiveGold,
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Bouton de filtre distance (Sucette / Pin de localisation 📍 + 5 km >)
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                      borderRadius: BorderRadius.circular(10),
                      border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.figmaActiveGold,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '5 km >',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                          ),
                        ),
                      ],
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
                '18 résultats trouvés dans un rayon de 5 km',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: isDark ? AppColors.darkBorder : const Color(0xFFEBE5DF),
                thickness: 0.8,
              ),
            ),

            // ==============================================================
            // 2. PILLS DE FILTRES HORIZONTAUX (Scroll horizontal fluide)
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
                    _buildFilterPill(index: 0, label: 'Tous (18)'),
                    const SizedBox(width: 10),
                    _buildFilterPill(index: 1, label: 'Salons (4)'),
                    const SizedBox(width: 10),
                    _buildFilterPill(index: 2, label: 'Services (8)'),
                    const SizedBox(width: 10),
                    _buildFilterPill(index: 3, label: 'Produits (6)'),
                  ],
                ),
              ),
            ),

            // ==============================================================
            // 3. RÉSULTATS DÉTAILLÉS SCROLLABLES (100% Column & Row)
            // ==============================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. SALONS CORRESPONDANTS (4)
                    if (_selectedPillIndex == 0 || _selectedPillIndex == 1) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Salons correspondants (4)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : Colors.black,
                          ),
                        ),
                      ),
                      _buildSalonResultCard(
                        index: 0,
                        imagePath: 'assets/images/recherche_img_0.png',
                        title: 'Salon Beauty',
                        location: 'Dakar, Almadies • 1.2 km',
                        rating: '★ 4.9 • 8 coiffeurs dispo',
                        onTap: () {
                          setState(() => _selectedResultIndex = 0);
                          context.push('/salons/salon-beauty');
                        },
                      ),
                      const SizedBox(height: 18),
                    ],

                    // B. SERVICES & PRESTATIONS (8)
                    if (_selectedPillIndex == 0 || _selectedPillIndex == 2) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Services & Prestations (8)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : Colors.black,
                          ),
                        ),
                      ),
                      _buildPrestationResultCard(
                        index: 1,
                        imagePath: 'assets/images/recherche_img_1.png',
                        title: 'Tresses Box Braids Moyennes',
                        subtitle: 'Salon Beauty • Durée 1h 30 • 1.2 km',
                        price: '15 000 FCFA',
                        onTap: () => setState(() => _selectedResultIndex = 1),
                        onReserver: () => context.push(RouteNames.mesRendezVous),
                      ),
                      const SizedBox(height: 12),
                      _buildPrestationResultCard(
                        index: 2,
                        imagePath: 'assets/images/recherche_img_2.png',
                        title: 'Soin Nourrissant Anti-casse',
                        subtitle: 'Hair & Prestige • Durée 45m • 3.4 km',
                        price: '12 000 FCFA',
                        onTap: () => setState(() => _selectedResultIndex = 2),
                        onReserver: () => context.push(RouteNames.mesRendezVous),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // C. PRODUITS DISPONIBLES À PROXIMITÉ (6)
                    if (_selectedPillIndex == 0 || _selectedPillIndex == 3) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Produits disponibles à proximité (6)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : Colors.black,
                          ),
                        ),
                      ),
                      _buildProductResultCard(
                        imagePath: 'assets/images/recherche_img_4.png',
                        title: 'Care - Soin Capillaire 250ml',
                        subtitle: 'Au Salon Beauty (1.2 km)',
                        price: '12 500 FCFA',
                        onAddToCart: () {
                          ref.read(localPanierCountProvider.notifier).state++;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produit ajouté au panier !'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildProductResultCard(
                        imagePath: 'assets/images/recherche_img_3.png',
                        title: 'Huile de Ricin Pure 100ml',
                        subtitle: 'Chez Glow Beauty (4.1 km)',
                        price: '5 000 FCFA',
                        onAddToCart: () {
                          ref.read(localPanierCountProvider.notifier).state++;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produit ajouté au panier !'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
              : (isDark ? AppColors.darkSurface : AppColors.figmaCardBg),
          borderRadius: BorderRadius.circular(20),
          border: isDark && !isSelected
              ? Border.all(color: AppColors.darkBorder)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // HELPER : Carte Salon (100% Container & Row)
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.figmaActiveGold
                : (isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF)),
            width: isSelected ? 1.5 : 0.9,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : Colors.black,
                    ),
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
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.figmaActiveGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.figmaActiveGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Voir salon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
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
  // HELPER : Carte Prestation (100% Container & Row)
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.figmaActiveGold
                : (isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF)),
            width: isSelected ? 1.5 : 0.9,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
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
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.figmaActiveGold,
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Réserver',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
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
  // HELPER : Carte Produit (100% Container & Row)
  // ==============================================================
  Widget _buildProductResultCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required String price,
    required VoidCallback onAddToCart,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
          width: 0.9,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
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
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.figmaActiveGold,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.figmaActiveGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '+ Panier',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
