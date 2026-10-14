import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'providers/panier_provider.dart';

class PanierScreen extends ConsumerWidget {
  const PanierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(panierStateProvider);
    final notifier = ref.read(panierStateProvider.notifier);
    final panier = state.panier;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Panier'),
        actions: [
          if (panier != null && panier.lignes.isNotEmpty && panier.slugSalon != null)
            IconButton(
              tooltip: 'Vider le panier',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => notifier.vider(panier.slugSalon!),
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
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => notifier.chargerPanier(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : (panier == null || panier.lignes.isEmpty)
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
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Découvrez nos produits capillaires de qualité salon',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: panier.lignes.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = panier.lignes[index];
                              return Card(
                                color: isDark ? AppColors.darkSurface : Colors.white,
                                elevation: isDark ? 0 : 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isDark
                                      ? const BorderSide(color: AppColors.darkBorder)
                                      : BorderSide.none,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.spa_outlined, color: AppColors.figmaActiveGold),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.produitNom,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              '${item.prixUnitaire.toStringAsFixed(0)} FCFA x ${item.quantite}',
                                              style: TextStyle(
                                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${item.sousTotal.toStringAsFixed(0)} FCFA',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.figmaActiveGold : AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.surface,
                            border: Border(
                              top: BorderSide(
                                color: isDark ? AppColors.darkBorder : AppColors.divider,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total estimé',
                                    style: TextStyle(
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${panier.montantTotal.toStringAsFixed(0)} FCFA',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.figmaActiveGold : AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.figmaActiveGold,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  // Passer commande
                                },
                                child: const Text('Commander'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
