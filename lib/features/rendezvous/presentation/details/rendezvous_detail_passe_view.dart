import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/rendezvous_model.dart';
import '../widgets/rendezvous_header_widget.dart';
import '../widgets/rendezvous_info_card.dart';
import '../widgets/rendezvous_prestation_card.dart';

class RendezVousDetailPasseView extends StatelessWidget {
  final RendezVousModel rdv;
  final VoidCallback onBackPressed;

  const RendezVousDetailPasseView({
    super.key,
    required this.rdv,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: Column(
        children: [
          // Header cover adapté avec statut Passé
          RendezVousHeaderWidget(
            rdv: rdv,
            onBackPressed: onBackPressed,
          ),

          // Contenu déroulant
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Prestations
                  Text(
                    'Prestations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...rdv.lignes.map((l) => RendezVousPrestationCard(ligne: l)),
                  const SizedBox(height: 16),

                  // Section Informations
                  Text(
                    'Informations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RendezVousInfoCard(rdv: rdv),
                  const SizedBox(height: 32),

                  // Action optionnelle: Reprendre rendez-vous
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (rdv.salonSlug != null) {
                          context.push('/salons/${rdv.salonSlug}');
                        } else {
                          context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.figmaBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reprendre rendez-vous',
                        style: TextStyle(
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
          ),
        ],
      ),
    );
  }
}
