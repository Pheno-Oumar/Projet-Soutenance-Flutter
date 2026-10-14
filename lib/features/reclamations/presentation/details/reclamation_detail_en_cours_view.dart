import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/reclamation_model.dart';
import '../widgets/reclamation_detail_header_card.dart';

class ReclamationDetailEnCoursView extends StatelessWidget {
  final ReclamationModel reclamation;
  final VoidCallback onBackPressed;

  const ReclamationDetailEnCoursView({
    super.key,
    required this.reclamation,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            // 1. Carte d'en-tête (Salon concerné + Statut)
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

            // Information de traitement
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF10283B) : const Color(0xFFEBF5FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E4868) : const Color(0xFF90CDF4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync_rounded, color: Color(0xFF38B6FF), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Un responsable du salon examine actuellement votre réclamation.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF90CDF4) : Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
