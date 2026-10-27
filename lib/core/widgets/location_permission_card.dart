import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_location_provider.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import 'app_toast.dart';

class LocationPermissionCard extends ConsumerWidget {
  final VoidCallback? onCompleted;

  const LocationPermissionCard({super.key, this.onCompleted});

  /// Affiche le pop-up / bottom-sheet de localisation si pas encore demandé
  static Future<void> checkAndShowPrompt(BuildContext context, WidgetRef ref) async {
    final alreadyPrompted = await LocationService.hasPromptedLocation();
    if (!alreadyPrompted && context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const LocationPermissionCard(),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locationState = ref.watch(userLocationProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre supérieure grise
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icône stylisée avec halo doré
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.figmaActiveGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.figmaActiveGold.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on_rounded,
                  size: 38,
                  color: AppColors.figmaActiveGold,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Titre
            Text(
              'Partagez votre position',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : Colors.black,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Activez la géolocalisation pour découvrir les salons et coiffeurs les plus proches de vous avec les distances réelles.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 26),

            // Bouton Principal : Partager ma position
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: locationState.isLoading
                    ? null
                    : () async {
                        final success = await ref
                            .read(userLocationProvider.notifier)
                            .requestLocation();
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (success) {
                            AppToast.show(
                              context,
                              message: 'Position partagée avec succès !',
                              type: ToastType.success,
                            );
                          } else {
                            AppToast.show(
                              context,
                              message: 'Position non disponible (Bamako par défaut)',
                              type: ToastType.info,
                            );
                          }
                          onCompleted?.call();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.figmaActiveGold,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: locationState.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.my_location_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Partager ma position',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // Bouton Secondaire : Plus tard
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () {
                  ref.read(userLocationProvider.notifier).dismissPrompt();
                  Navigator.pop(context);
                  onCompleted?.call();
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Plus tard',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
