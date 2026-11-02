import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_colors.dart';

/// Helper pour détecter si une URL ou un type représente un média vidéo
bool isVideoMedia(String? url, {String? typeMedia}) {
  if (typeMedia != null && typeMedia.toUpperCase() == 'VIDEO') {
    return true;
  }
  if (url == null || url.trim().isEmpty) return false;
  final lower = url.toLowerCase();
  return lower.contains('.m3u8') ||
      lower.contains('/m3u8') ||
      lower.contains('sp_hd') ||
      lower.contains('/video/upload/') ||
      lower.endsWith('.mp4') ||
      lower.contains('.mp4?') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.webm') ||
      lower.endsWith('.mkv');
}

/// Helper pour obtenir l'URL de la vignette d'une vidéo Cloudinary ou standard
String getMediaThumbnailUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  // Si c'est une vidéo Cloudinary HLS ou standard, Cloudinary génère une vignette jpg
  if (url.contains('cloudinary.com') && (url.contains('/video/upload/') || url.contains('.m3u8') || url.contains('.mp4'))) {
    var thumb = url.replaceAll('sp_hd/m3u8/', '');
    if (thumb.contains('.m3u8')) {
      thumb = thumb.replaceAll('.m3u8', '.jpg');
    } else if (thumb.contains('.mp4')) {
      thumb = thumb.replaceAll('.mp4', '.jpg');
    }
    return thumb;
  }
  return url;
}

/// Nettoie l'URL pour gérer l'émulateur Android (localhost -> 10.0.2.2)
String resolveMediaUrl(String url) {
  if (kIsWeb) return url;
  if (Platform.isAndroid && url.contains('localhost:8080')) {
    return url.replaceAll('localhost:8080', '10.0.2.2:8080');
  }
  return url;
}

/// Lecteur vidéo robuste prenant en charge :
/// - Les vidéos fractionnées en streaming adaptatif HLS (.m3u8)
/// - Les vidéos standards MP4/MOV/WebM
/// - Les assets locaux
/// - La mise en boucle, l'auto-play et le ratio plein écran
class AppVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final VideoPlayerController? controller;
  final bool autoPlay;
  final bool looping;
  final bool isPlaying;
  final BoxFit fit;
  final ValueChanged<VideoPlayerController>? onInitialized;
  final VoidCallback? onVideoEnd;
  final VoidCallback? onTap;

  const AppVideoPlayer({
    super.key,
    required this.videoUrl,
    this.controller,
    this.autoPlay = true,
    this.looping = true,
    this.isPlaying = true,
    this.fit = BoxFit.cover,
    this.onInitialized,
    this.onVideoEnd,
    this.onTap,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? _controller;
  bool _ownsController = false;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showPlayPauseIcon = false;
  bool _isManuallyPaused = false;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  void _setupPlayer() {
    if (widget.controller != null) {
      _attachExternalController(widget.controller!);
    } else {
      _initializePlayer();
    }
  }

  void _attachExternalController(VideoPlayerController extController) {
    _controller = extController;
    _ownsController = false;
    _isInitialized = extController.value.isInitialized;
    _hasError = extController.value.hasError;
    _controller!.addListener(_videoListener);

    if (_isInitialized) {
      if (widget.autoPlay && widget.isPlaying && !_isManuallyPaused) {
        _controller!.play();
      } else if (!widget.isPlaying) {
        _controller!.pause();
      }
      widget.onInitialized?.call(_controller!);
    }
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _disposePlayer();
      if (widget.controller != null) {
        _attachExternalController(widget.controller!);
      } else {
        _initializePlayer();
      }
      return;
    }

    if (widget.controller == null && oldWidget.videoUrl != widget.videoUrl) {
      _disposePlayer();
      _initializePlayer();
      return;
    }

    if (_controller != null && _isInitialized &&
        widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _isManuallyPaused = false;
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  void _disposePlayer() {
    final controller = _controller;
    controller?.removeListener(_videoListener);
    if (_ownsController && controller != null) {
      controller.pause();
      controller.dispose();
    }
    _controller = null;
    _ownsController = false;
    _isInitialized = false;
    _hasError = false;
  }

  Future<void> _initializePlayer() async {
    final cleanUrl = resolveMediaUrl(widget.videoUrl);
    if (cleanUrl.isEmpty) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    VideoPlayerController controller;
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(cleanUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    } else {
      controller = VideoPlayerController.asset(cleanUrl);
    }
    _controller = controller;
    _ownsController = true;

    try {
      await controller.initialize();

      if (!mounted || !identical(_controller, controller)) {
        return;
      }

      await controller.setLooping(widget.looping);
      if (!mounted || !identical(_controller, controller)) {
        return;
      }

      controller.addListener(_videoListener);

      if (widget.autoPlay && widget.isPlaying) {
        await controller.play();
      }

      if (!mounted || !identical(_controller, controller)) return;
      setState(() {
        _isInitialized = true;
      });

      widget.onInitialized?.call(controller);
    } catch (e) {
      if (!mounted || !identical(_controller, controller)) return;
      setState(() {
        _hasError = true;
      });
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    final value = _controller!.value;

    if (!_isInitialized && value.isInitialized) {
      setState(() {
        _isInitialized = true;
      });
      if (widget.autoPlay && widget.isPlaying && !_isManuallyPaused) {
        _controller!.play();
      }
      widget.onInitialized?.call(_controller!);
    }

    if (value.hasError && !_hasError) {
      setState(() {
        _hasError = true;
      });
    }

    // Détection de fin de vidéo pour les stories (si looping est false)
    if (!widget.looping &&
        value.isInitialized &&
        value.position >= value.duration &&
        value.duration > Duration.zero) {
      widget.onVideoEnd?.call();
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isManuallyPaused = true;
      } else {
        _controller!.play();
        _isManuallyPaused = false;
      }
      _showPlayPauseIcon = true;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _showPlayPauseIcon = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: const Color(0xFF161210),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_off_rounded,
              color: Colors.white38,
              size: 54,
            ),
            const SizedBox(height: 12),
            const Text(
              'Impossible de charger la vidéo',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.figmaActiveGold, size: 28),
              onPressed: () {
                setState(() {
                  _hasError = false;
                });
                _initializePlayer();
              },
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      final thumbUrl = getMediaThumbnailUrl(widget.videoUrl);
      final hasThumb = thumbUrl.isNotEmpty && (thumbUrl.startsWith('http://') || thumbUrl.startsWith('https://'));

      return Stack(
        fit: StackFit.expand,
        children: [
          if (hasThumb)
            Image.network(
              resolveMediaUrl(thumbUrl),
              fit: widget.fit,
              errorBuilder: (_, _, _) => Container(color: Colors.black),
            )
          else
            Container(color: Colors.black),
          Container(
            color: Colors.black26,
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    color: AppColors.figmaActiveGold,
                    strokeWidth: 2.5,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Préparation de la vidéo...',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final videoSize = _controller!.value.size;

    return GestureDetector(
      onTap: _togglePlayPause,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Rendu vidéo avec maintien du ratio plein écran
          SizedBox.expand(
            child: FittedBox(
              fit: widget.fit,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: videoSize.width > 0 ? videoSize.width : 1080,
                height: videoSize.height > 0 ? videoSize.height : 1920,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),

          // Indicateur visuel Play / Pause au centre lors du tap
          if (_showPlayPauseIcon)
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showPlayPauseIcon ? 1.0 : 0.0,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),

          // Indicateur subtil de buffering si la vidéo charge des segments HLS
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller!,
            builder: (context, value, _) {
              if (value.isBuffering) {
                return const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: AppColors.figmaActiveGold,
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
