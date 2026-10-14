import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class LireRealisationScreen extends StatefulWidget {
  final int initialIndex;
  final String salonName;
  final String initials;
  final String salonSlug;

  const LireRealisationScreen({
    super.key,
    this.initialIndex = 0,
    this.salonName = 'Beauty By Dika',
    this.initials = 'BD',
    this.salonSlug = 'beauty-by-dika',
  });

  @override
  State<LireRealisationScreen> createState() => _LireRealisationScreenState();
}

class _LireRealisationScreenState extends State<LireRealisationScreen> {
  late final PageController _pageController;
  final TextEditingController _commentController = TextEditingController();

  final Set<int> _likedIndexes = {};
  final Set<int> _savedIndexes = {};
  final Set<String> _followedSalons = {};

  final List<Map<String, dynamic>> _reels = [
    {
      'image': 'assets/images/lire_realisation_img_0.jpeg',
      'title': 'Tresse africaine avec chignon',
      'desc': 'Un look élégant et intemporel, parfait pour toutes les occasions.',
      'likes': '12,4K',
      'comments': '342',
      'saves': '1,8K',
    },
    {
      'image': 'assets/images/realisation_img_1.png',
      'title': 'Box Braids Sculptées',
      'desc': 'Tresses protectrices soignées avec finitions dorées éclatantes.',
      'likes': '8,7K',
      'comments': '184',
      'saves': '920',
    },
    {
      'image': 'assets/images/realisation_img_2.png',
      'title': 'Dégradé Homme Prestige',
      'desc': 'Coupe précise et contours soignés avec traçage barbe impeccable.',
      'likes': '15,2K',
      'comments': '512',
      'saves': '2,4K',
    },
    {
      'image': 'assets/images/realisation_img_3.png',
      'title': 'Soins Kératine & Brushing',
      'desc': 'Soin lissant régénérant pour une brillance absolue et un toucher soyeux.',
      'likes': '9,6K',
      'comments': '248',
      'saves': '1,1K',
    },
    {
      'image': 'assets/images/realisation_img_4.png',
      'title': 'Knotless Braids Chic',
      'desc': 'Tresses sans nœuds ultra légères et confortables au quotidien.',
      'likes': '11,9K',
      'comments': '390',
      'saves': '1,5K',
    },
    {
      'image': 'assets/images/realisation_img_5.png',
      'title': 'Tissage Naturel Ondulé',
      'desc': 'Volume et longueur avec intégration invisible et maintien longue durée.',
      'likes': '7,4K',
      'comments': '160',
      'saves': '830',
    },
    {
      'image': 'assets/images/realisation_img_6.png',
      'title': 'Balayage Doré Lumineux',
      'desc': 'Éclaircissement délicat et naturel sublimant les reflets au soleil.',
      'likes': '18,3K',
      'comments': '670',
      'saves': '3,1K',
    },
    {
      'image': 'assets/images/realisation_img_7.png',
      'title': 'Nattes Collées Graphiques',
      'desc': 'Motifs géométriques travaillés pour un style afro-chic affirmé.',
      'likes': '10,7K',
      'comments': '295',
      'saves': '1,4K',
    },
    {
      'image': 'assets/images/realisation_img_8.png',
      'title': 'Coiffure Mariage Glamour',
      'desc': 'Chignon sophistiqué orné pour les plus beaux événements.',
      'likes': '6,8K',
      'comments': '142',
      'saves': '670',
    },
  ];

  @override
  void initState() {
    super.initState();
    final clampedIndex = widget.initialIndex.clamp(0, _reels.length - 1);
    _pageController = PageController(initialPage: clampedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _openSalonProfile() {
    // Ouvre la page du salon directement sur l'onglet Réalisations (tab=2)
    context.push('/salons/${widget.salonSlug}?tab=2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==============================================================
          // 1. DÉFILEMENT VERTICAL DES RÉALISATIONS DU SALON (PageView)
          // ==============================================================
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            itemBuilder: (context, index) {
              final item = _reels[index];
              final isLiked = _likedIndexes.contains(index);
              final isSaved = _savedIndexes.contains(index);
              final isFollowed = _followedSalons.contains(widget.salonSlug);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Photo / Vidéo plein écran
                  Image.asset(
                    item['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF1F1A18),
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
                    bottom: 105,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar du salon avec bouton "+"
                        GestureDetector(
                          onTap: _openSalonProfile,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.figmaActiveGold,
                                    width: 1.8,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/detail_img_1.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: const Color(0xFF2E1C15),
                                      alignment: Alignment.center,
                                      child: Text(
                                        widget.initials,
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
                                        _followedSalons.add(widget.salonSlug);
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
                          icon: isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_rounded,
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

                        // Bouton Enregistrer / Favori (Bookmark)
                        _buildActionButton(
                          icon: isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_rounded,
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
                                content: Text('Lien de la réalisation copié !'),
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
                    bottom: 102,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom du salon avec pastille avatar
                        GestureDetector(
                          onTap: _openSalonProfile,
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
                                  widget.initials,
                                  style: const TextStyle(
                                    color: AppColors.figmaActiveGold,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.salonName,
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
          // 2. BOUTON RETOUR EN HAUT À GAUCHE (Fidèle à lire realisation.svg)
          // ==============================================================
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==============================================================
          // 3. CHAMP DE COMMENTAIRE EN BAS (Fidèle à lire realisation.svg)
          // Le rectangle EST le TextField avec son suffixIcon emoji
          // ==============================================================
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  cursorColor: AppColors.figmaActiveGold,
                  decoration: InputDecoration(
                    hintText: 'Ajouter un commentaire...',
                    hintStyle: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.16),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: AppColors.figmaActiveGold,
                        width: 1.2,
                      ),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sélecteur d\'emojis 😊'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        color: Colors.white70,
                        size: 22,
                      ),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Commentaire publié !'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      _commentController.clear();
                    }
                  },
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
                        child: Text('A', style: TextStyle(color: Colors.white)),
                      ),
                      title: Text(
                        'Aminata',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextPrimary : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Incroyable travail, les tresses sont parfaites ! 😍',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : Colors.black87,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFD4A373),
                        child: Text('F', style: TextStyle(color: Colors.white)),
                      ),
                      title: Text(
                        'Fanta',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextPrimary : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Combien de temps ça a pris ? Magnifique !',
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
