import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/auth_gate_dialog.dart';
import '../../../routing/route_names.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../commandes/data/models/commande_model.dart';
import '../data/models/panier_model.dart';
import 'providers/panier_provider.dart';

class PanierScreen extends ConsumerWidget {
  const PanierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(panierStateProvider);
    final notifier = ref.read(panierStateProvider.notifier);
    final authState = ref.watch(authStateProvider);
    final paniers = state.paniers;
    final hasMultipleSalons = paniers.length > 1;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mon Panier',
          style: TextStyle(
            fontSize: context.fontSize(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (paniers.isNotEmpty)
            IconButton(
              tooltip: 'Vider tous les paniers',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Vider le panier'),
                    content: const Text('Voulez-vous vraiment vider tous vos articles ?'),
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
                  await notifier.viderTous();
                }
              },
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.fontSize(14),
                            color: context.adaptiveTextColor(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => notifier.chargerPaniers(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : paniers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: isDark
                                ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                                : AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Votre panier est vide',
                            style: TextStyle(
                              fontSize: context.fontSize(18),
                              fontWeight: FontWeight.w600,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Découvrez nos produits capillaires de qualité salon',
                            style: TextStyle(
                              fontSize: context.fontSize(13.5),
                              color: context.adaptiveSubtextColor(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              14,
                              16,
                              hasMultipleSalons ? 20 : 100,
                            ),
                            itemCount: paniers.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 18),
                            itemBuilder: (itemCtx, index) {
                              final panier = paniers[index];
                              return _buildSalonCartCard(
                                context: context,
                                panier: panier,
                                state: state,
                                isDark: isDark,
                                notifier: notifier,
                                isAuthenticated: authState.isAuthenticated,
                                ref: ref,
                              );
                            },
                          ),
                        ),

                        // Barre inférieure de validation globale (si plusieurs salons)
                        if (hasMultipleSalons)
                          _buildGlobalCheckoutBar(
                            context: context,
                            state: state,
                            isDark: isDark,
                            notifier: notifier,
                            isAuthenticated: authState.isAuthenticated,
                            ref: ref,
                          ),
                      ],
                    ),
    );
  }

  // ==========================================
  // CARTE DE PANIER PAR SALON
  // ==========================================
  Widget _buildSalonCartCard({
    required BuildContext context,
    required PanierModel panier,
    required PanierState state,
    required bool isDark,
    required PanierNotifier notifier,
    required bool isAuthenticated,
    required WidgetRef ref,
  }) {
    final salonTitle = panier.salonNom ?? panier.slugSalon ?? 'Salon de beauté';
    final isThisSalonValidating = state.isValidating && state.validatingSalonSlug == panier.slugSalon;
    final isAnyValidating = state.isValidating;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du salon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF26201B)
                  : AppColors.figmaBrown.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    salonTitle,
                    style: TextStyle(
                      fontSize: context.fontSize(14),
                      fontWeight: FontWeight.w800,
                      color: context.adaptiveTextColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Vider ce salon',
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: AppColors.error.withValues(alpha: 0.8),
                  visualDensity: VisualDensity.compact,
                  onPressed: isAnyValidating
                      ? null
                      : () {
                          if (panier.slugSalon != null) {
                            notifier.viderPanier(panier.slugSalon!);
                          }
                        },
                ),
              ],
            ),
          ),

          // Lignes d'articles du salon
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            itemCount: panier.lignes.length,
            separatorBuilder: (_, index) => Divider(
              height: 18,
              color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
            ),
            itemBuilder: (context, lIdx) {
              final ligne = panier.lignes[lIdx];
              return _buildLigneItem(
                context: context,
                ligne: ligne,
                slugSalon: panier.slugSalon ?? '',
                isDark: isDark,
                notifier: notifier,
              );
            },
          ),

          // Pied de carte : Sous-total & Bouton "Valider ce salon"
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total salon (${panier.nombreArticles})',
                      style: TextStyle(
                        fontSize: context.fontSize(11.5),
                        color: context.adaptiveSubtextColor(),
                      ),
                    ),
                    Text(
                      '${panier.montantTotal.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontSize: context.fontSize(16),
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: isAnyValidating
                      ? null
                      : () async {
                          if (!isAuthenticated) {
                            final action = await AuthGateDialog.show(
                              context,
                              salonNom: salonTitle,
                              message: 'Veuillez vous connecter pour valider la commande de ce salon.',
                            );
                            if (action == null || !context.mounted) return;
                            final loggedIn = await context.push<bool>(
                              action == 'register' ? RouteNames.register : RouteNames.login,
                            );
                            if (loggedIn != true || !context.mounted) return;
                            await notifier.synchroniserApresConnexion();
                          }

                          if (panier.slugSalon != null && context.mounted) {
                            final freshState = ref.read(panierStateProvider);
                            final freshPanier = freshState.paniers.firstWhere(
                              (p) => p.slugSalon == panier.slugSalon,
                              orElse: () => panier,
                            );
                            if (freshPanier.lignes.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Le panier de ce salon est vide.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }
                            await _afficherConfirmationSalon(
                              context: context,
                              panier: freshPanier,
                              isDark: isDark,
                              notifier: notifier,
                              ref: ref,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.figmaActiveGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: isThisSalonValidating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Valider ce salon',
                              style: TextStyle(
                                fontSize: context.fontSize(12.5),
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
  // LIGNE DE PRODUIT
  // ==========================================
  Widget _buildLigneItem({
    required BuildContext context,
    required LignePanierModel ligne,
    required String slugSalon,
    required bool isDark,
    required PanierNotifier notifier,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image miniature
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF26201B) : AppColors.figmaCardBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ligne.imageUrl != null && ligne.imageUrl!.isNotEmpty
                ? Image.asset(
                    ligne.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.spa_rounded,
                      color: AppColors.figmaActiveGold,
                      size: 24,
                    ),
                  )
                : const Icon(
                    Icons.spa_rounded,
                    color: AppColors.figmaActiveGold,
                    size: 24,
                  ),
          ),
        ),
        const SizedBox(width: 12),

        // Détails produit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ligne.produitNom,
                style: TextStyle(
                  fontSize: context.fontSize(13.5),
                  fontWeight: FontWeight.w700,
                  color: context.adaptiveTextColor(),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '${ligne.prixUnitaire.toStringAsFixed(0)} FCFA / unité',
                style: TextStyle(
                  fontSize: context.fontSize(11.5),
                  color: context.adaptiveSubtextColor(),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sous-total : ${ligne.sousTotal.toStringAsFixed(0)} FCFA',
                style: TextStyle(
                  fontSize: context.fontSize(12),
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.figmaActiveGold : AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),

        // Sélecteur de quantité
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2E2620) : const Color(0xFFF3ECE4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  if (ligne.quantite > 1) {
                    notifier.modifierQuantite(
                      slugSalon: slugSalon,
                      produitId: ligne.produitId,
                      quantite: ligne.quantite - 1,
                    );
                  } else {
                    notifier.supprimerArticle(
                      slugSalon: slugSalon,
                      produitId: ligne.produitId,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Icon(
                    ligne.quantite == 1
                        ? Icons.delete_outline_rounded
                        : Icons.remove_rounded,
                    size: 16,
                    color: isDark ? Colors.white70 : AppColors.figmaBrown,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '${ligne.quantite}',
                  style: TextStyle(
                    fontSize: context.fontSize(13),
                    fontWeight: FontWeight.w700,
                    color: context.adaptiveTextColor(),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  notifier.modifierQuantite(
                    slugSalon: slugSalon,
                    produitId: ligne.produitId,
                    quantite: ligne.quantite + 1,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: isDark ? Colors.white70 : AppColors.figmaBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BARRE INFÉRIEURE : VALIDATION MULTI-SALONS
  // ==========================================
  Widget _buildGlobalCheckoutBar({
    required BuildContext context,
    required PanierState state,
    required bool isDark,
    required PanierNotifier notifier,
    required bool isAuthenticated,
    required WidgetRef ref,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total général (${state.totalArticles} articles)',
                    style: TextStyle(
                      fontSize: context.fontSize(12),
                      color: context.adaptiveSubtextColor(),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${state.montantTotalGlobal.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontSize: context.fontSize(19),
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.figmaActiveGold : AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.figmaBrown,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveValue(compact: 16.0, standard: 22.0),
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: state.isValidating
                  ? null
                  : () async {
                      if (!isAuthenticated) {
                        final action = await AuthGateDialog.show(
                          context,
                          message:
                              'Veuillez vous connecter pour valider toutes vos commandes dans les différents salons.',
                        );
                        if (action == null || !context.mounted) return;
                        final loggedIn = await context.push<bool>(
                          action == 'register' ? RouteNames.register : RouteNames.login,
                        );
                        if (loggedIn != true || !context.mounted) return;
                        await notifier.synchroniserApresConnexion();
                      }

                      if (context.mounted) {
                        final freshState = ref.read(panierStateProvider);
                        if (freshState.paniers.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Votre panier est vide.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        await _afficherConfirmationGlobale(
                          context: context,
                          state: freshState,
                          isDark: isDark,
                          notifier: notifier,
                          ref: ref,
                        );
                      }
                    },
              child: state.isValidating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Valider tous les paniers',
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
    );
  }

  // ==========================================
  // MODALE 1 : RÉCAPITULATIF PRÉ-COMMANDE SALON UNIQUE
  // ==========================================
  Future<void> _afficherConfirmationSalon({
    required BuildContext context,
    required PanierModel panier,
    required bool isDark,
    required PanierNotifier notifier,
    required WidgetRef ref,
  }) async {
    final salonTitle = panier.salonNom ?? panier.slugSalon ?? 'Salon de beauté';

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poignée supérieure
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // En-tête
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confirmation de commande',
                            style: TextStyle(
                              fontSize: context.fontSize(16),
                              fontWeight: FontWeight.w800,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                          Text(
                            salonTitle,
                            style: TextStyle(
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Contenu récapitulatif défilant
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Titre liste
                    Text(
                      'Articles (${panier.nombreArticles})',
                      style: TextStyle(
                        fontSize: context.fontSize(13),
                        fontWeight: FontWeight.w700,
                        color: context.adaptiveSubtextColor(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Lignes produits
                    ...panier.lignes.map((l) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF26201B) : AppColors.figmaCardBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: l.imageUrl != null && l.imageUrl!.isNotEmpty
                                    ? Image.asset(
                                        l.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.spa_rounded,
                                          color: AppColors.figmaActiveGold,
                                          size: 20,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.spa_rounded,
                                        color: AppColors.figmaActiveGold,
                                        size: 20,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.produitNom,
                                    style: TextStyle(
                                      fontSize: context.fontSize(13),
                                      fontWeight: FontWeight.w700,
                                      color: context.adaptiveTextColor(),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${l.quantite} × ${l.prixUnitaire.toStringAsFixed(0)} FCFA',
                                    style: TextStyle(
                                      fontSize: context.fontSize(11.5),
                                      color: context.adaptiveSubtextColor(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${l.sousTotal.toStringAsFixed(0)} FCFA',
                              style: TextStyle(
                                fontSize: context.fontSize(13),
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.figmaActiveGold : AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 12),
                    // Bloc Info Retrait & Paiement
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF26201B)
                            : AppColors.figmaBrown.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.store_mall_directory_outlined,
                                size: 18,
                                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Retrait en salon : $salonTitle',
                                  style: TextStyle(
                                    fontSize: context.fontSize(12),
                                    fontWeight: FontWeight.w600,
                                    color: context.adaptiveTextColor(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                size: 18,
                                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Paiement sur place au comptoir ou par Wave',
                                  style: TextStyle(
                                    fontSize: context.fontSize(12),
                                    color: context.adaptiveSubtextColor(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    // Récapitulatif Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total à payer',
                          style: TextStyle(
                            fontSize: context.fontSize(14),
                            fontWeight: FontWeight.w600,
                            color: context.adaptiveTextColor(),
                          ),
                        ),
                        Text(
                          '${panier.montantTotal.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            fontSize: context.fontSize(18),
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Boutons d'action
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: isDark ? AppColors.darkBorder : Colors.grey[400]!,
                            ),
                          ),
                          child: Text(
                            'Modifier mon panier',
                            style: TextStyle(
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w600,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.figmaActiveGold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Confirmer la commande',
                            style: TextStyle(
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final cmd = await notifier.validerPanierSalon(panier.slugSalon!);
      if (context.mounted) {
        if (cmd != null) {
          await _afficherSuccesCommande(
            context: context,
            panier: panier,
            commande: cmd,
            isDark: isDark,
          );
          await notifier.chargerPaniers();
        } else {
          final errorMsg = ref.read(panierStateProvider).error ??
              'Échec de validation de la commande. Veuillez réessayer.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  // ==========================================
  // MODALE 2 : SUCCÈS COMMANDE SALON UNIQUE
  // ==========================================
  Future<void> _afficherSuccesCommande({
    required BuildContext context,
    required PanierModel panier,
    required CommandeModel commande,
    required bool isDark,
  }) async {
    final salonTitle = panier.salonNom ?? panier.slugSalon ?? 'Salon de beauté';
    final numeroCommande = commande.numeroCommande.isNotEmpty
        ? commande.numeroCommande
        : '#COM-${commande.id.toString().padLeft(4, '0')}';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 40,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Commande validée avec succès !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.fontSize(18),
                    fontWeight: FontWeight.w800,
                    color: context.adaptiveTextColor(),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Votre commande auprès de $salonTitle a été transmise.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.fontSize(13),
                    color: context.adaptiveSubtextColor(),
                  ),
                ),
                const SizedBox(height: 18),

                // Carte récapitulative
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF26201B)
                        : AppColors.figmaBrown.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Numéro de commande',
                            style: TextStyle(
                              fontSize: context.fontSize(12.5),
                              color: context.adaptiveSubtextColor(),
                            ),
                          ),
                          Text(
                            numeroCommande,
                            style: TextStyle(
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.figmaActiveGold : AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      if (commande.codeRetrait != null && commande.codeRetrait!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Code de retrait',
                              style: TextStyle(
                                fontSize: context.fontSize(12.5),
                                color: context.adaptiveSubtextColor(),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.figmaActiveGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                commande.codeRetrait!,
                                style: TextStyle(
                                  fontSize: context.fontSize(13),
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.figmaActiveGold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Articles commandés',
                            style: TextStyle(
                              fontSize: context.fontSize(12.5),
                              color: context.adaptiveSubtextColor(),
                            ),
                          ),
                          Text(
                            '${panier.nombreArticles} article(s)',
                            style: TextStyle(
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w600,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(
                        height: 16,
                        color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Montant total à payer',
                            style: TextStyle(
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w700,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                          Text(
                            '${panier.montantTotal.toStringAsFixed(0)} FCFA',
                            style: TextStyle(
                              fontSize: context.fontSize(16),
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : Colors.grey[400]!,
                          ),
                        ),
                        child: Text(
                          'Continuer mes achats',
                          style: TextStyle(
                            fontSize: context.fontSize(13),
                            fontWeight: FontWeight.w600,
                            color: context.adaptiveTextColor(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        label: Text(
                          'Voir mes commandes',
                          style: TextStyle(
                            fontSize: context.fontSize(13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push(RouteNames.mesCommandes);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.figmaBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // MODALE 3 : RÉCAPITULATIF VALIDATION GLOBALE MULTI-SALONS
  // ==========================================
  Future<void> _afficherConfirmationGlobale({
    required BuildContext context,
    required PanierState state,
    required bool isDark,
    required PanierNotifier notifier,
    required WidgetRef ref,
  }) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poignée supérieure
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // En-tête
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.figmaBrown.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: AppColors.figmaBrown,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Validation Multi-Salons',
                            style: TextStyle(
                              fontSize: context.fontSize(16),
                              fontWeight: FontWeight.w800,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                          Text(
                            '${state.paniers.length} salons partenaires concernés',
                            style: TextStyle(
                              fontSize: context.fontSize(12.5),
                              color: context.adaptiveSubtextColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Contenu récapitulatif
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.figmaActiveGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.figmaActiveGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: AppColors.figmaActiveGold,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Une commande indépendante sera transmise à chacun des salons partenaires.',
                              style: TextStyle(
                                fontSize: context.fontSize(12),
                                color: context.adaptiveTextColor(),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Liste des salons
                    ...state.paniers.map((p) {
                      final title = p.salonNom ?? p.slugSalon ?? 'Salon';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF26201B)
                              : AppColors.figmaBrown.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.storefront_rounded,
                                      size: 16,
                                      color: isDark
                                          ? AppColors.figmaActiveGold
                                          : AppColors.figmaBrown,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: context.fontSize(14),
                                        fontWeight: FontWeight.w700,
                                        color: context.adaptiveTextColor(),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${p.montantTotal.toStringAsFixed(0)} FCFA',
                                  style: TextStyle(
                                    fontSize: context.fontSize(14),
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.figmaActiveGold
                                        : AppColors.figmaBrown,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${p.nombreArticles} article(s) : ${p.lignes.map((l) => "${l.quantite}x ${l.produitNom}").join(", ")}',
                              style: TextStyle(
                                fontSize: context.fontSize(12),
                                color: context.adaptiveSubtextColor(),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),
                    // Récapitulatif Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total général (${state.totalArticles} articles)',
                          style: TextStyle(
                            fontSize: context.fontSize(14),
                            fontWeight: FontWeight.w600,
                            color: context.adaptiveTextColor(),
                          ),
                        ),
                        Text(
                          '${state.montantTotalGlobal.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            fontSize: context.fontSize(19),
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.figmaActiveGold : AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Boutons d'action
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: isDark ? AppColors.darkBorder : Colors.grey[400]!,
                            ),
                          ),
                          child: Text(
                            'Annuler',
                            style: TextStyle(
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w600,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.figmaBrown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Valider tout',
                            style: TextStyle(
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final paniersAvant = List<PanierModel>.from(state.paniers);
      final totalAvant = state.montantTotalGlobal;
      final orders = await notifier.validerTousLesPaniers();
      if (context.mounted) {
        if (orders.isNotEmpty) {
          await _afficherSuccesMultiCommandes(
            context: context,
            commandes: orders,
            paniers: paniersAvant,
            montantTotal: totalAvant,
            isDark: isDark,
          );
          await notifier.chargerPaniers();
        } else {
          final errorMsg = ref.read(panierStateProvider).error ??
              'Une erreur est survenue lors de la validation des commandes.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  // ==========================================
  // MODALE 4 : SUCCÈS VALIDATION GLOBALE MULTI-SALONS
  // ==========================================
  Future<void> _afficherSuccesMultiCommandes({
    required BuildContext context,
    required List<CommandeModel> commandes,
    required List<PanierModel> paniers,
    required double montantTotal,
    required bool isDark,
  }) async {
    final nbSalons = paniers.length;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 40,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Toutes vos commandes sont validées !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.fontSize(18),
                    fontWeight: FontWeight.w800,
                    color: context.adaptiveTextColor(),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$nbSalons commandes ont été enregistrées avec succès auprès de vos salons.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.fontSize(13),
                    color: context.adaptiveSubtextColor(),
                  ),
                ),
                const SizedBox(height: 18),

                // Cartes de récapitulatif par salon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF26201B)
                        : AppColors.figmaBrown.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      ...paniers.map((p) {
                        final title = p.salonNom ?? p.slugSalon ?? 'Salon';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: context.fontSize(13),
                                    fontWeight: FontWeight.w600,
                                    color: context.adaptiveTextColor(),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${p.montantTotal.toStringAsFixed(0)} FCFA',
                                style: TextStyle(
                                  fontSize: context.fontSize(13),
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      Divider(
                        height: 18,
                        color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Montant total cumulé',
                            style: TextStyle(
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w700,
                              color: context.adaptiveTextColor(),
                            ),
                          ),
                          Text(
                            '${montantTotal.toStringAsFixed(0)} FCFA',
                            style: TextStyle(
                              fontSize: context.fontSize(16),
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : Colors.grey[400]!,
                          ),
                        ),
                        child: Text(
                          'Continuer mes achats',
                          style: TextStyle(
                            fontSize: context.fontSize(13),
                            fontWeight: FontWeight.w600,
                            color: context.adaptiveTextColor(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        label: Text(
                          'Voir mes commandes',
                          style: TextStyle(
                            fontSize: context.fontSize(13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push(RouteNames.mesCommandes);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.figmaBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
