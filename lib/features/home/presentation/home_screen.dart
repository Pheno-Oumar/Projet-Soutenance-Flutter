import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../../panier/presentation/providers/panier_provider.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      context.push('${RouteNames.recherche}?q=${Uri.encodeComponent(trimmed)}');
    } else {
      context.push(RouteNames.recherche);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      // Bouton flottant de l'Assistant IA avec l'icône exacte Figma (bulle avec 3 points)
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.assistantChat),
        backgroundColor: AppColors.figmaActiveGold,
        elevation: 5,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.sms_rounded, // Bulle avec les 3 points exactement comme sur le SVG Figma
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
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ==============================================================
              // 1. CARROUSEL DES STORIES / SALONS (Scroll horizontal fluide)
              // ==============================================================
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildStoryItem(
                      index: 0,
                      label: 'SB',
                      sublabel: 'Story',
                      isSpecialStory: true,
                      bgColor: const Color(0xFF3D291F),
                      onTap: () {
                        setState(() => _selectedStoryIndex = 0);
                        context.push('${RouteNames.story}?salon=Salon Beauty&initials=SB');
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildStoryItem(
                      index: 1,
                      label: 'H&C',
                      sublabel: 'Hair & Co',
                      bgColor: const Color(0xFF242B35),
                      onTap: () {
                        setState(() => _selectedStoryIndex = 1);
                        context.push('${RouteNames.story}?salon=Hair & Co&initials=H&C');
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildStoryItem(
                      index: 2,
                      label: 'GLOW',
                      sublabel: 'Glow Beauty',
                      bgColor: const Color(0xFF3D291F),
                      onTap: () {
                        setState(() => _selectedStoryIndex = 2);
                        context.push('${RouteNames.story}?salon=Glow Beauty&initials=GLOW');
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildStoryItem(
                      index: 3,
                      label: 'KADY',
                      sublabel: "Kady's Hair",
                      bgColor: const Color(0xFF2B1A22),
                      onTap: () {
                        setState(() => _selectedStoryIndex = 3);
                        context.push("${RouteNames.story}?salon=Kady's Hair&initials=KADY");
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildStoryItem(
                      index: 4,
                      label: 'ATELIER',
                      sublabel: 'Atelier Afro',
                      bgColor: const Color(0xFF1A1E24),
                      onTap: () {
                        setState(() => _selectedStoryIndex = 4);
                        context.push('${RouteNames.story}?salon=Atelier Afro&initials=ATELIER');
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildStoryItem(
                      index: 5,
                      label: 'CHIC',
                      sublabel: 'Chic Hair',
                      bgColor: const Color(0xFF321E30),
                      onTap: () {
                        setState(() => _selectedStoryIndex = 5);
                        context.push('${RouteNames.story}?salon=Chic Hair&initials=CHIC');
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildStoryItem(
                      index: 6,
                      label: 'AFRO',
                      sublabel: 'Afro Reine',
                      bgColor: const Color(0xFF2E241E),
                      onTap: () {
                        setState(() => _selectedStoryIndex = 6);
                        context.push('${RouteNames.story}?salon=Afro Reine&initials=AFRO');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ==============================================================
              // 2. TEXTFIELD DE RECHERCHE & SÉLECTEUR DE DISTANCE (Figma)
              // Le rectangle lui-même EST le TextField (pas de Container imbriqué)
              // ==============================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Le champ TextField est directement le rectangle stylé avec son placeholder
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

                    // Sélecteur de distance (Sucette / Pin de géolocalisation 📍 + 5 km + flèche)
                    InkWell(
                      onTap: () => _onSearchSubmitted(_searchController.text),
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
                            // Sucette / Pin de localisation 📍
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.figmaActiveGold,
                              size: 17,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '5 km',
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
              // 3. MEILLEURS SALONS (Hauteur réduite selon Figma, Scroll fluide)
              // ==============================================================
              _buildSectionHeader(
                title: 'Meilleurs Salons',
                actionLabel: 'Voir tout',
                onActionTap: () => context.go(RouteNames.salons),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildSalonCard(
                      index: 0,
                      imagePath: 'assets/images/accueil_img_0.png',
                      rating: '4.9',
                      title: 'Salon Beauty',
                      location: 'Almadies • 1.2 km',
                      onTap: () {
                        setState(() => _selectedSalonIndex = 0);
                        context.push('/salons/salon-beauty');
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildSalonCard(
                      index: 1,
                      imagePath: 'assets/images/accueil_img_1.png',
                      rating: '4.8',
                      title: 'Hair & Prestige',
                      location: 'Plateau • 3.4 km',
                      onTap: () {
                        setState(() => _selectedSalonIndex = 1);
                        context.push('/salons/hair-prestige');
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildSalonCard(
                      index: 2,
                      imagePath: 'assets/images/accueil_img_2.png',
                      rating: '4.7',
                      title: "Kady's Prestige",
                      location: 'Mermoz • 2.1 km',
                      onTap: () {
                        setState(() => _selectedSalonIndex = 2);
                        context.push('/salons/kadys-prestige');
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildSalonCard(
                      index: 3,
                      imagePath: 'assets/images/accueil_img_0.png',
                      rating: '4.9',
                      title: 'Glow & Glamour',
                      location: 'Fann • 2.8 km',
                      onTap: () {
                        setState(() => _selectedSalonIndex = 3);
                        context.push('/salons/glow-glamour');
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildSalonCard(
                      index: 4,
                      imagePath: 'assets/images/accueil_img_1.png',
                      rating: '4.6',
                      title: 'Afro Chic Studio',
                      location: 'Ngor • 4.1 km',
                      onTap: () {
                        setState(() => _selectedSalonIndex = 4);
                        context.push('/salons/afro-chic');
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildSalonCard(
                      index: 5,
                      imagePath: 'assets/images/accueil_img_2.png',
                      rating: '4.8',
                      title: "L'Atelier Capillaire",
                      location: 'Point E • 1.8 km',
                      onTap: () {
                        setState(() => _selectedSalonIndex = 5);
                        context.push('/salons/latelier-capillaire');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==============================================================
              // 4. MEILLEURS SERVICES (Hauteur compacte 52px, bordure au clic)
              // ==============================================================
              _buildSectionHeader(
                title: 'Meilleurs Services',
                actionLabel: 'Explorer',
                onActionTap: () => context.push(RouteNames.recherche),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildServiceCard(
                      index: 0,
                      title: 'Tresses',
                      subtitle: '+45 styles',
                      onTap: () {
                        setState(() => _selectedServiceIndex = 0);
                        context.push('${RouteNames.recherche}?q=Tresses');
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildServiceCard(
                      index: 1,
                      title: 'Soins profonds',
                      subtitle: 'Kératine, bains',
                      onTap: () {
                        setState(() => _selectedServiceIndex = 1);
                        context.push('${RouteNames.recherche}?q=Soins');
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildServiceCard(
                      index: 2,
                      title: 'Coloration',
                      subtitle: 'Balayage doré',
                      onTap: () {
                        setState(() => _selectedServiceIndex = 2);
                        context.push('${RouteNames.recherche}?q=Coloration');
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildServiceCard(
                      index: 3,
                      title: 'Nattes Collées',
                      subtitle: '+30 modèles',
                      onTap: () {
                        setState(() => _selectedServiceIndex = 3);
                        context.push('${RouteNames.recherche}?q=Nattes');
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildServiceCard(
                      index: 4,
                      title: 'Brushing & Blowout',
                      subtitle: 'Lissage soyeux',
                      onTap: () {
                        setState(() => _selectedServiceIndex = 4);
                        context.push('${RouteNames.recherche}?q=Brushing');
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildServiceCard(
                      index: 5,
                      title: 'Coupe & Barbe',
                      subtitle: 'Finitions nettes',
                      onTap: () {
                        setState(() => _selectedServiceIndex = 5);
                        context.push('${RouteNames.recherche}?q=Barbe');
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildServiceCard(
                      index: 6,
                      title: 'Perruques & Pose',
                      subtitle: 'Pose invisible',
                      onTap: () {
                        setState(() => _selectedServiceIndex = 6);
                        context.push('${RouteNames.recherche}?q=Perruques');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==============================================================
              // 5. MEILLEURES PRESTATIONS RÉALISÉES (Hauteur compacte)
              // ==============================================================
              _buildSectionHeader(
                title: 'Meilleures Prestations Réalisées',
                actionLabel: 'Voir tout',
                onActionTap: () => context.push(RouteNames.recherche),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildPrestationCard(
                      index: 0,
                      imagePath: 'assets/images/accueil_img_3.png',
                      title: 'Box Braids & Perles',
                      stylist: 'Fatou S. • 1h 30m',
                      price: '15 000 FCFA',
                      onTap: () => setState(() => _selectedPrestationIndex = 0),
                      onReserver: () => context.push(RouteNames.mesRendezVous),
                    ),
                    const SizedBox(width: 12),
                    _buildPrestationCard(
                      index: 1,
                      imagePath: 'assets/images/accueil_img_4.png',
                      title: 'Soin Kératine Intense',
                      stylist: 'Mariam • 1h 15m',
                      price: '22 000 FCFA',
                      onTap: () => setState(() => _selectedPrestationIndex = 1),
                      onReserver: () => context.push(RouteNames.mesRendezVous),
                    ),
                    const SizedBox(width: 12),
                    _buildPrestationCard(
                      index: 2,
                      imagePath: 'assets/images/recherche_img_2.png',
                      title: 'Knotless Braids Bohèmes',
                      stylist: 'Aïcha • 2h 00m',
                      price: '18 000 FCFA',
                      onTap: () => setState(() => _selectedPrestationIndex = 2),
                      onReserver: () => context.push(RouteNames.mesRendezVous),
                    ),
                    const SizedBox(width: 12),
                    _buildPrestationCard(
                      index: 3,
                      imagePath: 'assets/images/recherche_img_3.png',
                      title: 'Tissage Ouvert Ondulé',
                      stylist: 'Salimata • 1h 45m',
                      price: '25 000 FCFA',
                      onTap: () => setState(() => _selectedPrestationIndex = 3),
                      onReserver: () => context.push(RouteNames.mesRendezVous),
                    ),
                    const SizedBox(width: 12),
                    _buildPrestationCard(
                      index: 4,
                      imagePath: 'assets/images/accueil_img_4.png',
                      title: 'Lissage Brésilien Premium',
                      stylist: 'Kady • 2h 30m',
                      price: '35 000 FCFA',
                      onTap: () => setState(() => _selectedPrestationIndex = 4),
                      onReserver: () => context.push(RouteNames.mesRendezVous),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==============================================================
              // 6. MEILLEURS PRODUITS EN VENTE (Avec bouton Ajouter au Panier Figma)
              // ==============================================================
              _buildSectionHeader(
                title: 'Meilleurs Produits en Vente',
                actionLabel: null,
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildProductCard(
                      imagePath: 'assets/images/accueil_img_5.png',
                      title: 'Care Soin 250ml',
                      category: 'Soin capillaire',
                      price: '12 500 F',
                      onAddToCart: () {
                        ref.read(localPanierCountProvider.notifier).state++;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Care Soin 250ml ajouté au panier !'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildProductCard(
                      imagePath: 'assets/images/accueil_img_6.png',
                      title: 'Huile de Ricin Pure',
                      category: 'Pure 100ml',
                      price: '5 000 F',
                      onAddToCart: () {
                        ref.read(localPanierCountProvider.notifier).state++;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Huile de Ricin ajoutée au panier !'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildProductCard(
                      imagePath: 'assets/images/recherche_img_4.png',
                      title: 'Masque Karité & Coco',
                      category: 'Bio 300g',
                      price: '8 500 F',
                      onAddToCart: () {
                        ref.read(localPanierCountProvider.notifier).state++;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Masque Karité & Coco ajouté au panier !'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildProductCard(
                      imagePath: 'assets/images/accueil_img_5.png',
                      title: 'Sérum Anti-Casse',
                      category: 'Élixir 50ml',
                      price: '14 000 F',
                      onAddToCart: () {
                        ref.read(localPanierCountProvider.notifier).state++;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sérum Anti-Casse ajouté au panier !'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildProductCard(
                      imagePath: 'assets/images/accueil_img_6.png',
                      title: 'Spray Hydratant Aloé',
                      category: 'Brume 200ml',
                      price: '7 000 F',
                      onAddToCart: () {
                        ref.read(localPanierCountProvider.notifier).state++;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Spray Hydratant Aloé ajouté au panier !'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
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
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    bool isSpecialStory = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedStoryIndex == index;
    final borderColor = isSelected
        ? AppColors.figmaActiveGold
        : (isSpecialStory ? AppColors.figmaBadgeGold : const Color(0xFFD4AF37));

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
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ? 2.5 : 2,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSpecialStory ? AppColors.figmaBadgeGold : Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (isSpecialStory)
                Positioned(
                  bottom: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.figmaBadgePink,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'STORY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            sublabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // HELPER : Carte Meilleurs Salons (Hauteur réduite ~120px)
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaCardBg,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.figmaActiveGold, width: 1.5)
              : (isDark ? Border.all(color: AppColors.darkBorder, width: 1) : null),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image salon avec badge rating
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    imagePath,
                    width: 165,
                    height: 75, // Réduit de 105 à 75 selon Figma
                    fit: BoxFit.cover,
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

            // Textes sous l'image
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : Colors.black,
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
                            color: isDark ? AppColors.darkTextSecondary : Colors.black54,
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
  // HELPER : Carte Meilleurs Services (Hauteur compacte ~52px)
  // ==============================================================
  Widget _buildServiceCard({
    required int index,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedServiceIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 125,
        height: 56, // Ajusté à 56px pour supprimer l'overflow de 1px tout en restant très compact
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaCardBg,
          borderRadius: BorderRadius.circular(10),
          // La bordure ne s'affiche que si l'utilisateur a cliqué sur la carte !
          border: isSelected
              ? Border.all(color: AppColors.figmaActiveGold, width: 1.5)
              : (isDark ? Border.all(color: AppColors.darkBorder, width: 1) : null),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.figmaActiveGold : (isDark ? AppColors.darkTextSecondary : Colors.black45),
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
  // HELPER : Carte Prestation Réalisée (Hauteur compacte)
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 172,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.figmaCardBg,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.figmaActiveGold, width: 1.5)
              : (isDark ? Border.all(color: AppColors.darkBorder, width: 1) : null),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imagePath,
                width: 172,
                height: 80, // Réduit de 105 à 80
                fit: BoxFit.cover,
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
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    stylist,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          price,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.figmaActiveGold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
  // HELPER : Carte Produit en Vente (Avec bouton Ajouter au Panier Figma)
  // ==============================================================
  Widget _buildProductCard({
    required String imagePath,
    required String title,
    required String category,
    required String price,
    required VoidCallback onAddToCart,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 175,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.figmaCardBg,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.darkBorder, width: 1) : null,
      ),
      child: Column(
        children: [
          // Ligne visuel + infos produit
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.figmaActiveGold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Bouton doré officiel Figma "+ Ajouter au panier"
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_shopping_cart_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Ajouter au panier',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}
