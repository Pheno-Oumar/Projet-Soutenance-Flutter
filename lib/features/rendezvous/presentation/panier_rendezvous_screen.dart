import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/auth_gate_dialog.dart';
import '../../../routing/route_names.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../salon/data/models/creneau_disponible_model.dart';
import '../../salon/data/models/horaire_salon_model.dart';
import '../../salon/presentation/providers/salon_provider.dart';
import '../data/models/rendezvous_panier_model.dart';
import 'providers/rendezvous_panier_provider.dart';
import 'providers/rendezvous_provider.dart';

class PanierRendezVousScreen extends ConsumerStatefulWidget {
  const PanierRendezVousScreen({super.key});

  @override
  ConsumerState<PanierRendezVousScreen> createState() => _PanierRendezVousScreenState();
}

class _PanierRendezVousScreenState extends ConsumerState<PanierRendezVousScreen> {
  final Map<String, TextEditingController> _notesControllers = {};

  @override
  void dispose() {
    for (final c in _notesControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getNotesController(String slug, String? initialValue) {
    if (!_notesControllers.containsKey(slug)) {
      _notesControllers[slug] = TextEditingController(text: initialValue ?? '');
    }
    return _notesControllers[slug]!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(rendezvousPanierProvider);
    final notifier = ref.read(rendezvousPanierProvider.notifier);
    final authState = ref.watch(authStateProvider);
    final paniers = state.paniers;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Panier Rendez-vous',
          style: TextStyle(
            fontSize: context.fontSize(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (paniers.isNotEmpty)
            IconButton(
              tooltip: 'Vider le panier rendez-vous',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Vider le panier rendez-vous'),
                    content: const Text(
                      'Voulez-vous retirer toutes les prestations sélectionnées de vos paniers ?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Vider', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  for (final p in List.of(paniers)) {
                    await notifier.viderSalon(p.slugSalon);
                  }
                }
              },
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : paniers.isEmpty
              ? _buildEmptyState(context, isDark)
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveValue(compact: 12.0, standard: 16.0),
                    vertical: 14.0,
                  ),
                  itemCount: paniers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final salonPanier = paniers[index];
                    return _buildSalonRdvCard(
                      context,
                      salonPanier,
                      isDark,
                      notifier,
                      authState.isAuthenticated,
                      state.isValidating,
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 46,
                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune prestation sélectionnée',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.fontSize(18),
                fontWeight: FontWeight.w700,
                color: context.adaptiveTextColor(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Parcourez les salons et ajoutez des coiffures ou des soins à votre panier rendez-vous pour planifier votre venue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.fontSize(13.5),
                color: context.adaptiveSubtextColor(),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Découvrir les salons'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.figmaBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => context.go('/salons'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalonRdvCard(
    BuildContext context,
    SalonRendezVousPanierModel salon,
    bool isDark,
    RendezvousPanierNotifier notifier,
    bool isAuthenticated,
    bool isValidating,
  ) {
    final notesController = _getNotesController(salon.slugSalon, salon.notes);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Salon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.6)
                  : AppColors.figmaInputBg.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  backgroundImage: salon.salonLogo != null && salon.salonLogo!.isNotEmpty
                      ? NetworkImage(salon.salonLogo!)
                      : null,
                  child: salon.salonLogo == null || salon.salonLogo!.isEmpty
                      ? const Icon(Icons.store, color: Colors.white, size: 18)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salon.salonNom,
                        style: TextStyle(
                          fontSize: context.fontSize(15),
                          fontWeight: FontWeight.w700,
                          color: context.adaptiveTextColor(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 13,
                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            salon.dureeTotaleFormatee,
                            style: TextStyle(
                              fontSize: context.fontSize(12),
                              color: context.adaptiveSubtextColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.content_cut,
                            size: 13,
                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${salon.prestations.length} prestation${salon.prestations.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: context.fontSize(12),
                              color: context.adaptiveSubtextColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Supprimer ce salon',
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () async {
                    await notifier.viderSalon(salon.slugSalon);
                  },
                ),
              ],
            ),
          ),

          // Liste des prestations sélectionnées
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              children: salon.prestations.map((presta) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: presta.imageUrl != null && presta.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  presta.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.auto_awesome,
                                    size: 20,
                                    color: isDark
                                        ? AppColors.figmaActiveGold
                                        : AppColors.figmaBrown,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.auto_awesome,
                                size: 20,
                                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              presta.serviceNom,
                              style: TextStyle(
                                fontSize: context.fontSize(13.5),
                                fontWeight: FontWeight.w600,
                                color: context.adaptiveTextColor(),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${presta.varianteNom} • ${presta.dureeFormatee}',
                              style: TextStyle(
                                fontSize: context.fontSize(12),
                                color: context.adaptiveSubtextColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${presta.prix.toStringAsFixed(0)} F',
                        style: TextStyle(
                          fontSize: context.fontSize(13.5),
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.figmaActiveGold : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'Retirer cette prestation',
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        onPressed: () async {
                          await notifier.retirerPrestation(salon.slugSalon, presta.varianteId);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Configuration du RDV (Coiffeur + Date & Créneaux en direct + Notes)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Choix du Coiffeur / Styliste
                Text(
                  'Coiffeur ou styliste',
                  style: TextStyle(
                    fontSize: context.fontSize(13),
                    fontWeight: FontWeight.w600,
                    color: context.adaptiveTextColor(),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _ouvrirSelecteurCoiffeur(context, salon, notifier),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                            .withValues(alpha: 0.35),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: (isDark ? AppColors.darkSurfaceVariant : Colors.white)
                          .withValues(alpha: 0.5),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: (isDark
                                  ? AppColors.figmaActiveGold
                                  : AppColors.figmaBrown)
                              .withValues(alpha: 0.15),
                          child: Icon(
                            salon.coiffeurId != null ? Icons.person : Icons.auto_awesome,
                            size: 16,
                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                salon.coiffeurNom ?? 'Sans préférence (Premier disponible)',
                                style: TextStyle(
                                  fontSize: context.fontSize(13),
                                  fontWeight: FontWeight.w600,
                                  color: context.adaptiveTextColor(),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                salon.coiffeurId != null
                                    ? 'Coiffeur dédié choisi'
                                    : 'Attribution automatique selon disponibilité',
                                style: TextStyle(
                                  fontSize: context.fontSize(11.5),
                                  color: context.adaptiveSubtextColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 13,
                          color: context.adaptiveSubtextColor(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 2. Choix de la Date & du Créneau (Issu du backend)
                Text(
                  'Date et créneau horaire',
                  style: TextStyle(
                    fontSize: context.fontSize(13),
                    fontWeight: FontWeight.w600,
                    color: context.adaptiveTextColor(),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _ouvrirSelecteurDateHeure(context, salon, notifier),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                            .withValues(alpha: 0.35),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: (isDark ? AppColors.darkSurfaceVariant : Colors.white)
                          .withValues(alpha: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 20,
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                salon.dateHeurePrevue != null
                                    ? _formaterDateHeureFr(salon.dateHeurePrevue!)
                                    : 'Choisir une date & vérifier les créneaux disponibles',
                                style: TextStyle(
                                  fontSize: context.fontSize(13),
                                  fontWeight: FontWeight.w600,
                                  color: salon.dateHeurePrevue != null
                                      ? context.adaptiveTextColor()
                                      : context.adaptiveSubtextColor(),
                                ),
                              ),
                              Text(
                                salon.dateHeurePrevue != null
                                    ? 'Créneau calculé en temps réel par le salon'
                                    : 'Appuyez pour consulter les disponibilités réelles',
                                style: TextStyle(
                                  fontSize: context.fontSize(11.5),
                                  color: context.adaptiveSubtextColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit_calendar_outlined,
                          size: 16,
                          color: context.adaptiveSubtextColor(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Notes particulières
                TextField(
                  controller: notesController,
                  onChanged: (text) {
                    notifier.definirNotes(salon.slugSalon, text);
                  },
                  decoration: InputDecoration(
                    hintText: 'Notes ou demandes particulières (facultatif)...',
                    hintStyle: TextStyle(
                      fontSize: context.fontSize(12),
                      color: context.adaptiveSubtextColor(),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: context.fontSize(12)),
                ),
              ],
            ),
          ),

          // Total & Bouton de validation STRICTEMENT POUR CE SALON
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.3)
                  : AppColors.background.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total salon (${salon.dureeTotaleFormatee})',
                      style: TextStyle(
                        fontSize: context.fontSize(11.5),
                        color: context.adaptiveSubtextColor(),
                      ),
                    ),
                    Text(
                      '${salon.montantTotal.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontSize: context.fontSize(16),
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.figmaActiveGold : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.figmaBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isValidating
                      ? null
                      : () => _validerRendezVousPourSalon(
                            context,
                            salon,
                            notifier,
                            isAuthenticated,
                          ),
                  child: isValidating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Valider pour ce salon',
                              style: TextStyle(
                                fontSize: context.fontSize(13),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ACTION DE VALIDATION STRICTEMENT PAR SALON
  // ==========================================

  Future<void> _validerRendezVousPourSalon(
    BuildContext context,
    SalonRendezVousPanierModel salon,
    RendezvousPanierNotifier notifier,
    bool isAuthenticated,
  ) async {
    // 1. Contrôle d'authentification
    if (!isAuthenticated) {
      final action = await AuthGateDialog.show(
        context,
        message:
            'Connectez-vous ou créez un compte pour valider votre rendez-vous chez ${salon.salonNom}.',
      );
      if (action == null || !context.mounted) return;
      final loggedIn = await context.push<bool>(
        action == 'register' ? RouteNames.register : RouteNames.login,
      );
      if (loggedIn != true || !context.mounted) return;
    }

    // 2. Contrôle de date & heure
    if (salon.dateHeurePrevue == null) {
      final picked = await _ouvrirSelecteurDateHeure(context, salon, notifier);
      if (picked != true) return;
    }

    // Copie de confirmation avant vidage local par le repository
    final salonSnapshot = salon.copyWith();

    try {
      final ok = await notifier.validerSalon(salon.slugSalon);
      if (context.mounted && ok) {
        // Rafraîchir la liste de mes rendez-vous
        ref.invalidate(mesRendezVousProvider);

        // Afficher la modale détaillée de confirmation
        _afficherModaleConfirmation(context, salonSnapshot);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la confirmation: ${e.toString().replaceAll("Exception:", "")}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ==========================================
  // SÉLECTEUR DE COIFFEUR (BOTTOM SHEET)
  // ==========================================

  Future<void> _ouvrirSelecteurCoiffeur(
    BuildContext context,
    SalonRendezVousPanierModel salon,
    RendezvousPanierNotifier notifier,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CoiffeurSelectionSheet(
        slugSalon: salon.slugSalon,
        salonNom: salon.salonNom,
        selectedCoiffeurId: salon.coiffeurId,
        onSelect: (id, nom) async {
          await notifier.definirCoiffeur(salon.slugSalon, id, nom);
        },
      ),
    );
  }

  // ==========================================
  // SÉLECTEUR DE DATE & CRÉNEAU ISSU DU BACK-END
  // ==========================================

  Future<bool?> _ouvrirSelecteurDateHeure(
    BuildContext context,
    SalonRendezVousPanierModel salon,
    RendezvousPanierNotifier notifier,
  ) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DateHeureSelectionSheet(
        slugSalon: salon.slugSalon,
        salonNom: salon.salonNom,
        dureeFormatee: salon.dureeTotaleFormatee,
        varianteIds: salon.prestations.map((p) => p.varianteId).toList(),
        coiffeurId: salon.coiffeurId,
        coiffeurNom: salon.coiffeurNom,
        initialDateTime: salon.dateHeurePrevue,
        onConfirmed: (dateTime, coiffeurId, coiffeurNom) async {
          await notifier.definirDateHeure(salon.slugSalon, dateTime);
          if (salon.coiffeurId == null && coiffeurId != null) {
            await notifier.definirCoiffeur(salon.slugSalon, coiffeurId, coiffeurNom);
          }
        },
      ),
    );
  }

  // ==========================================
  // MODALE DE CONFIRMATION DU RENDEZ-VOUS
  // ==========================================

  void _afficherModaleConfirmation(
    BuildContext context,
    SalonRendezVousPanierModel salon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateTexte = salon.dateHeurePrevue != null
        ? _formaterDateHeureFr(salon.dateHeurePrevue!)
        : 'À confirmer';

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Rendez-vous confirmé !',
                style: TextStyle(
                  fontSize: context.fontSize(20),
                  fontWeight: FontWeight.bold,
                  color: context.adaptiveTextColor(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Votre réservation chez ${salon.salonNom} a été transmise avec succès.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.fontSize(13.5),
                  color: context.adaptiveSubtextColor(),
                ),
              ),
              const SizedBox(height: 18),
              // Récapitulatif
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSurfaceVariant : AppColors.figmaInputBg)
                      .withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 0.8,
                  ),
                ),
                child: Column(
                  children: [
                    _buildRecapRow(
                      context,
                      icon: Icons.store,
                      label: 'Salon',
                      valeur: salon.salonNom,
                    ),
                    const Divider(height: 16),
                    _buildRecapRow(
                      context,
                      icon: Icons.event,
                      label: 'Date & Heure',
                      valeur: dateTexte,
                    ),
                    const Divider(height: 16),
                    _buildRecapRow(
                      context,
                      icon: Icons.person_outline,
                      label: 'Coiffeur',
                      valeur: salon.coiffeurNom ?? 'Sans préférence (Premier disponible)',
                    ),
                    const Divider(height: 16),
                    _buildRecapRow(
                      context,
                      icon: Icons.content_cut,
                      label: 'Prestations',
                      valeur: '${salon.prestations.length} (${salon.dureeTotaleFormatee})',
                    ),
                    const Divider(height: 16),
                    _buildRecapRow(
                      context,
                      icon: Icons.payments_outlined,
                      label: 'Total à régler au salon',
                      valeur: '${salon.montantTotal.toStringAsFixed(0)} FCFA',
                      isBold: true,
                      valeurColor: isDark ? AppColors.figmaActiveGold : AppColors.primaryDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Fermer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.figmaBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(RouteNames.mesRendezVous);
                      },
                      child: const Text('Mes rendez-vous'),
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

  Widget _buildRecapRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String valeur,
    bool isBold = false,
    Color? valeurColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.adaptiveSubtextColor()),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: context.fontSize(12.5),
            color: context.adaptiveSubtextColor(),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            valeur,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: context.fontSize(13),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valeurColor ?? context.adaptiveTextColor(),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // FORMATAGE DE DATE & HEURE EN FRANÇAIS
  // ==========================================

  static String _formaterDateHeureFr(DateTime dt) {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const mois = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];
    final jourNom = jours[dt.weekday - 1];
    final jourNum = dt.day.toString().padLeft(2, '0');
    final moisNom = mois[dt.month - 1];
    final heure = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$jourNom $jourNum $moisNom à ${heure}h$min';
  }
}

// ============================================================================
// COMPOSANT : MODALE DE SÉLECTION DU COIFFEUR (SALON COIFFEURS PROVIDER)
// ============================================================================

class _CoiffeurSelectionSheet extends ConsumerWidget {
  final String slugSalon;
  final String salonNom;
  final int? selectedCoiffeurId;
  final Future<void> Function(int? id, String? nom) onSelect;

  const _CoiffeurSelectionSheet({
    required this.slugSalon,
    required this.salonNom,
    required this.selectedCoiffeurId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coiffeursAsync = ref.watch(salonCoiffeursProvider(slugSalon));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choisir un coiffeur ou styliste',
                        style: TextStyle(
                          fontSize: context.fontSize(16),
                          fontWeight: FontWeight.bold,
                          color: context.adaptiveTextColor(),
                        ),
                      ),
                      Text(
                        salonNom,
                        style: TextStyle(
                          fontSize: context.fontSize(12.5),
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Option 1 : Sans préférence (Premier disponible)
                _buildCoiffeurTile(
                  context,
                  isDark: isDark,
                  isSelected: selectedCoiffeurId == null,
                  avatarWidget: CircleAvatar(
                    radius: 20,
                    backgroundColor: (isDark
                            ? AppColors.figmaActiveGold
                            : AppColors.figmaBrown)
                        .withValues(alpha: 0.15),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    ),
                  ),
                  nom: 'Sans préférence (Premier disponible)',
                  description:
                      'Le salon affectera automatiquement le coiffeur le plus adapté le jour J.',
                  badgeTexte: 'Recommandé',
                  badgeColor: Colors.blueAccent,
                  onTap: () async {
                    await onSelect(null, null);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 10),

                // Option 2..N : Coiffeurs réels du salon
                coiffeursAsync.when(
                  loading: () => Column(
                    children: List.generate(
                      2,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.figmaInputBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Information coiffeurs indisponible en ligne pour ce salon.',
                      style: TextStyle(
                        fontSize: context.fontSize(12),
                        color: context.adaptiveSubtextColor(),
                      ),
                    ),
                  ),
                  data: (coiffeurs) {
                    if (coiffeurs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Tous les coiffeurs du salon sont disponibles via l\'option "Sans préférence".',
                          style: TextStyle(
                            fontSize: context.fontSize(12.5),
                            color: context.adaptiveSubtextColor(),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: coiffeurs.map((c) {
                        final idAffectation = c.affectationId ?? c.id;
                        final isSelected = selectedCoiffeurId == idAffectation;

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildCoiffeurTile(
                            context,
                            isDark: isDark,
                            isSelected: isSelected,
                            avatarWidget: CircleAvatar(
                              radius: 20,
                              backgroundColor: (isDark
                                      ? AppColors.figmaActiveGold
                                      : AppColors.figmaBrown)
                                  .withValues(alpha: 0.15),
                              backgroundImage: c.photoProfilUrl != null &&
                                      c.photoProfilUrl!.isNotEmpty
                                  ? NetworkImage(c.photoProfilUrl!)
                                  : null,
                              child: c.photoProfilUrl == null || c.photoProfilUrl!.isEmpty
                                  ? Text(
                                      c.displayName.isNotEmpty
                                          ? c.displayName[0].toUpperCase()
                                          : 'C',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.figmaActiveGold
                                            : AppColors.figmaBrown,
                                      ),
                                    )
                                  : null,
                            ),
                            nom: c.displayName,
                            description: c.biographie?.isNotEmpty == true
                                ? c.biographie!
                                : (c.anneeExperience > 0
                                    ? '${c.anneeExperience} ans d\'expérience'
                                    : 'Coiffeur styliste professionnel'),
                            badgeTexte: c.available ? 'Disponible' : 'Occupé',
                            badgeColor: c.available ? Colors.green : Colors.grey,
                            onTap: () async {
                              await onSelect(idAffectation, c.displayName);
                              if (context.mounted) Navigator.pop(context);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoiffeurTile(
    BuildContext context, {
    required bool isDark,
    required bool isSelected,
    required Widget avatarWidget,
    required String nom,
    required String description,
    required String badgeTexte,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isSelected ? 1.8 : 0.8,
          ),
          color: isSelected
              ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                  .withValues(alpha: 0.08)
              : (isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.4) : Colors.white),
        ),
        child: Row(
          children: [
            avatarWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          nom,
                          style: TextStyle(
                            fontSize: context.fontSize(14),
                            fontWeight: FontWeight.w600,
                            color: context.adaptiveTextColor(),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeTexte,
                          style: TextStyle(
                            fontSize: context.fontSize(10),
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: context.fontSize(12),
                      color: context.adaptiveSubtextColor(),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected
                  ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                  : Colors.grey.withValues(alpha: 0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// COMPOSANT : MODALE DE SÉLECTION DATE & CRÉNEAUX CALCULÉS PAR LE BACK-END
// ============================================================================

class _DateHeureSelectionSheet extends ConsumerStatefulWidget {
  final String slugSalon;
  final String salonNom;
  final String dureeFormatee;
  final List<int> varianteIds;
  final int? coiffeurId;
  final String? coiffeurNom;
  final DateTime? initialDateTime;
  final Future<void> Function(
    DateTime dateTime,
    int? coiffeurId,
    String? coiffeurNom,
  ) onConfirmed;

  const _DateHeureSelectionSheet({
    required this.slugSalon,
    required this.salonNom,
    required this.dureeFormatee,
    required this.varianteIds,
    required this.coiffeurId,
    required this.coiffeurNom,
    required this.initialDateTime,
    required this.onConfirmed,
  });

  @override
  ConsumerState<_DateHeureSelectionSheet> createState() => _DateHeureSelectionSheetState();
}

class _DateHeureSelectionSheetState extends ConsumerState<_DateHeureSelectionSheet> {
  late DateTime _selectedDate;
  TimeOfDay? _heureMinimale;
  CreneauDisponibleModel? _selectedCreneau;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (widget.initialDateTime != null && widget.initialDateTime!.isAfter(now)) {
      _selectedDate = DateTime(
        widget.initialDateTime!.year,
        widget.initialDateTime!.month,
        widget.initialDateTime!.day,
      );
    } else {
      // Par défaut demain
      _selectedDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Horaires réguliers du salon pour information
    final horairesAsync = ref.watch(salonHorairesProvider(widget.slugSalon));
    final jourSemaineStr = _nomJourSemaine(_selectedDate.weekday);
    HoraireSalonModel? horaireDuJour;
    horairesAsync.whenData((horaires) {
      for (final h in horaires) {
        if (h.jourSemaine.toUpperCase() == jourSemaineStr.toUpperCase()) {
          horaireDuJour = h;
          break;
        }
      }
    });

    final isSalonFerme = horaireDuJour != null && !horaireDuJour!.actif;

    // CRÉNEAUX CALCULÉS PAR LE BACK-END
    final heureMinStr = _heureMinimale != null
        ? '${_heureMinimale!.hour.toString().padLeft(2, '0')}:${_heureMinimale!.minute.toString().padLeft(2, '0')}:00'
        : null;

    final disponibilitesAsync = ref.watch(
      salonDisponibilitesProvider((
        slug: widget.slugSalon,
        date: _selectedDate,
        varianteIds: widget.varianteIds,
        coiffeurId: widget.coiffeurId,
        heureMinimale: heureMinStr,
      )),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Créneaux disponibles (En direct)',
                        style: TextStyle(
                          fontSize: context.fontSize(16),
                          fontWeight: FontWeight.bold,
                          color: context.adaptiveTextColor(),
                        ),
                      ),
                      Text(
                        '${widget.salonNom} • Durée totale : ${widget.dureeFormatee}',
                        style: TextStyle(
                          fontSize: context.fontSize(12.5),
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Contexte coiffeur & date
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                          .withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.coiffeurId != null ? Icons.person : Icons.auto_awesome,
                        size: 18,
                        color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.coiffeurNom != null
                              ? 'Recherche pour : ${widget.coiffeurNom}'
                              : 'Recherche : Premier coiffeur disponible',
                          style: TextStyle(
                            fontSize: context.fontSize(12.5),
                            fontWeight: FontWeight.w600,
                            color: context.adaptiveTextColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 1. Choix du Jour
                Text(
                  '1. Choisissez le jour',
                  style: TextStyle(
                    fontSize: context.fontSize(13.5),
                    fontWeight: FontWeight.w600,
                    color: context.adaptiveTextColor(),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _choisirDateCalendrier,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                            .withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: (isDark ? AppColors.darkSurfaceVariant : AppColors.figmaInputBg)
                          .withValues(alpha: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 20,
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _formaterDateLongue(_selectedDate),
                            style: TextStyle(
                              fontSize: context.fontSize(14),
                              fontWeight: FontWeight.w600,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _choisirDateCalendrier,
                          style: TextButton.styleFrom(
                            foregroundColor:
                                isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                          ),
                          child: const Text('Changer'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Horaires du salon ou fermeture
                if (horaireDuJour != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSalonFerme
                          ? Colors.orange.withValues(alpha: 0.12)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSalonFerme ? Colors.orange : Colors.green,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSalonFerme ? Icons.warning_amber_rounded : Icons.access_time_filled,
                          size: 16,
                          color: isSalonFerme ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isSalonFerme
                                ? 'Attention : Le salon est habituellement fermé ce jour.'
                                : 'Horaires du salon : ${horaireDuJour!.plageHoraire}',
                            style: TextStyle(
                              fontSize: context.fontSize(12),
                              fontWeight: FontWeight.w500,
                              color: isSalonFerme ? Colors.orange : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 2. Filtre d'heure minimale (Optionnel)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '2. À partir de quelle heure ?',
                      style: TextStyle(
                        fontSize: context.fontSize(13.5),
                        fontWeight: FontWeight.w600,
                        color: context.adaptiveTextColor(),
                      ),
                    ),
                    if (_heureMinimale != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _heureMinimale = null;
                            _selectedCreneau = null;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                        ),
                        child: const Text('Effacer'),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildHeureMinPill(
                        label: 'Dès l\'ouverture',
                        isSelected: _heureMinimale == null,
                        onTap: () {
                          setState(() {
                            _heureMinimale = null;
                            _selectedCreneau = null;
                          });
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildHeureMinPill(
                        label: 'Dès 11h00',
                        isSelected: _heureMinimale?.hour == 11 && _heureMinimale?.minute == 0,
                        onTap: () {
                          setState(() {
                            _heureMinimale = const TimeOfDay(hour: 11, minute: 0);
                            _selectedCreneau = null;
                          });
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildHeureMinPill(
                        label: 'Après-midi (14h00)',
                        isSelected: _heureMinimale?.hour == 14 && _heureMinimale?.minute == 0,
                        onTap: () {
                          setState(() {
                            _heureMinimale = const TimeOfDay(hour: 14, minute: 0);
                            _selectedCreneau = null;
                          });
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildHeureMinPill(
                        label: 'Fin d\'après-midi (16h00)',
                        isSelected: _heureMinimale?.hour == 16 && _heureMinimale?.minute == 0,
                        onTap: () {
                          setState(() {
                            _heureMinimale = const TimeOfDay(hour: 16, minute: 0);
                            _selectedCreneau = null;
                          });
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 3. Créneaux disponibles retournés par le Back-end
                Text(
                  '3. Créneaux disponibles calculés',
                  style: TextStyle(
                    fontSize: context.fontSize(13.5),
                    fontWeight: FontWeight.w600,
                    color: context.adaptiveTextColor(),
                  ),
                ),
                const SizedBox(height: 8),

                disponibilitesAsync.when(
                  loading: () => Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Calcul des créneaux en direct auprès du salon...',
                          style: TextStyle(
                            fontSize: context.fontSize(12.5),
                            color: context.adaptiveSubtextColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  error: (err, _) => Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Erreur lors du calcul des créneaux. Veuillez réessayer ou choisir une autre date.',
                            style: TextStyle(
                              fontSize: context.fontSize(12),
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  data: (creneaux) {
                    if (creneaux.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.event_busy_outlined,
                              size: 36,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aucun créneau disponible ce jour',
                              style: TextStyle(
                                fontSize: context.fontSize(14),
                                fontWeight: FontWeight.bold,
                                color: context.adaptiveTextColor(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.coiffeurNom != null
                                  ? '${widget.coiffeurNom} n\'a pas de disponibilité suffisante (${widget.dureeFormatee}) pour cette date ou à partir de cette heure. Essayez une autre date ou choisissez « Sans préférence » pour voir d\'autres coiffeurs.'
                                  : 'Tous les coiffeurs du salon sont occupés pour la durée requise (${widget.dureeFormatee}) à cette date. Veuillez choisir un autre jour ou effacer le filtre horaire.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.fontSize(12.5),
                                color: context.adaptiveSubtextColor(),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.edit_calendar, size: 16),
                              label: const Text('Choisir une autre date'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                    ? AppColors.figmaActiveGold
                                    : AppColors.figmaBrown,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _choisirDateCalendrier,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${creneaux.length} créneau${creneaux.length > 1 ? 'x' : ''} disponible${creneaux.length > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Durée requise : ${widget.dureeFormatee}',
                              style: TextStyle(
                                fontSize: context.fontSize(12),
                                color: context.adaptiveSubtextColor(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: creneaux.map((creneau) {
                            final isSelected = _selectedCreneau?.heureDebut == creneau.heureDebut;

                            return ChoiceChip(
                              label: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isSelected
                                        ? creneau.plageFormatee
                                        : creneau.heureDebutFormatee,
                                  ),
                                  if (widget.coiffeurId == null && creneau.coiffeurNom != null)
                                    Text(
                                      creneau.coiffeurNom!,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.normal,
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.85)
                                            : context.adaptiveSubtextColor(),
                                      ),
                                    ),
                                ],
                              ),
                              selected: isSelected,
                              backgroundColor: isDark
                                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                                  : AppColors.figmaInputBg,
                              selectedColor:
                                  isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                              labelStyle: TextStyle(
                                fontSize: context.fontSize(12.5),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : context.adaptiveTextColor(),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? (isDark
                                          ? AppColors.figmaActiveGold
                                          : AppColors.figmaBrown)
                                      : (isDark ? AppColors.darkBorder : AppColors.border),
                                  width: isSelected ? 1.5 : 0.8,
                                ),
                              ),
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() {
                                    _selectedCreneau = creneau;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Bouton de validation
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.figmaBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _selectedCreneau == null ? null : _confirmer,
                    child: Text(
                      _selectedCreneau != null
                          ? 'Confirmer : ${_formaterDateCourt(_selectedDate)} de ${_selectedCreneau!.plageFormatee}'
                          : 'Sélectionnez un créneau ci-dessus',
                      style: TextStyle(
                        fontSize: context.fontSize(13.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeureMinPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.figmaInputBg),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Future<void> _choisirDateCalendrier() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedCreneau = null;
      });
    }
  }

  Future<void> _confirmer() async {
    if (_selectedCreneau == null) return;

    final completeDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedCreneau!.heure,
      _selectedCreneau!.minute,
    );

    await widget.onConfirmed(
      completeDateTime,
      _selectedCreneau!.coiffeurAffectationId,
      _selectedCreneau!.coiffeurNom,
    );
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  static String _nomJourSemaine(int weekday) {
    switch (weekday) {
      case 1:
        return 'LUNDI';
      case 2:
        return 'MARDI';
      case 3:
        return 'MERCREDI';
      case 4:
        return 'JEUDI';
      case 5:
        return 'VENDREDI';
      case 6:
        return 'SAMEDI';
      case 7:
        return 'DIMANCHE';
      default:
        return 'LUNDI';
    }
  }

  static String _formaterDateLongue(DateTime dt) {
    const jours = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    const mois = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    final j = jours[dt.weekday - 1];
    final m = mois[dt.month - 1];
    return '$j ${dt.day} $m ${dt.year}';
  }

  static String _formaterDateCourt(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }
}
