import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class StoryItem {
  final String imagePath;
  final String caption;
  final String timestamp;

  const StoryItem({
    required this.imagePath,
    required this.caption,
    required this.timestamp,
  });
}

class StoryScreen extends StatefulWidget {
  final String salonName;
  final String initials;

  const StoryScreen({
    super.key,
    this.salonName = 'Salon Beauty',
    this.initials = 'SB',
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  int _currentIndex = 0;
  bool _isLiked = false;
  final TextEditingController _replyController = TextEditingController();

  // Liste des stories du salon avec multiples images (comme sur Instagram/WhatsApp)
  late final List<StoryItem> _stories;

  @override
  void initState() {
    super.initState();
    _stories = [
      const StoryItem(
        imagePath: 'assets/images/story_img_0.jpg',
        caption: 'Tresses spirales artistiques ✨ Création exclusive de la semaine',
        timestamp: 'Il y a 2h',
      ),
      const StoryItem(
        imagePath: 'assets/images/story_img_1.png',
        caption: 'Box Braids & Perles dorées 🤎 Réalisé ce matin au salon',
        timestamp: 'Il y a 1h',
      ),
      const StoryItem(
        imagePath: 'assets/images/story_img_2.png',
        caption: 'Soin kératine intense & Brillance éclatante 💆‍♀️✨',
        timestamp: 'Il y a 30m',
      ),
    ];

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < _stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _animController.reset();
      _animController.forward();
    } else {
      if (mounted) {
        context.pop();
      }
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _animController.reset();
      _animController.forward();
    } else {
      _animController.reset();
      _animController.forward();
    }
  }

  void _onTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;
    if (dx < screenWidth * 0.35) {
      _previousStory();
    } else {
      _nextStory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStory = _stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onLongPressStart: (_) => _animController.stop(),
        onLongPressEnd: (_) => _animController.forward(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. IMAGE DE FOND FULLSCREEN
            Image.asset(
              currentStory.imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF1F1A18),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_rounded,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),

            // 2. DÉGRADÉ SUPÉRIEUR POUR LA LISIBILITÉ DE L'APP BAR & PROGRESS BARS
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 140,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 3. DÉGRADÉ INFÉRIEUR POUR LA LISIBILITÉ DU TEXTE & INTERACTIONS
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 4. HEADER SUPÉRIEUR : BARRES DE PROGRESSION & INFOS SALON
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // A. BARRES DE PROGRESSION SEGMENTÉES (Comme Instagram / WhatsApp)
                    Row(
                      children: List.generate(_stories.length, (index) {
                        return Expanded(
                          child: Container(
                            height: 2.5,
                            margin: EdgeInsets.only(
                              right: index < _stories.length - 1 ? 4.0 : 0.0,
                            ),
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, _) {
                                double progress = 0.0;
                                if (index < _currentIndex) {
                                  progress = 1.0;
                                } else if (index == _currentIndex) {
                                  progress = _animController.value;
                                }
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.white.withValues(alpha: 0.35),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    minHeight: 2.5,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 12),

                    // B. INFOS DU SALON & BOUTON FERMER (Figma Stories.svg)
                    Row(
                      children: [
                        // Avatar circulaire avec anneau doré
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2E1C15),
                            border: Border.all(
                              color: AppColors.figmaActiveGold,
                              width: 1.6,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.initials,
                            style: const TextStyle(
                              color: AppColors.figmaActiveGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Nom du salon & Temps
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.salonName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                currentStory.timestamp,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bouton Fermer ✕
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 5. ZONE INFÉRIEURE : LÉGENDE & CHAMP RÉPONSE (INTERACTIONS STORIES)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Légende de la story
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        currentStory.caption,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Barre de réponse rapide & bouton J'aime
                    Row(
                      children: [
                        // Champ de message
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _replyController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Envoyer un message...',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 12.5,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    if (_replyController.text.trim().isNotEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Message envoyé !'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                      _replyController.clear();
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Bouton Like ❤️
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                color: _isLiked
                                    ? const Color(0xFFE53935)
                                    : Colors.white.withValues(alpha: 0.3),
                                width: 1.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _isLiked ? const Color(0xFFE53935) : Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
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
}
