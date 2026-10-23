import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routing/route_names.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../data/kadys_repository.dart';
import '../data/models/kadys_model.dart';
import 'providers/kadys_provider.dart';

class KadysFeedScreen extends ConsumerStatefulWidget {
  const KadysFeedScreen({super.key});

  @override
  ConsumerState<KadysFeedScreen> createState() => _KadysFeedScreenState();
}

class _KadysFeedScreenState extends ConsumerState<KadysFeedScreen> {
  // 0 = Suivis, 1 = Pour Toi
  int _activeTopTab = 1;
  final PageController _pageController = PageController();

  final Set<int> _savedIds = {};
  final Set<String> _followedSalons = {};

  // Fallback de secours si le backend est injoignable
  final List<KadysModel> _fallbackItems = const [
    KadysModel(
      id: 1,
      titre: 'Tresse africaine avec chignon',
      description: 'Un look élégant et intemporel, parfait pour toutes les occasions.',
      urlVideo: 'https://images.unsplash.com/photo-1580618672591-eb180b1a973f?w=800&auto=format&fit=crop&q=80',
      salonNom: 'Salon Beauty',
      salonSlug: 'beauty-by-dika',
      salonLogoUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500&auto=format&fit=crop&q=80',
      totalLikes: 12400,
      totalCommentaires: 342,
      totalVues: 18000,
    ),
    KadysModel(
      id: 2,
      titre: 'Box Braids Sculptées',
      description: 'Tresses protectrices soignées avec finitions dorées éclatantes.',
      urlVideo: 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?w=800&auto=format&fit=crop&q=80',
      salonNom: 'Beauty By Dika',
      salonSlug: 'beauty-by-dika',
      salonLogoUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=500&auto=format&fit=crop&q=80',
      totalLikes: 8700,
      totalCommentaires: 184,
      totalVues: 9200,
    ),
    KadysModel(
      id: 3,
      titre: 'Dégradé Homme Prestige',
      description: 'Coupe précise et contours soignés avec traçage barbe impeccable.',
      urlVideo: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&auto=format&fit=crop&q=80',
      salonNom: 'Barber Shop Kalaban',
      salonSlug: 'barber-shop-kalaban',
      salonLogoUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop&q=80',
      totalLikes: 15200,
      totalCommentaires: 512,
      totalVues: 24000,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToSalonRealizations(String slug) {
    context.push('/salons/$slug?tab=2');
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll('.', ',')}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll('.', ',')}K';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = context.responsiveValue(compact: 44.0, standard: 50.0);
    final actionSpacing = context.responsiveValue(compact: 12.0, standard: 16.0);
    final bottomOffset = context.responsiveValue(compact: 14.0, standard: 22.0);

    final kadysFeedState = ref.watch(kadysFeedProvider);
    final allItems = kadysFeedState.items.isNotEmpty ? kadysFeedState.items : _fallbackItems;

    // Filtrage Suivis vs Pour Toi
    final displayItems = _activeTopTab == 0
        ? allItems.where((it) => _followedSalons.contains(it.salonSlug ?? '')).toList()
        : allItems;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==============================================================
          // 1. FLUX VERTICAL VIDÉOS / RÉALISATIONS KADY'S (PageView)
          // ==============================================================
          if (kadysFeedState.isLoading && kadysFeedState.items.isEmpty)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.figmaActiveGold,
              ),
            )
          else if (_activeTopTab == 0 && displayItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: AppColors.figmaActiveGold,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun salon suivi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.fontSize(18),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cliquez sur le badge rose "+" sur un salon dans le flux "Pour Toi" pour suivre ses créations exclusives.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: context.fontSize(13),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => setState(() => _activeTopTab = 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.figmaActiveGold,
                        foregroundColor: AppColors.figmaBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Découvrir le flux Pour Toi',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                final item = displayItems[index];
                final isLiked = item.isLikedByCurrentUser;
                final isSaved = _savedIds.contains(item.id);
                final salonSlug = item.salonSlug ?? 'beauty-by-dika';
                final isFollowed = _followedSalons.contains(salonSlug);
                final imgPath = item.urlVideo ?? '';
                final isNetwork = imgPath.startsWith('http://') || imgPath.startsWith('https://');
                final logoUrl = item.salonLogoUrl ?? '';
                final salonName = item.salonNom ?? 'Salon Kady\'s';
                final initials = salonName
                    .split(' ')
                    .map((s) => s.isNotEmpty ? s[0] : '')
                    .take(2)
                    .join('')
                    .toUpperCase();

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Photo / Vidéo plein écran
                    if (isNetwork)
                      Image.network(
                        imgPath,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFF151515),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.figmaActiveGold,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFF151515),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white38,
                            size: 72,
                          ),
                        ),
                      )
                    else if (imgPath.isNotEmpty)
                      Image.asset(
                        imgPath,
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
                      )
                    else
                      Container(
                        color: const Color(0xFF151515),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white38,
                          size: 72,
                        ),
                      ),

                    // Dégradé sombre au bas pour la lisibilité
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 320,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.95),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Colonne d'actions TikTok à droite
                    Positioned(
                      right: 12,
                      bottom: bottomOffset,
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
                                  width: avatarSize,
                                  height: avatarSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.figmaActiveGold,
                                      width: 2.0,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black45,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: logoUrl.startsWith('http')
                                        ? Image.network(
                                            logoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => Container(
                                              color: const Color(0xFF2E1C15),
                                              alignment: Alignment.center,
                                              child: Text(
                                                initials.isNotEmpty ? initials : 'SK',
                                                style: TextStyle(
                                                  color: AppColors.figmaActiveGold,
                                                  fontSize: context.fontSize(13),
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: const Color(0xFF2E1C15),
                                            alignment: Alignment.center,
                                            child: Text(
                                              initials.isNotEmpty ? initials : 'SK',
                                              style: TextStyle(
                                                color: AppColors.figmaActiveGold,
                                                fontSize: context.fontSize(13),
                                                fontWeight: FontWeight.w800,
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
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Vous suivez maintenant $salonName !'),
                                            duration: const Duration(seconds: 1),
                                            backgroundColor: AppColors.figmaBrown,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFE91E63),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(height: actionSpacing + 4),

                          // Bouton J'aime (Heart avec appel dynamique API)
                          _buildActionButton(
                            icon: Icons.favorite_rounded,
                            color: isLiked ? const Color(0xFFE53935) : Colors.white,
                            label: _formatCount(item.totalLikes),
                            onTap: () async {
                              final isAuth = ref.read(authStateProvider).isAuthenticated;
                              if (!isAuth) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Connectez-vous pour aimer cette coiffure !'),
                                    backgroundColor: AppColors.figmaBrown,
                                    action: SnackBarAction(
                                      label: 'Connexion',
                                      textColor: AppColors.figmaActiveGold,
                                      onPressed: () => context.push(RouteNames.login),
                                    ),
                                  ),
                                );
                                return;
                              }
                              await ref.read(kadysFeedProvider.notifier).toggleLike(item.id);
                            },
                          ),

                          SizedBox(height: actionSpacing),

                          // Bouton Commentaires (Chat bubble interactif avec backend)
                          _buildActionButton(
                            icon: Icons.chat_bubble_rounded,
                            color: Colors.white,
                            label: _formatCount(item.totalCommentaires),
                            onTap: () => _showCommentsBottomSheet(context, item.id, item.titre),
                          ),

                          SizedBox(height: actionSpacing),

                          // Bouton Favori / Sauvegarde
                          _buildActionButton(
                            icon: Icons.bookmark_rounded,
                            color: isSaved ? AppColors.figmaActiveGold : Colors.white,
                            label: _formatCount(item.totalVues),
                            onTap: () {
                              setState(() {
                                if (isSaved) {
                                  _savedIds.remove(item.id);
                                } else {
                                  _savedIds.add(item.id);
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isSaved
                                        ? 'Retiré de vos inspirations !'
                                        : 'Ajouté à vos inspirations enregistrées !',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppColors.figmaBrown,
                                ),
                              );
                            },
                          ),

                          SizedBox(height: actionSpacing),

                          // Bouton Partager
                          _buildActionButton(
                            icon: Icons.reply_rounded,
                            color: Colors.white,
                            label: 'Partager',
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                text: 'Découvre "${item.titre}" par $salonName sur MonSalon : https://monsalon.app/kadys/${item.id}',
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lien copié dans le presse-papier !'),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: AppColors.figmaBrown,
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
                      right: 84,
                      bottom: bottomOffset,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo + Nom du salon (Clic -> Liste des réalisations du salon)
                          GestureDetector(
                            onTap: () => _navigateToSalonRealizations(salonSlug),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF2E1C15),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initials.isNotEmpty ? initials : 'SK',
                                    style: TextStyle(
                                      color: AppColors.figmaActiveGold,
                                      fontSize: context.fontSize(10),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '@$salonName',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.fontSize(14),
                                      fontWeight: FontWeight.w700,
                                      shadows: const [
                                        Shadow(color: Colors.black87, blurRadius: 4),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Titre de la réalisation
                          Text(
                            item.titre,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.fontSize(15.5),
                              fontWeight: FontWeight.w800,
                              shadows: const [
                                Shadow(color: Colors.black87, blurRadius: 4),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Description de la réalisation
                          if (item.description != null && item.description!.isNotEmpty)
                            Text(
                              item.description!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.90),
                                fontSize: context.fontSize(12.5),
                                height: 1.3,
                                shadows: const [
                                  Shadow(color: Colors.black87, blurRadius: 4),
                                ],
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
                    const SizedBox(width: 32),

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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Suivis',
                                  style: TextStyle(
                                    color: _activeTopTab == 0
                                        ? Colors.white
                                        : Colors.white60,
                                    fontSize: context.fontSize(15.5),
                                    fontWeight: _activeTopTab == 0
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (_activeTopTab == 0)
                                  Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    width: 24,
                                    height: 2.5,
                                    decoration: BoxDecoration(
                                      color: AppColors.figmaActiveGold,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeTopTab = 1;
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Pour Toi',
                                  style: TextStyle(
                                    color: _activeTopTab == 1
                                        ? Colors.white
                                        : Colors.white60,
                                    fontSize: context.fontSize(16.5),
                                    fontWeight: _activeTopTab == 1
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (_activeTopTab == 1)
                                  Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    width: 24,
                                    height: 2.5,
                                    decoration: BoxDecoration(
                                      color: AppColors.figmaActiveGold,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Icône de recherche 🔍 en haut à droite
                    GestureDetector(
                      onTap: () => context.push(RouteNames.recherche),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
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
          Icon(
            icon,
            color: color,
            size: context.responsiveValue(compact: 24.0, standard: 28.0),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.fontSize(11),
              fontWeight: FontWeight.w600,
              shadows: const [
                Shadow(color: Colors.black87, blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, int realisationId, String realisationTitre) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _KadysCommentsModal(
        realisationId: realisationId,
        realisationTitre: realisationTitre,
      ),
    );
  }
}

class _KadysCommentsModal extends ConsumerStatefulWidget {
  final int realisationId;
  final String realisationTitre;

  const _KadysCommentsModal({
    required this.realisationId,
    required this.realisationTitre,
  });

  @override
  ConsumerState<_KadysCommentsModal> createState() => _KadysCommentsModalState();
}

class _KadysCommentsModalState extends ConsumerState<_KadysCommentsModal> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final isAuth = ref.read(authStateProvider).isAuthenticated;
    if (!isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Connectez-vous pour commenter !'),
          backgroundColor: AppColors.figmaBrown,
          action: SnackBarAction(
            label: 'Connexion',
            textColor: AppColors.figmaActiveGold,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(RouteNames.login);
            },
          ),
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final repo = ref.read(kadysRepositoryProvider);
      await repo.ajouterCommentaire(widget.realisationId, text);
      _commentController.clear();
      ref.invalidate(kadysCommentsProvider(widget.realisationId));
      ref.read(kadysFeedProvider.notifier).chargerFeed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commentaire publié avec succès !'),
            duration: Duration(seconds: 1),
            backgroundColor: AppColors.figmaBrown,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commentsAsync = ref.watch(kadysCommentsProvider(widget.realisationId));

    return Container(
      height: context.heightPercent(0.65, min: 380.0, max: 560.0),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          // Poignée supérieure
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 14),

          // Titre du modal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commentaires',
                  style: TextStyle(
                    fontSize: context.fontSize(16),
                    fontWeight: FontWeight.w800,
                    color: context.adaptiveTextColor(),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: context.adaptiveSubtextColor(),
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
            thickness: 0.8,
          ),

          // Liste des commentaires
          Expanded(
            child: commentsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.figmaActiveGold,
                  strokeWidth: 2,
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Impossible de charger les commentaires.',
                    style: TextStyle(
                      color: context.adaptiveSubtextColor(),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              data: (comments) {
                if (comments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: AppColors.figmaActiveGold,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Aucun commentaire pour le moment',
                            style: TextStyle(
                              color: context.adaptiveTextColor(),
                              fontSize: context.fontSize(14),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Soyez le premier à commenter cette coiffure !',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.adaptiveSubtextColor(),
                              fontSize: context.fontSize(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: comments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) {
                    final c = comments[idx];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.figmaBrown,
                          child: Text(
                            c.initials,
                            style: const TextStyle(
                              color: AppColors.figmaActiveGold,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.auteurNomComplet,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: context.fontSize(13),
                                  color: context.adaptiveTextColor(),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                c.contenu,
                                style: TextStyle(
                                  fontSize: context.fontSize(12.5),
                                  color: context.adaptiveTextColor(),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Barre de saisie de commentaire
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.adaptiveTextColor(),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Ajouter un commentaire public...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _isSending ? null : _submitComment,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.figmaBrown,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: AppColors.figmaActiveGold,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: AppColors.figmaActiveGold,
                              size: 18,
                            ),
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
