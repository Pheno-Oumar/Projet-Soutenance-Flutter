import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_names.dart';
import '../../data/models/commande_model.dart';
import '../widgets/commande_articles_widget.dart';
import '../widgets/commande_detail_header_widget.dart';
import '../widgets/commande_livraison_widget.dart';
import '../widgets/commande_recap_widget.dart';

class DetailsCommandeAnnulerScreen extends ConsumerWidget {
  final CommandeModel commande;

  const DetailsCommandeAnnulerScreen({
    super.key,
    required this.commande,
  });

  void _repasserCommande(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Articles ajoutés à votre panier !'),
        backgroundColor: AppColors.figmaBrown,
        duration: Duration(seconds: 2),
      ),
    );
    context.push(RouteNames.panier);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Details commande',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CARTE EN-TÊTE
            CommandeDetailHeaderWidget(commande: commande),
            const SizedBox(height: 18),

            // 2. ARTICLES (2)
            CommandeArticlesWidget(articles: commande.lignes),
            const SizedBox(height: 16),

            // 3. RÉCAPITULATIF FINANCIER
            CommandeRecapWidget(commande: commande),
            const SizedBox(height: 16),

            // 4. LIEU DE LIVRAISON
            CommandeLivraisonWidget(commande: commande),
            const SizedBox(height: 32),

            // 5. BOUTON : REPASSER LA COMMANDE (Marron plein)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _repasserCommande(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.figmaBrown,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Repasser la commande',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
