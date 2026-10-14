import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CodeRetraitDialog extends StatelessWidget {
  final String codeRetrait;
  final String numeroCommande;

  const CodeRetraitDialog({
    super.key,
    required this.codeRetrait,
    required this.numeroCommande,
  });

  static void show(BuildContext context, {required String codeRetrait, required String numeroCommande}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CodeRetraitDialog(
        codeRetrait: codeRetrait,
        numeroCommande: numeroCommande,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de tirage
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Icône badge de retrait
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFFBF4ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              size: 32,
              color: AppColors.figmaBrown,
            ),
          ),
          const SizedBox(height: 14),

          // Titre
          Text(
            'Code de retrait Click & Collect',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            numeroCommande,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8C827A),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // Boîte du Code de Retrait
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkInputBg : const Color(0xFFFDFBF9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.figmaActiveGold, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  codeRetrait,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: AppColors.figmaBrown,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Fausse simulation de code-barres stylisée
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(36, (index) {
                final isThick = index % 3 == 0 || index % 7 == 0;
                final isSpace = index % 5 == 0;
                if (isSpace) return const SizedBox(width: 2);
                return Container(
                  width: isThick ? 3 : 1.5,
                  height: 40,
                  color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                );
              }),
            ),
          ),

          const SizedBox(height: 18),

          // Consignes
          Text(
            'Présentez ce code ou votre numéro de commande à l\'accueil du salon pour récupérer vos produits.',
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Bouton Fermer
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.figmaBrown,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Fermer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
