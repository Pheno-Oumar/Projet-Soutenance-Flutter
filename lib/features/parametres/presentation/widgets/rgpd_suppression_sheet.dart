import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/models/rgpd_models.dart';
import '../../data/repositories/rgpd_repository.dart';

class RgpdSuppressionSheet extends ConsumerStatefulWidget {
  const RgpdSuppressionSheet({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const RgpdSuppressionSheet(),
    );
  }

  @override
  ConsumerState<RgpdSuppressionSheet> createState() => _RgpdSuppressionSheetState();
}

class _RgpdSuppressionSheetState extends ConsumerState<RgpdSuppressionSheet> {
  bool _isLoading = true;
  String? _errorMessage;
  EligibiliteSuppressionModel? _eligibilite;
  List<DemandeSuppressionModel> _demandes = [];
  bool _afficherNouveauFormulaire = false;

  final TextEditingController _motifController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  @override
  void dispose() {
    _motifController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(rgpdRepositoryProvider);
      final res = await repo.verifierEligibiliteSuppression();
      final demandes = await repo.consulterSuiviSuppression();
      if (mounted) {
        setState(() {
          _eligibilite = res;
          _demandes = demandes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmerSuppression() async {
    if (_confirmationController.text.trim().toUpperCase() != 'SUPPRIMER') {
      AppToast.show(
        context,
        message: 'Veuillez saisir exactement le mot SUPPRIMER pour confirmer.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(rgpdRepositoryProvider);
      final nouvelle = await repo.demanderSuppression(motif: _motifController.text);
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _demandes = [nouvelle, ..._demandes];
          _afficherNouveauFormulaire = false;
        });
        Navigator.pop(context);
        AppToast.show(
          context,
          message: 'Votre demande de suppression a été soumise avec succès.',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppToast.show(
          context,
          message: 'Erreur : ${e.toString().replaceAll('Exception: ', '')}',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // En-tête
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_remove_outlined,
                      size: 24,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Supprimer mon compte',
                          style: TextStyle(
                            fontSize: context.fontSize(17),
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                          ),
                        ),
                        Text(
                          'Droit à l\'effacement et anonymisation (Art. 17 RGPD)',
                          style: TextStyle(
                            fontSize: context.fontSize(12),
                            color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Contenu dynamique
              if (_isLoading) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const CircularProgressIndicator(strokeWidth: 2.5),
                      const SizedBox(height: 16),
                      Text(
                        'Vérification de votre dossier et suivi en cours...',
                        style: TextStyle(
                          fontSize: context.fontSize(13.5),
                          color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _chargerDonnees,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildBodyContent(context, isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, bool isDark) {
    final derniereDemande = _demandes.isNotEmpty ? _demandes.first : null;

    // 1. CAS D'UNE DEMANDE DÉJÀ EN ATTENTE (Suivi en direct)
    if (derniereDemande != null && derniereDemande.statut == 'EN_ATTENTE') {
      return _buildDemandeEnAttenteView(context, isDark, derniereDemande);
    }

    // 2. CAS D'UNE DEMANDE APPROUVÉE
    if (derniereDemande != null && derniereDemande.statut == 'APPROUVEE') {
      return _buildDemandeApprouveeView(context, isDark, derniereDemande);
    }

    // 3. CAS D'UNE PRÉCÉDENTE DEMANDE REJETÉE
    if (derniereDemande != null && derniereDemande.statut == 'REJETEE' && !_afficherNouveauFormulaire) {
      return _buildDemandeRejeteeView(context, isDark, derniereDemande);
    }

    // 4. SI LE CLIENT N'EST PAS ÉLIGIBLE
    if (_eligibilite != null && !_eligibilite!.eligible) {
      return _buildIneligibleView(context, isDark, _eligibilite!);
    }

    // 5. SINON : CLIENT ÉLIGIBLE (Formulaire de suppression)
    return _buildEligibleView(context, isDark);
  }

  Widget _buildDemandeEnAttenteView(BuildContext context, bool isDark, DemandeSuppressionModel demande) {
    final df = DateFormat('dd/MM/yyyy à HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Demande en cours d\'instruction',
                      style: TextStyle(
                        fontSize: context.fontSize(15),
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.amber[200] : const Color(0xFF8A5A00),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'En cours',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (demande.dateDemande != null)
                Text(
                  'Transmise le ${df.format(demande.dateDemande!)}',
                  style: TextStyle(
                    fontSize: context.fontSize(12),
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
                  ),
                ),
              if (demande.motif != null && demande.motif!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Motif indiqué : "${demande.motif}"',
                  style: TextStyle(
                    fontSize: context.fontSize(12.5),
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2C241E),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Votre demande d\'effacement et anonymisation est entre les mains de l\'administrateur système. '
                  'Elle sera traitée dans les plus brefs délais. Vous recevrez un email récapitulatif dès que la décision aura été validée.',
                  style: TextStyle(
                    fontSize: context.fontSize(12),
                    height: 1.35,
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
              foregroundColor: isDark ? const Color(0xFF1E1610) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildDemandeApprouveeView(BuildContext context, bool isDark, DemandeSuppressionModel demande) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 36),
              const SizedBox(height: 10),
              Text(
                'Compte en cours d\'anonymisation',
                style: TextStyle(
                  fontSize: context.fontSize(15),
                  fontWeight: FontWeight.w800,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Votre demande de suppression a été approuvée par l\'administrateur.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.fontSize(12.5),
                  color: isDark ? AppColors.darkTextSecondary : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ),
      ],
    );
  }

  Widget _buildDemandeRejeteeView(BuildContext context, bool isDark, DemandeSuppressionModel demande) {
    final df = DateFormat('dd/MM/yyyy à HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Précédente demande refusée',
                      style: TextStyle(
                        fontSize: context.fontSize(15),
                        fontWeight: FontWeight.w800,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (demande.dateDecision != null)
                Text(
                  'Décision rendue le ${df.format(demande.dateDecision!)}',
                  style: TextStyle(
                    fontSize: context.fontSize(12),
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                  ),
                ),
              if (demande.motifDecision != null && demande.motifDecision!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Motif de refus de l\'administrateur :\n"${demande.motifDecision}"',
                    style: TextStyle(
                      fontSize: context.fontSize(12.5),
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.red[200] : Colors.red[900],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Si votre situation a changé ou a été régularisée, vous pouvez soumettre une nouvelle demande :',
          style: TextStyle(
            fontSize: context.fontSize(12.5),
            color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => _afficherNouveauFormulaire = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
              foregroundColor: isDark ? const Color(0xFF1E1610) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Formuler une nouvelle demande', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildIneligibleView(BuildContext context, bool isDark, EligibiliteSuppressionModel eligibilite) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suppression impossible actuellement',
                      style: TextStyle(
                        fontSize: context.fontSize(14),
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.amber[200] : const Color(0xFF8A5A00),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Certaines conditions préalables ne sont pas encore remplies pour clôturer votre compte.',
                      style: TextStyle(
                        fontSize: context.fontSize(12),
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF5A4010),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (eligibilite.motifsIneligibilite.isNotEmpty) ...[
          Text(
            'Motifs bloquants :',
            style: TextStyle(
              fontSize: context.fontSize(13.5),
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 8),
          ...eligibilite.motifsIneligibilite.map(
            (motif) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F5F1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE8DFD5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.block_rounded, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      motif,
                      style: TextStyle(
                        fontSize: context.fontSize(12.5),
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2C241E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkTextMuted : Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Conseil : Assurez-vous que vos commandes soient récupérées, vos rendez-vous terminés et vos réclamations résolues.',
                    style: TextStyle(
                      fontSize: context.fontSize(11.5),
                      color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Compris'),
          ),
        ),
      ],
    );
  }

  Widget _buildEligibleView(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.report_problem_outlined, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Action irréversible (Anonymisation RGPD)',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.redAccent,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Vos données nominatives (nom, prénom, email, téléphone) seront anonymisées définitivement.\n'
                '• Votre accès au compte sera immédiatement désactivé.\n'
                '• Les factures et données comptables seront conservées de manière anonyme pour les salons selon les obligations fiscales en vigueur.',
                style: TextStyle(
                  fontSize: context.fontSize(12),
                  height: 1.4,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2C241E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Motif de votre départ (optionnel)',
          style: TextStyle(
            fontSize: context.fontSize(13.5),
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _motifController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Expliquez-nous pourquoi vous souhaitez supprimer votre compte...',
            hintStyle: TextStyle(
              fontSize: context.fontSize(12.5),
              color: isDark ? AppColors.darkTextMuted : Colors.grey[500],
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F7F5),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Confirmation de sécurité',
          style: TextStyle(
            fontSize: context.fontSize(13.5),
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Veuillez taper "SUPPRIMER" ci-dessous pour confirmer :',
          style: TextStyle(
            fontSize: context.fontSize(12),
            color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmationController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'SUPPRIMER',
            hintStyle: TextStyle(
              fontSize: context.fontSize(13),
              color: isDark ? AppColors.darkTextMuted : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F7F5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: (_confirmationController.text.trim().toUpperCase() == 'SUPPRIMER' && !_isSubmitting)
                ? _confirmerSuppression
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.red.withValues(alpha: 0.3),
              disabledForegroundColor: Colors.white60,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Confirmer la suppression de mon compte',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }
}
