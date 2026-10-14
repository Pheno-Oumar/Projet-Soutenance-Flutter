import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/prestation_model.dart';
import '../providers/prestation_provider.dart';
import '../widgets/prestation_header_widget.dart';
import '../widgets/prestation_info_card.dart';
import '../widgets/prestation_ligne_card.dart';

class PrestationDetailScreen extends ConsumerStatefulWidget {
  final int id;
  final PrestationModel? initialPrestation;

  const PrestationDetailScreen({
    super.key,
    required this.id,
    this.initialPrestation,
  });

  @override
  ConsumerState<PrestationDetailScreen> createState() => _PrestationDetailScreenState();
}

class _PrestationDetailScreenState extends ConsumerState<PrestationDetailScreen> {
  PrestationModel? _prestation;

  @override
  void initState() {
    super.initState();
    _prestation = widget.initialPrestation;
    if (_prestation == null) {
      final state = ref.read(mesPrestationsProvider);
      _prestation = state.allPrestations.cast<PrestationModel?>().firstWhere(
        (p) => p?.id == widget.id,
        orElse: () => null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(mesPrestationsProvider);
    final prestation = state.allPrestations.cast<PrestationModel?>().firstWhere(
      (p) => p?.id == widget.id,
      orElse: () => _prestation,
    );

    if (prestation == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
          title: const Text('Détail Prestation', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Prestation introuvable',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
            ),
          ),
        ),
      );
    }

    final totalVariants = prestation.lignes.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: Column(
        children: [
          // 1. Cover Header identique aux rendez-vous
          PrestationHeaderWidget(
            prestation: prestation,
            onBackPressed: () => context.pop(),
          ),

          // 2. Contenu déroulant
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Motif d'annulation si annulée
                  if (prestation.isAnnulee) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3B1212) : const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFF8B4B4),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prestation annulée',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  prestation.motifAnnulation ??
                                      'Cette prestation a été annulée.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark ? const Color(0xFFFECACA) : const Color(0xFFB91C1C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Section Prestations / Services réalisés
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prestations & Services',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                        ),
                      ),
                      if (prestation.hasMultipleVariants)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF3E9DD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$totalVariants variantes',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Liste de toutes les variantes de services
                  ...prestation.lignes.map((l) => PrestationLigneCard(ligne: l)),

                  // Récapitulatif si multiples variantes
                  if (prestation.hasMultipleVariants) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFF6EFE7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFD8A868).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total ($totalVariants prestations)',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2E1C15),
                            ),
                          ),
                          Text(
                            '${prestation.montantTotal.toStringAsFixed(0)} FCFA',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

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
                  PrestationInfoCard(prestation: prestation),
                  const SizedBox(height: 32),

                  // Bouton Reprendre rendez-vous
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (prestation.salonSlug.isNotEmpty) {
                          context.push('/salons/${prestation.salonSlug}');
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
                        elevation: 2,
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
