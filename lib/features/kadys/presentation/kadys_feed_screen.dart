import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';

class KadysFeedScreen extends ConsumerStatefulWidget {
  const KadysFeedScreen({super.key});

  @override
  ConsumerState<KadysFeedScreen> createState() => _KadysFeedScreenState();
}

class _KadysFeedScreenState extends ConsumerState<KadysFeedScreen> {
  // 0 = Suivis, 1 = Pour Toi
  int _activeTopTab = 1;
  final PageController _pageController = PageController();

  final Set<int> _likedIndexes = {};
  final Set<int> _savedIndexes = {};
  final Set<String> _followedSalons = {};

  final List<Map<String, dynamic>> _feedItems = [
    {
      'image': 'assets/images/kadys_img_0.jpeg',
      'salonName': 'Salon Beauty',
      'salonSlug': 'beauty-by-dika',
      'initials': 'SB',
      'logo': 'assets/images/detail_img_1.jpg',
      'title': 'Tresse africaine avec chignon',
      'desc': 'Un look élégant et intemporel, parfait pour toutes les occasions.',
      'likes': '12,4K',
      'comments': '342',
      'saves': '1,8K',
    },
    {
      'image': 'assets/images/realisation_img_1.png',
      'salonName': 'Beauty By Dika',
      'salonSlug': 'beauty-by-dika',
      'initials': 'BD',
      'logo': 'assets/images/detail_img_1.jpg',
      'title': 'Box Braids Sculptées',
      'desc': 'Tresses protectrices soignées avec finitions dorées éclatantes.',
      'likes': '8,7K',
      'comments': '184',
      'saves': '920',
    },
    {
      'image': 'assets/images/realisation_img_2.png',
      'salonName': 'Barber Shop Kalaban',
      'salonSlug': 'beauty-by-dika',
      'initials': 'BK',
      'logo': 'assets/images/salons_img_2.jpg',
      'title': 'Dégradé Homme Prestige',
      'desc': 'Coupe précise et contours soignés avec traçage barbe impeccable.',
      'likes': '15,2K',
      'comments': '512',
      'saves': '2,4K',
    },
    {
      'image': 'assets/images/realisation_img_4.png',
      'salonName': 'Coiffure Afro Chic',
      'salonSlug': 'beauty-by-dika',
      'initials': 'AC',
      'logo': 'assets/images/salons_img_3.jpg',
      'title': 'Knotless Braids Chic',
      'desc': 'Tresses sans nœuds ultra légères et confortables au quotidien.',
      'likes': '11,9K',
      'comments': '390',
      'saves': '1,5K',
    },
    {
      'image': 'assets/images/realisation_img_6.png',
      'salonName': 'Salon Élégance',
      'salonSlug': 'beauty-by-dika',
      'initials': 'SE',
      'logo': 'assets/images/salons_img_4.jpg',
      'title': 'Balayage Doré Lumineux',
      'desc': 'Éclaircissement délicat et naturel sublimant les reflets au soleil.',
      'likes': '18,3K',
      'comments': '670',
      'saves': '3,1K',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToSalonRealizations(String slug) {
    // Si on clique sur le logo du salon, une nouvelle page s'affiche pour voir la liste des réalisations de ce salon !
    context.push('/salons/$slug?tab=2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==============================================================
          // 1. FLUX VERTICAL VIDÉOS / RÉALISATIONS KADY'S (PageView)
          // ==============================================================
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _feedItems.length,
            itemBuilder: (context, index) {
              final item = _feedItems[index];
              final isLiked = _likedIndexes.contains(index);
              final isSaved = _savedIndexes.contains(index);
              final salonSlug = item['salonSlug'] as String;
              final isFollowed = _followedSalons.contains(salonSlug);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Photo / Vidéo plein écran
                  Image.asset(
                    item['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF151515),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white38,
                        size: 72,
                      ),
                    ),
                  ),

                  // Dégradé sombre au bas pour la lisibilité
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 280,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.90),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Colonne d'actions TikTok à droite
                  Positioned(
                    right: 12,
                    bottom: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar du salon avec bouton "+" (Clic -> Liste des réalisations du salon)
                        GestureDetector(
                          onTap: () => _navigateToSalonRealizations(salonSlug),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.figmaActiveGold,
                                    width: 1.8,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    item['logo'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: const Color(0xFF2E1C15),
                                      alignment: Alignment.center,
                                      child: Text(
                                        item['initials'] as String,
                                        style: const TextStyle(
                                          color: AppColors.figmaActiveGold,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (!isFollowed)
                                Positioned(
                                  bottom: -6,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _followedSalons.add(salonSlug);
                                      });
                                    },
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFE91E63),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Bouton J'aime (Heart)
                        _buildActionButton(
                          icon: Icons.favorite_rounded,
                          color: isLiked ? const Color(0xFFE53935) : Colors.white,
                          label: item['likes'] as String,
                          onTap: () {
                            setState(() {
                              if (isLiked) {
                                _likedIndexes.remove(index);
                              } else {
                                _likedIndexes.add(index);
                              }
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Bouton Commentaires (Chat bubble)
                        _buildActionButton(
                          icon: Icons.chat_bubble_rounded,
                          color: Colors.white,
                          label: item['comments'] as String,
                          onTap: () => _showCommentsBottomSheet(context),
                        ),

                        const SizedBox(height: 16),

                        // Bouton Favori (Bookmark)
                        _buildActionButton(
                          icon: Icons.bookmark_rounded,
                          color: isSaved
                              ? AppColors.figmaActiveGold
                              : Colors.white,
                          label: item['saves'] as String,
                          onTap: () {
                            setState(() {
                              if (isSaved) {
                                _savedIndexes.remove(index);
                              } else {
                                _savedIndexes.add(index);
                              }
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Bouton Partager
                        _buildActionButton(
                          icon: Icons.reply_rounded,
                          color: Colors.white,
                          label: 'Partager',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lien copié dans le presse-papier !'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Informations du salon et de la coiffure (Bas gauche)
                  Positioned(
                    left: 16,
                    right: 85,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo + Nom du salon (Clic -> Liste des réalisations du salon)
                        GestureDetector(
                          onTap: () => _navigateToSalonRealizations(salonSlug),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF2E1C15),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  item['initials'] as String,
                                  style: const TextStyle(
                                    color: AppColors.figmaActiveGold,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item['salonName'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Titre de la réalisation
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Description de la réalisation
                        Text(
                          item['desc'] as String,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // ==============================================================
          // 2. BARRE SUPÉRIEURE (Suivis / Pour Toi + Recherche 🔍)
          // ==============================================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 32), // Équilibre la barre

                    // Boutons Suivis & Pour Toi au centre
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeTopTab = 0;
                              });
                            },
                            child: Text(
                              'Suivis',
                              style: TextStyle(
                                color: _activeTopTab == 0
                                    ? Colors.white
                                    : Colors.white60,
                                fontSize: 16,
                                fontWeight: _activeTopTab == 0
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeTopTab = 1;
                              });
                            },
                            child: Text(
                              'Pour Toi',
                              style: TextStyle(
                                color: _activeTopTab == 1
                                    ? Colors.white
                                    : Colors.white60,
                                fontSize: 17,
                                fontWeight: _activeTopTab == 1
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Icône de recherche 🔍 en haut à droite
                    GestureDetector(
                      onTap: () => context.push(RouteNames.recherche),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 26,
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 380,
          child: Column(
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
              const SizedBox(height: 12),
              Text(
                'Commentaires (342)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF5C3826),
                        child: Text('M', style: TextStyle(color: Colors.white)),
                      ),
                      title: Text(
                        'Mariam Diallo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextPrimary : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'J\'adore ce style ! Quelle coiffeuse a fait ça ? 🔥',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : Colors.black87,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFD4A373),
                        child: Text('B', style: TextStyle(color: Colors.white)),
                      ),
                      title: const Text(
                        'Beauty By Dika',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.figmaActiveGold,
                        ),
                      ),
                      subtitle: Text(
                        'C\'est notre fondatrice Dika ! Rendez-vous disponible au salon 🌸',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
