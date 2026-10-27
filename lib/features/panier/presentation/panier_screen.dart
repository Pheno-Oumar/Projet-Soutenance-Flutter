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

class PanierScreen extends ConsumerStatefulWidget {
  const PanierScreen({super.key});

  @override
  ConsumerState<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends ConsumerState<PanierScreen> {
  int _selectedSalonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(panierStateProvider);
    final notifier = ref.read(panierStateProvider.notifier);
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
          'Mon Panier Produits',
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
                  setState(() => _selectedSalonIndex = 0);
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
                            child: _buildSalonCartCard(
                              context: context,
                              panier: currentSalon!,
                              state: state,
                              isDark: isDark,
                              notifier: notifier,
                              isAuthenticated: authState.isAuthenticated,
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
  }) {
    final salonTitle = panier.salonNom ?? panier.slugSalon ?? 'Salon de beauté';

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
                  child: const Icon(Icons.store, color: Colors.white, size: 17),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salonTitle,
                        style: TextStyle(
                          fontSize: context.fontSize(15),
                          fontWeight: FontWeight.w700,
                          color: context.adaptiveTextColor(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${panier.nombreArticles} article${panier.nombreArticles > 1 ? "s" : ""} • Total : ${panier.montantTotal.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          fontSize: context.fontSize(12),
                          color: context.adaptiveSubtextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Vider ce salon',
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Vider le panier de $salonTitle'),
                        content: const Text('Voulez-vous retirer tous les articles de ce salon ?'),
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
                    if (confirm == true && panier.slugSalon != null) {
                      await notifier.viderPanier(panier.slugSalon!);
                    }
                  },
                ),
              ],
            ),
          ),

          // Liste des articles du panier
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: panier.lignes.map((ligne) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: _buildLigneItem(
                    context: context,
                    ligne: ligne,
                    slugSalon: panier.slugSalon ?? '',
                    isDark: isDark,
                    notifier: notifier,
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Informations pratiques (Retrait & Paiement)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store_mall_directory_outlined,
                        size: 16,
                        color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Retrait direct au salon : $salonTitle',
                          style: TextStyle(
                            fontSize: context.fontSize(12),
                            fontWeight: FontWeight.w600,
                            color: context.adaptiveTextColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 16,
                        color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Paiement sur place au comptoir ou via Mobile Money',
                          style: TextStyle(
                            fontSize: context.fontSize(11.5),
                            color: context.adaptiveSubtextColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (ligne.imageUrl != null && ligne.imageUrl!.isNotEmpty)
                ? (ligne.imageUrl!.startsWith('http')
                    ? Image.network(
                        ligne.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.spa_rounded,
                          size: 20,
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        ),
                      )
                    : Image.asset(
                        ligne.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.spa_rounded,
                          size: 20,
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        ),
                      ))
                : Icon(
                    Icons.spa_rounded,
                    size: 20,
                    color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  ),
          ),
        ),
        const SizedBox(width: 10),

        // Détails produit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ligne.produitNom,
                style: TextStyle(
                  fontSize: context.fontSize(13.5),
                  fontWeight: FontWeight.w600,
                  color: context.adaptiveTextColor(),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${ligne.prixUnitaire.toStringAsFixed(0)} FCFA / unité',
                style: TextStyle(
                  fontSize: context.fontSize(11.5),
                  color: context.adaptiveSubtextColor(),
                ),
              ),
            ],
          ),
        ),

        // Sélecteur de quantité
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF3ECE4),
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
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  child: Icon(
                    ligne.quantite == 1
                        ? Icons.delete_outline_rounded
                        : Icons.remove_rounded,
                    size: 15,
                    color: isDark ? Colors.white70 : AppColors.figmaBrown,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  '${ligne.quantite}',
                  style: TextStyle(
                    fontSize: context.fontSize(12.5),
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
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  child: Icon(
                    Icons.add_rounded,
                    size: 15,
                    color: isDark ? Colors.white70 : AppColors.figmaBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Sous-total
        Text(
          '${ligne.sousTotal.toStringAsFixed(0)} F',
          style: TextStyle(
            fontSize: context.fontSize(13.5),
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.figmaActiveGold : AppColors.primaryDark,
          ),
        ),
      ],
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
                Icons.shopping_bag_outlined,
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
              'Découvrez nos produits capillaires de qualité salon et commandez directement.',
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
    List<PanierModel> paniers,
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
            final salonName = p.salonNom ?? p.slugSalon ?? 'Salon ${i + 1}';
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
                        salonName,
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
                          '${p.nombreArticles}',
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
    PanierModel salon,
    bool isDark,
    PanierNotifier notifier,
    bool isAuthenticated,
    bool isValidating,
  ) {
    final salonTitle = salon.salonNom ?? salon.slugSalon ?? 'Salon de beauté';

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
                          salonTitle,
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
                        ' • ${salon.nombreArticles} article${salon.nombreArticles > 1 ? "s" : ""}',
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
                  : () => _validerPanierPourSalon(
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
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Commander',
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

  Future<void> _validerPanierPourSalon(
    BuildContext context,
    PanierModel panier,
    PanierNotifier notifier,
    bool isAuthenticated,
  ) async {
    final salonTitle = panier.salonNom ?? panier.slugSalon ?? 'Salon de beauté';
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
        isDark: Theme.of(context).brightness == Brightness.dark,
        notifier: notifier,
        ref: ref,
      );
    }
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


  // _afficherSuccesMultiCommandes removed
}
/*
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
*/

