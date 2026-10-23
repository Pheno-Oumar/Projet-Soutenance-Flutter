import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

class AuthGateDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? salonNom;

  const AuthGateDialog({
    super.key,
    this.title = 'Connexion requise',
    this.message = 'Veuillez vous connecter ou créer un compte pour finaliser cette action.',
    this.salonNom,
  });

  static Future<String?> show(
    BuildContext context, {
    String title = 'Connexion requise',
    String message = 'Veuillez vous connecter ou créer un compte pour finaliser votre commande.',
    String? salonNom,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          22,
          16,
          22,
          MediaQuery.of(ctx).viewInsets.bottom + 28,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBorder
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icone
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            // Titre
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ctx.fontSize(18),
                fontWeight: FontWeight.w800,
                color: ctx.adaptiveTextColor(),
              ),
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              salonNom != null
                  ? '$message\nSalon : $salonNom'
                  : message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ctx.fontSize(13.5),
                color: ctx.adaptiveSubtextColor(),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Bouton 1 : Se connecter
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop('login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: ctx.fontSize(14.5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Bouton 2 : Créer un compte
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop('register'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  side: BorderSide(
                    color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: ctx.fontSize(14.5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Bouton 3 : Annuler
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(
                'Continuer en invité',
                style: TextStyle(
                  fontSize: ctx.fontSize(13),
                  color: ctx.adaptiveSubtextColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
