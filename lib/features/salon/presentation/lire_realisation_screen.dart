import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'providers/salon_provider.dart';
import '../data/models/realisation_salon_model.dart';

class LireRealisationScreen extends ConsumerStatefulWidget {
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
  ConsumerState<LireRealisationScreen> createState() => _LireRealisationScreenState();
}

class _LireRealisationScreenState extends ConsumerState<LireRealisationScreen> {
  late final PageController _pageController;
  final TextEditingController _commentController = TextEditingController();

  final Set<int> _likedIndexes = {};
  final Set<int> _savedIndexes = {};
  final Set<String> _followedSalons = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
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
    final realisationsAsync = ref.watch(salonRealisationsProvider(widget.salonSlug));
    final dynamicReels = realisationsAsync.valueOrNull ?? [];
    final fallbackTransversales = ref.watch(realisationsTransversalesProvider).valueOrNull ?? [];
    final activeList = dynamicReels.isNotEmpty
        ? dynamicReels
        : (widget.salonSlug.isEmpty ? fallbackTransversales : <RealisationSalonModel>[]);

    final reelsList = activeList.map((r) {
      final viewsFormatted = r.totalVues >= 1000
          ? '${(r.totalVues / 1000).toStringAsFixed(1).replaceAll('.', ',')}K'
          : '${r.totalVues}';
      final likesFormatted = r.totalLikes >= 1000
          ? '${(r.totalLikes / 1000).toStringAsFixed(1).replaceAll('.', ',')}K'
          : '${r.totalLikes}';
      return {
        'image': r.urlVideo ?? 'assets/images/lire_realisation_img_0.jpeg',
        'title': r.titre,
        'desc': r.description ?? 'Prestation réalisée avec soin.',
        'likes': likesFormatted,
        'comments': '${r.totalCommentaires}',
        'saves': viewsFormatted,
      };
    }).toList();

    if (reelsList.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.salonName, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.video_library_outlined, size: 64, color: Colors.white38),
                const SizedBox(height: 16),
                const Text(
                  'Aucune réalisation disponible',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ce salon n\'a pas encore publié de vidéo ou look dans sa vitrine.',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.figmaActiveGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
            itemCount: reelsList.length,
            itemBuilder: (context, index) {
              final item = reelsList[index];
              final isLiked = _likedIndexes.contains(index);
              final isSaved = _savedIndexes.contains(index);
              final isFollowed = _followedSalons.contains(widget.salonSlug);
              final imgPath = item['image'] as String;
              final isNetwork = imgPath.startsWith('http');

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Photo / Vidéo plein écran
                  if (isNetwork)
                    Image.network(
                      imgPath,
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
                    )
                  else
                    Image.asset(
                      imgPath,
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
