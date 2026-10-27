import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Types de notification Toast disponibles
enum ToastType { info, success, warning, error, cart, rdv }

/// Notification Toast flottante moderne en haut de l'écran (façon Angular Toastr / iOS banner).
/// Flotte sous l'AppBar sans jamais masquer la BottomNavigationBar.
class AppToast {
  static OverlayEntry? _currentEntry;
  static _ToastWidgetState? _currentState;

  /// Affiche un toast moderne en haut de l'écran avec une durée définie.
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(milliseconds: 2500),
    String? actionLabel,
    VoidCallback? onAction,
    IconData? customIcon,
  }) {
    // Si un toast est déjà présent, le masquer proprement
    hide();

    final overlay = Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        key: GlobalKey<_ToastWidgetState>(),
        message: message,
        type: type,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        customIcon: customIcon,
        onDismissed: () {
          if (_currentEntry == entry) {
            _currentEntry?.remove();
            _currentEntry = null;
            _currentState = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// Masque immédiatement le toast actif.
  static void hide() {
    _currentState?.dismiss();
    _currentEntry?.remove();
    _currentEntry = null;
    _currentState = null;
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    this.actionLabel,
    this.onAction,
    this.customIcon,
    required this.onDismissed,
  });

  final String message;
  final ToastType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? customIcon;
  final VoidCallback onDismissed;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    AppToast._currentState = this;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    _timer = Timer(widget.duration, () {
      dismiss();
    });
  }

  void dismiss() {
    _timer?.cancel();
    if (mounted) {
      _controller.reverse().then((_) {
        if (mounted) {
          widget.onDismissed();
        }
      });
    } else {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    return switch (widget.type) {
      ToastType.error => const Color(0xFF8B2522),
      ToastType.warning => const Color(0xFF7A4B1A),
      ToastType.success ||
      ToastType.cart ||
      ToastType.rdv ||
      ToastType.info => AppColors.figmaBrown,
    };
  }

  IconData _getIcon() {
    if (widget.customIcon != null) return widget.customIcon!;
    return switch (widget.type) {
      ToastType.cart => Icons.shopping_bag_rounded,
      ToastType.rdv => Icons.event_available_rounded,
      ToastType.success => Icons.check_circle_rounded,
      ToastType.warning => Icons.warning_amber_rounded,
      ToastType.error => Icons.error_outline_rounded,
      ToastType.info => Icons.info_outline_rounded,
    };
  }

  Color _getIconColor() {
    return switch (widget.type) {
      ToastType.error => Colors.white,
      ToastType.warning => const Color(0xFFFFD54F),
      ToastType.cart ||
      ToastType.rdv ||
      ToastType.success ||
      ToastType.info => AppColors.figmaActiveGold,
    };
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 10;

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! < -4) {
                  dismiss();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.figmaActiveGold.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icône du toast
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _getIcon(),
                        color: _getIconColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Message
                    Expanded(
                      child: Text(
                        widget.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),

                    // Bouton d'action optionnel (ex: "Voir")
                    if (widget.actionLabel != null && widget.onAction != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          dismiss();
                          widget.onAction!();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.figmaActiveGold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: const TextStyle(
                              color: Color(0xFF2C2420),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Bouton fermer discret
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: dismiss,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.65),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
