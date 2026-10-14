import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/reclamation_model.dart';
import '../providers/reclamation_provider.dart';
import '../widgets/reclamation_detail_header_card.dart';

class ReclamationDetailRejeteView extends ConsumerWidget {
  final ReclamationModel reclamation;
  final VoidCallback onBackPressed;

  const ReclamationDetailRejeteView({
    super.key,
    required this.reclamation,
    required this.onBackPressed,
  });

  void _confirmerRelance(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Relancer la réclamation ?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? AppColors.darkTextPrimary : Colors.black,
          ),
        ),
        content: Text(
          'Votre réclamation pour ${reclamation.salonNom} va être remise en traitement.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(mesReclamationsProvider.notifier).relancerReclamation(reclamation.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Votre réclamation a été relancée avec succès.'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer la relance'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final responseText = reclamation.reponseTraitement ??
        "Votre réclamation a été rejetée. Les conditions générales de vente ou les délais requis n'ont pas été respectés.";
    final auteur = reclamation.reponseAuteur ?? 'Direction ${reclamation.salonNom}';
    final initiales = reclamation.reponseAuteurInitiales ?? 'SB';
    final dateReponse = reclamation.dateTraitement ?? 'Traité';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: onBackPressed,
        ),
        title: const Text(
          'Détails réclamation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Carte d'en-tête (Salon concerné + Statut Rejetée)
            ReclamationDetailHeaderCard(reclamation: reclamation),
            const SizedBox(height: 24),

            // 2. Section "Votre message déposé"
            Text(
              'Votre message déposé',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
                  width: 1.0,
                ),
              ),
              child: Text(
                '"${reclamation.description}"',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4A4A4A),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Section "Réponse officielle du salon" (Motif du rejet)
            const Text(
              'Réponse officielle du salon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD8A868),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E140E) : const Color(0xFF382319),
                          border: Border.all(color: AppColors.figmaActiveGold, width: 1.2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initiales,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auteur,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                            ),
                          ),
                          Text(
                            'Répondu le $dateReponse',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      height: 1,
                      color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
                    ),
                  ),
                  Text(
                    '"$responseText"',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4A4A4A),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Bouton vert "Relancer la réclamation"
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => _confirmerRelance(context, ref),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Relancer la réclamation',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
