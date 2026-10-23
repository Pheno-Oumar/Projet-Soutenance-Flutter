import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'providers/salon_provider.dart';
import '../data/models/realisation_salon_model.dart';

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

class StoryScreen extends ConsumerStatefulWidget {
  final String salonName;
  final String initials;
  final String slug;

  const StoryScreen({
    super.key,
    this.salonName = 'Salon Beauty',
    this.initials = 'SB',
    this.slug = '',
  });

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  int _currentIndex = 0;
  int _totalStories = 0;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  void _nextStory() {
    if (_totalStories > 0 && _currentIndex < _totalStories - 1) {
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

  Widget _buildStoryImage(String path) {
    final cleanPath = path.replaceAll('http://localhost:8080', 'http://10.0.2.2:8080');
    Widget placeholder() => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2E1C15),
                Color(0xFF120E0C),
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.figmaActiveGold,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.salonName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return Image.network(
        cleanPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => placeholder(),
      );
    }
    return placeholder();
  }

  @override
  Widget build(BuildContext context) {
    final salonStoriesAsync = ref.watch(salonStoriesProvider(widget.slug));
    final salonDetailAsync = ref.watch(salonDetailProvider(widget.slug));
    final logoUrl = salonDetailAsync.valueOrNull?.logoUrl;

    if (salonStoriesAsync.isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.figmaActiveGold,
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 16),
              Text(
                'Chargement des stories de ${widget.salonName}...',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (salonStoriesAsync.hasError && widget.slug.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 14),
                const Text(
                  'Impossible de charger les stories',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  salonStoriesAsync.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => ref.invalidate(salonStoriesProvider(widget.slug)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.figmaActiveGold,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Réessayer'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                      ),
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final realStories = salonStoriesAsync.valueOrNull ?? [];
    final realisationsAsync = ref.watch(salonRealisationsProvider(widget.slug));
    final dynamicReels = realisationsAsync.valueOrNull ?? [];
    final fallbackTransversales = ref.watch(realisationsTransversalesProvider).valueOrNull ?? [];

    final List<StoryItem> stories;
    if (realStories.isNotEmpty) {
      stories = realStories.map((s) {
        final hoursAgo = s.dateCreation != null
            ? DateTime.now().difference(s.dateCreation!).inHours
            : 0;
        final timeLabel = hoursAgo <= 1
            ? 'Il y a moins d\'une heure'
            : (hoursAgo < 24 ? 'Il y a ${hoursAgo}h' : 'Hier');
        return StoryItem(
          imagePath: s.mediaUrl,
          caption: '${widget.salonName} • Story exclusive',
          timestamp: timeLabel,
        );
      }).toList();
    } else if (dynamicReels.isNotEmpty || fallbackTransversales.isNotEmpty) {
      final activeList = dynamicReels.isNotEmpty
          ? dynamicReels
          : (widget.slug.isEmpty ? fallbackTransversales : <RealisationSalonModel>[]);
      stories = activeList.map((r) {
        return StoryItem(
          imagePath: r.urlVideo ?? 'assets/images/story_img_0.jpg',
          caption: r.description != null && r.description!.isNotEmpty
              ? '${r.titre} • ${r.description}'
              : r.titre,
          timestamp: 'Aujourd\'hui',
        );
      }).toList();
    } else {
      stories = [];
    }

    _totalStories = stories.length;

    if (stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.figmaActiveGold,
                      child: Text(
                        widget.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.salonName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.auto_stories_outlined,
                          size: 64,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune story disponible',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ce salon n\'a aucune story ou réalisation publiée pour le moment.',
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.figmaActiveGold,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentStory = stories[_currentIndex.clamp(0, stories.length - 1)];

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
            _buildStoryImage(currentStory.imagePath),

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
                      children: List.generate(stories.length, (index) {
                        return Expanded(
                          child: Container(
                            height: 2.5,
                            margin: EdgeInsets.only(
                              right: index < stories.length - 1 ? 4.0 : 0.0,
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
                          child: (logoUrl != null && logoUrl.startsWith('http'))
                              ? ClipOval(
                                  child: Image.network(
                                    logoUrl,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Text(
                                      widget.initials,
                                      style: const TextStyle(
                                        color: AppColors.figmaActiveGold,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
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
          ],
        ),
      ),
    );
  }
}
