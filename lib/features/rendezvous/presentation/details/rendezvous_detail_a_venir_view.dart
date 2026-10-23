import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/rendezvous_model.dart';
import '../providers/rendezvous_provider.dart';
import '../widgets/rendezvous_header_widget.dart';
import '../widgets/rendezvous_info_card.dart';
import '../widgets/rendezvous_prestation_card.dart';

class RendezVousDetailAVenirView extends ConsumerWidget {
  final RendezVousModel rdv;
  final VoidCallback onBackPressed;

  const RendezVousDetailAVenirView({
    super.key,
    required this.rdv,
    required this.onBackPressed,
  });

  void _confirmerAnnulation(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reasonController = TextEditingController(text: 'Empêchement imprévu');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Annuler le rendez-vous ?',
                style: TextStyle(
                  fontSize: ctx.fontSize(18),
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Êtes-vous sûr de vouloir annuler votre rendez-vous pour ${rdv.salonNom ?? 'ce salon'} prévu le ${rdv.dateHeureFormatee} ?',
                style: TextStyle(
                  fontSize: ctx.fontSize(13),
                  color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                ),
                decoration: InputDecoration(
                  labelText: 'Motif de l\'annulation',
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : null,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkInputBg : const Color(0xFFFAF7F2),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Non, garder',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : null,
                            fontSize: ctx.fontSize(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final raison = reasonController.text.trim();
                        await ref.read(mesRendezVousProvider.notifier).annuler(
                              rdv.id,
                              raison: raison.isNotEmpty ? raison : 'Annulé par le client',
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Votre rendez-vous a été annulé.'),
                              backgroundColor: Color(0xFFD32F2F),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Oui, annuler',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: ctx.fontSize(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: Column(
        children: [
          // Header cover adapté avec statut À venir
          RendezVousHeaderWidget(
            rdv: rdv,
            onBackPressed: onBackPressed,
          ),

          // Contenu déroulant
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: context.responsiveValue(compact: 70.0, standard: 80.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Prestations
                  Text(
                    'Prestations',
                    style: TextStyle(
                      fontSize: context.fontSize(16),
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
                      fontSize: context.fontSize(16),
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RendezVousInfoCard(rdv: rdv),
                  const SizedBox(height: 32),

                  // Bouton Annuler le RDV
                  SizedBox(
                    width: double.infinity,
                    height: context.responsiveValue(compact: 44.0, standard: 48.0),
                    child: OutlinedButton(
                      onPressed: () => _confirmerAnnulation(context, ref),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFE53935),
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: isDark ? const Color(0xFF2B1717) : Colors.white,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Annuler le RDV',
                          style: TextStyle(
                            color: const Color(0xFFE53935),
                            fontSize: context.fontSize(15),
                            fontWeight: FontWeight.w700,
                          ),
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
