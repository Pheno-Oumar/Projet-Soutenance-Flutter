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
  int _selectedSalonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(rendezvousPanierProvider);
    final notifier = ref.read(rendezvousPanierProvider.notifier);
    final authState = ref.watch(authStateProvider);
    final paniers = state.paniers;

    if (_selectedSalonIndex >= paniers.length) {
      _selectedSalonIndex = 0;
    }
    final currentSalon = paniers.isNotEmpty ? paniers[_selectedSalonIndex] : null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          'Mon Panier Rendez-vous',
          style: TextStyle(
            fontSize: context.fontSize(17),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (paniers.isNotEmpty)
            IconButton(
              tooltip: 'Vider le panier',
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Vider le panier rendez-vous'),
                    content: const Text(
                      'Voulez-vous retirer toutes les prestations de vos paniers ?',
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
                  setState(() => _selectedSalonIndex = 0);
                }
              },
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : paniers.isEmpty
              ? _buildEmptyState(context, isDark)
              : Column(
                  children: [
                    if (paniers.length > 1)
                      _buildSalonSelectorTabs(context, paniers, isDark),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsiveValue(compact: 12.0, standard: 16.0),
                          vertical: 14.0,
                        ),
                        child: _buildSalonRdvCard(
                          context,
                          currentSalon!,
                          isDark,
                          notifier,
                        ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: (paniers.isEmpty || state.isLoading || currentSalon == null)
          ? null
          : _buildStickyBottomValidationBar(
              context,
              currentSalon,
              isDark,
              notifier,
              authState.isAuthenticated,
              state.isValidating,
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 42,
                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Votre panier est vide',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.fontSize(18),
                fontWeight: FontWeight.w700,
                color: context.adaptiveTextColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des prestations depuis un salon pour planifier votre rendez-vous.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.fontSize(13.5),
                color: context.adaptiveSubtextColor(),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.storefront_outlined, size: 18),
              label: const Text('Découvrir les salons'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.figmaBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => context.go('/salons'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalonSelectorTabs(
    BuildContext context,
    List<SalonRendezVousPanierModel> paniers,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(paniers.length, (i) {
            final p = paniers[i];
            final isSelected = i == _selectedSalonIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedSalonIndex = i),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                        : (isDark ? AppColors.darkSurfaceVariant : AppColors.figmaInputBg),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                      width: isSelected ? 1.4 : 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 15,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        p.salonNom,
                        style: TextStyle(
                          fontSize: context.fontSize(12.5),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : context.adaptiveTextColor(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${p.prestations.length}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStickyBottomValidationBar(
    BuildContext context,
    SalonRendezVousPanierModel salon,
    bool isDark,
    RendezvousPanierNotifier notifier,
    bool isAuthenticated,
    bool isValidating,
  ) {
    final hasDate = salon.dateHeurePrevue != null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          salon.salonNom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.fontSize(11.5),
                            color: context.adaptiveSubtextColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        ' • ${salon.dureeTotaleFormatee}',
                        style: TextStyle(
                          fontSize: context.fontSize(11),
                          color: context.adaptiveSubtextColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${salon.montantTotal.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: context.fontSize(17),
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.figmaBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
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
                        Icon(
                          hasDate ? Icons.check_circle_outline : Icons.calendar_today_outlined,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasDate ? 'Valider le rdv' : 'Choisir & valider',
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
    );
  }

  Widget _buildSalonRdvCard(
    BuildContext context,
    SalonRendezVousPanierModel salon,
    bool isDark,
    RendezvousPanierNotifier notifier,
  ) {
    final hasDate = salon.dateHeurePrevue != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // En-tête Salon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.6)
                  : AppColors.figmaInputBg.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  backgroundImage: salon.salonLogo != null && salon.salonLogo!.isNotEmpty
                      ? NetworkImage(salon.salonLogo!)
                      : null,
                  child: salon.salonLogo == null || salon.salonLogo!.isEmpty
                      ? const Icon(Icons.store, color: Colors.white, size: 17)
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
                      Text(
                        '${salon.prestations.length} prestation${salon.prestations.length > 1 ? 's' : ''} • Durée : ${salon.dureeTotaleFormatee}',
                        style: TextStyle(
                          fontSize: context.fontSize(12),
                          color: context.adaptiveSubtextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Supprimer',
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () => notifier.viderSalon(salon.slugSalon),
                ),
              ],
            ),
          ),

          // Liste des prestations sélectionnées
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: salon.prestations.map((presta) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
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
                                    size: 18,
                                    color: isDark
                                        ? AppColors.figmaActiveGold
                                        : AppColors.figmaBrown,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.auto_awesome,
                                size: 18,
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
                                fontSize: context.fontSize(11.5),
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
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Retirer',
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        onPressed: () => notifier.retirerPrestation(salon.slugSalon, presta.varianteId),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // 2 Cartes Interactives Claires : Coiffeur & Date/Heure
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Choix du Coiffeur
                InkWell(
                  onTap: () => _ouvrirSelecteurCoiffeur(context, salon, notifier),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                        width: 0.8,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: isDark
                          ? AppColors.darkSurfaceVariant.withValues(alpha: 0.4)
                          : AppColors.figmaInputBg.withValues(alpha: 0.5),
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
                                'Coiffeur ou styliste',
                                style: TextStyle(
                                  fontSize: context.fontSize(11),
                                  color: context.adaptiveSubtextColor(),
                                ),
                              ),
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

                const SizedBox(height: 10),

                // 2. Choix de la Date & Créneau (Carte très visible avec statut)
                InkWell(
                  onTap: () => _ouvrirSelecteurDateHeure(context, salon, notifier),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: hasDate
                            ? Colors.green.shade400
                            : (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                                .withValues(alpha: 0.6),
                        width: hasDate ? 1.4 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: hasDate
                          ? (isDark ? Colors.green.shade900.withValues(alpha: 0.25) : Colors.green.shade50)
                          : (isDark
                              ? AppColors.darkSurfaceVariant.withValues(alpha: 0.4)
                              : (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                                  .withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: hasDate
                                ? Colors.green.withValues(alpha: 0.15)
                                : (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                                    .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasDate ? Icons.check_circle : Icons.calendar_today_outlined,
                            size: 18,
                            color: hasDate
                                ? Colors.green
                                : (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasDate ? 'Date & Heure réservées' : 'Date et heure du rendez-vous',
                                style: TextStyle(
                                  fontSize: context.fontSize(11),
                                  fontWeight: FontWeight.w500,
                                  color: hasDate
                                      ? (isDark ? Colors.green.shade300 : Colors.green.shade800)
                                      : context.adaptiveSubtextColor(),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasDate
                                    ? _formaterDateHeureFr(salon.dateHeurePrevue!)
                                    : 'Appuyez pour choisir la date et le créneau',
                                style: TextStyle(
                                  fontSize: context.fontSize(13.5),
                                  fontWeight: FontWeight.w700,
                                  color: hasDate
                                      ? (isDark ? Colors.green.shade200 : Colors.green.shade900)
                                      : (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasDate
                                ? Colors.green.withValues(alpha: 0.15)
                                : (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                                    .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hasDate ? 'Modifier' : 'Choisir',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: hasDate
                                  ? Colors.green
                                  : (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown),
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _validerRendezVousPourSalon(
    BuildContext context,
    SalonRendezVousPanierModel salon,
    RendezvousPanierNotifier notifier,
    bool isAuthenticated,
  ) async {
    if (!isAuthenticated) {
      final action = await AuthGateDialog.show(
        context,
        message: 'Connectez-vous pour valider votre rendez-vous chez ${salon.salonNom}.',
      );
      if (action == null || !context.mounted) return;
      final loggedIn = await context.push<bool>(
        action == 'register' ? RouteNames.register : RouteNames.login,
      );
      if (loggedIn != true || !context.mounted) return;
    }

    if (salon.dateHeurePrevue == null) {
      final picked = await _ouvrirSelecteurDateHeure(context, salon, notifier);
      if (picked != true) return;
    }

    final salonSnapshot = salon.copyWith();

    try {
      final ok = await notifier.validerSalon(salon.slugSalon);
      if (context.mounted && ok) {
        ref.invalidate(mesRendezVousProvider);
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 38),
              ),
              const SizedBox(height: 14),
              Text(
                'Rendez-vous confirmé !',
                style: TextStyle(
                  fontSize: context.fontSize(19),
                  fontWeight: FontWeight.bold,
                  color: context.adaptiveTextColor(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Votre réservation chez ${salon.salonNom} a été enregistrée avec succès.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.fontSize(13),
                  color: context.adaptiveSubtextColor(),
                ),
              ),
              const SizedBox(height: 16),
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
                    _buildRecapRow(context, icon: Icons.store, label: 'Salon', valeur: salon.salonNom),
                    const Divider(height: 14),
                    _buildRecapRow(context, icon: Icons.event, label: 'Date & Heure', valeur: dateTexte),
                    const Divider(height: 14),
                    _buildRecapRow(
                      context,
                      icon: Icons.person_outline,
                      label: 'Coiffeur',
                      valeur: salon.coiffeurNom ?? 'Sans préférence (Automatique)',
                    ),
                    const Divider(height: 14),
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
              const SizedBox(height: 20),
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
            fontSize: context.fontSize(12),
            color: context.adaptiveSubtextColor(),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            valeur,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: context.fontSize(12.5),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valeurColor ?? context.adaptiveTextColor(),
            ),
          ),
        ),
      ],
    );
  }

  static String _formaterDateHeureFr(DateTime dt) {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const mois = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    final jourNom = jours[dt.weekday - 1];
    final jourNum = dt.day.toString().padLeft(2, '0');
    final moisNom = mois[dt.month - 1];
    final heure = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$jourNom $jourNum $moisNom à ${heure}h$min';
  }
}

// ============================================================================
// COMPOSANT : SÉLECTION DU COIFFEUR
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
        maxHeight: MediaQuery.of(context).size.height * 0.70,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          fontSize: context.fontSize(12),
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
                _buildOptionTile(
                  context,
                  isDark: isDark,
                  isSelected: selectedCoiffeurId == null,
                  icon: Icons.auto_awesome,
                  title: 'Sans préférence (Premier disponible)',
                  subtitle: 'Attribution automatique du meilleur coiffeur disponible.',
                  onTap: () async {
                    await onSelect(null, null);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                coiffeursAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (coiffeurs) {
                    return Column(
                      children: coiffeurs.map((c) {
                        final idAffectation = c.affectationId ?? c.id;
                        final isSelected = selectedCoiffeurId == idAffectation;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildOptionTile(
                            context,
                            isDark: isDark,
                            isSelected: isSelected,
                            avatarUrl: c.photoProfilUrl,
                            title: c.displayName,
                            subtitle: c.biographie?.isNotEmpty == true
                                ? c.biographie!
                                : (c.anneeExperience > 0 ? '${c.anneeExperience} ans d\'expérience' : 'Styliste professionnel'),
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

  Widget _buildOptionTile(
    BuildContext context, {
    required bool isDark,
    required bool isSelected,
    IconData? icon,
    String? avatarUrl,
    required String title,
    required String subtitle,
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
              ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown).withValues(alpha: 0.08)
              : (isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.4) : Colors.white),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown).withValues(alpha: 0.15),
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? Icon(icon ?? Icons.person, color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.fontSize(13.5),
                      fontWeight: FontWeight.w600,
                      color: context.adaptiveTextColor(),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.fontSize(11.5),
                      color: context.adaptiveSubtextColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown) : Colors.grey.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// COMPOSANT : SÉLECTION DE DATE & CRÉNEAU AVEC BOUTON FIXE EN BAS
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
      _selectedDate = DateTime(now.year, now.month, now.day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // En-tête de la modale
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choisir votre créneau',
                        style: TextStyle(
                          fontSize: context.fontSize(16),
                          fontWeight: FontWeight.bold,
                          color: context.adaptiveTextColor(),
                        ),
                      ),
                      Text(
                        '${widget.salonNom} • Durée : ${widget.dureeFormatee}',
                        style: TextStyle(
                          fontSize: context.fontSize(12),
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

          // Zone défilable pour la date et les créneaux
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Sélecteur de date horizontal (14 prochains jours)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1. Choisissez le jour',
                      style: TextStyle(
                        fontSize: context.fontSize(13.5),
                        fontWeight: FontWeight.w700,
                        color: context.adaptiveTextColor(),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: const Text('Calendrier'),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _choisirDateCalendrier,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Bandeau des 14 prochains jours
                _buildHorizontalDaysStrip(isDark),

                const SizedBox(height: 12),

                // Alerte horaires du salon
                if (horaireDuJour != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSalonFerme
                          ? Colors.orange.withValues(alpha: 0.12)
                          : Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSalonFerme ? Colors.orange : Colors.green.shade400,
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
                                ? 'Salon habituellement fermé ce jour.'
                                : 'Horaires : ${horaireDuJour!.plageHoraire}',
                            style: TextStyle(
                              fontSize: context.fontSize(11.5),
                              fontWeight: FontWeight.w500,
                              color: isSalonFerme ? Colors.orange : Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Filtres rapides d'horaire
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '2. À partir de quelle heure ?',
                      style: TextStyle(
                        fontSize: context.fontSize(13.5),
                        fontWeight: FontWeight.w700,
                        color: context.adaptiveTextColor(),
                      ),
                    ),
                    if (_heureMinimale != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _heureMinimale = null;
                            _selectedCreneau = null;
                          });
                        },
                        child: const Text(
                          'Tous les horaires',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildHeurePill('Toute la journée', null, isDark),
                      const SizedBox(width: 8),
                      _buildHeurePill('Matin dès 10h', const TimeOfDay(hour: 10, minute: 0), isDark),
                      const SizedBox(width: 8),
                      _buildHeurePill('Après-midi dès 14h', const TimeOfDay(hour: 14, minute: 0), isDark),
                      const SizedBox(width: 8),
                      _buildHeurePill('Soir dès 17h', const TimeOfDay(hour: 17, minute: 0), isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Titre et badges créneaux
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '3. Disponibilités en direct',
                      style: TextStyle(
                        fontSize: context.fontSize(13.5),
                        fontWeight: FontWeight.w700,
                        color: context.adaptiveTextColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Liste / Grille des créneaux
                disponibilitesAsync.when(
                  loading: () => Container(
                    padding: const EdgeInsets.all(28),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Recherche des créneaux disponibles...',
                          style: TextStyle(
                            fontSize: context.fontSize(12),
                            color: context.adaptiveSubtextColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  error: (err, _) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 8),
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
                            const Icon(Icons.event_busy_outlined, size: 32, color: Colors.orange),
                            const SizedBox(height: 6),
                            Text(
                              'Aucun créneau disponible ce jour',
                              style: TextStyle(
                                fontSize: context.fontSize(13.5),
                                fontWeight: FontWeight.bold,
                                color: context.adaptiveTextColor(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Le salon n\'a pas de disponibilité suffisante (${widget.dureeFormatee}) à cette date. Veuillez choisir un autre jour ci-dessus.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.fontSize(11.5),
                                color: context.adaptiveSubtextColor(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            Text(
                              'Durée requise : ${widget.dureeFormatee}',
                              style: TextStyle(
                                fontSize: context.fontSize(11.5),
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
                                    creneau.heureDebutFormatee,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    ),
                                  ),
                                  if (creneau.coiffeurNom != null && widget.coiffeurId == null)
                                    Text(
                                      creneau.coiffeurNom!,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isSelected ? Colors.white70 : context.adaptiveSubtextColor(),
                                      ),
                                    ),
                                ],
                              ),
                              selected: isSelected,
                              backgroundColor: isDark
                                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                                  : AppColors.figmaInputBg,
                              selectedColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                              labelStyle: TextStyle(
                                fontSize: context.fontSize(12),
                                color: isSelected ? Colors.white : context.adaptiveTextColor(),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                                      : (isDark ? AppColors.darkBorder : AppColors.border),
                                  width: isSelected ? 1.5 : 0.8,
                                ),
                              ),
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() => _selectedCreneau = creneau);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // =========================================================
          // BOUTON PERSISTANT FIXÉ EN BAS (STICKY BOTTOM BAR)
          // =========================================================
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 0.8,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCreneau != null
                              ? 'Créneau sélectionné'
                              : 'Aucun créneau choisi',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.adaptiveSubtextColor(),
                          ),
                        ),
                        Text(
                          _selectedCreneau != null
                              ? '${_selectedCreneau!.heureDebutFormatee} - ${_selectedCreneau!.heureFinFormatee}'
                              : 'Touchez une heure ci-dessus',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _selectedCreneau != null
                                ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                                : context.adaptiveSubtextColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.figmaBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _selectedCreneau == null ? null : _confirmer,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Valider le rdv',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.check, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalDaysStrip(bool isDark) {
    final now = DateTime.now();
    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = DateTime(now.year, now.month, now.day).add(Duration(days: index));
          final isSelected = _selectedDate.year == day.year &&
              _selectedDate.month == day.month &&
              _selectedDate.day == day.day;

          final labelJour = index == 0
              ? 'Auj.'
              : (index == 1 ? 'Dem.' : _jourCourt(day.weekday));

          return InkWell(
            onTap: () {
              setState(() {
                _selectedDate = day;
                _selectedCreneau = null;
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                    : (isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5) : AppColors.figmaInputBg),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                  width: isSelected ? 1.5 : 0.8,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    labelJour,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : context.adaptiveSubtextColor(),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : context.adaptiveTextColor(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeurePill(String label, TimeOfDay? time, bool isDark) {
    final isSelected = _heureMinimale?.hour == time?.hour && _heureMinimale?.minute == time?.minute;
    return InkWell(
      onTap: () {
        setState(() {
          _heureMinimale = time;
          _selectedCreneau = null;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : context.adaptiveTextColor(),
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

  static String _jourCourt(int weekday) {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return jours[weekday - 1];
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
}
