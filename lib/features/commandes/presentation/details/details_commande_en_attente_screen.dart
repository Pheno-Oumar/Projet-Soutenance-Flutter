import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/commande_repository.dart';
import '../../data/models/commande_model.dart';
import '../widgets/commande_articles_widget.dart';
import '../widgets/commande_detail_header_widget.dart';
import '../widgets/commande_livraison_widget.dart';
import '../widgets/commande_recap_widget.dart';

class DetailsCommandeEnAttenteScreen extends ConsumerStatefulWidget {
  final CommandeModel commande;

  const DetailsCommandeEnAttenteScreen({
    super.key,
    required this.commande,
  });

  @override
  ConsumerState<DetailsCommandeEnAttenteScreen> createState() =>
      _DetailsCommandeEnAttenteScreenState();
}

class _DetailsCommandeEnAttenteScreenState
    extends ConsumerState<DetailsCommandeEnAttenteScreen> {
  bool _isCancelling = false;

  Future<void> _handleAnnuler() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Annuler la commande ?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? AppColors.darkTextPrimary : Colors.black,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir annuler cette commande en attente ?',
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Non',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);
    await ref.read(commandeRepositoryProvider).annulerCommande(widget.commande.id);
    if (!mounted) return;
    setState(() => _isCancelling = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Votre commande a été annulée avec succès.'),
        backgroundColor: Color(0xFFE53935),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
            CommandeDetailHeaderWidget(commande: widget.commande),
            const SizedBox(height: 18),

            // 2. ARTICLES (2)
            CommandeArticlesWidget(articles: widget.commande.lignes),
            const SizedBox(height: 16),

            // 3. RÉCAPITULATIF FINANCIER
            CommandeRecapWidget(commande: widget.commande),
            const SizedBox(height: 16),

            // 4. LIEU DE LIVRAISON
            CommandeLivraisonWidget(commande: widget.commande),
            const SizedBox(height: 32),

            // 5. BOUTON D'ACTION : ANNULER LA COMMANDE (Outline rouge)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _isCancelling ? null : _handleAnnuler,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE53935), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCancelling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE53935),
                        ),
                      )
                    : const Text(
                        'Annuler la commande',
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 14.5,
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
