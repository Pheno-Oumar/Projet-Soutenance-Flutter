import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../data/commande_repository.dart';
import '../data/models/commande_model.dart';
import 'details/details_commande_annuler_screen.dart';
import 'details/details_commande_en_attente_screen.dart';
import 'details/details_commande_recupere_screen.dart';
import 'details/details_commande_rejette_screen.dart';
import 'details/details_commande_validee_screen.dart';
import 'widgets/commande_card_widget.dart';

enum CommandeTabFilter {
  tout('Tout', null),
  enAttente('En attente', StatutCommande.enAttente),
  validee('Validée', StatutCommande.validee),
  recuperee('Récupérée', StatutCommande.recuperee),
  rejette('Rejetée', StatutCommande.rejette),
  annulee('Annulée', StatutCommande.annulee);

  final String label;
  final StatutCommande? statut;

  const CommandeTabFilter(this.label, this.statut);
}

class MesCommandesScreen extends ConsumerStatefulWidget {
  final CommandeTabFilter initialFilter;

  const MesCommandesScreen({
    super.key,
    this.initialFilter = CommandeTabFilter.tout,
  });

  @override
  ConsumerState<MesCommandesScreen> createState() => _MesCommandesScreenState();
}

class _MesCommandesScreenState extends ConsumerState<MesCommandesScreen> {
  late CommandeTabFilter _selectedFilter;
  List<CommandeModel> _allCommandes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    // Données statiques immédiates pour visualiser toutes les interfaces instantanément
    _allCommandes = ref.read(commandeRepositoryProvider).getMockCommandesSync();
    _isLoading = false;
    _fetchCommandes();
  }

  Future<void> _fetchCommandes() async {
    final repo = ref.read(commandeRepositoryProvider);
    final list = await repo.getCommandes();
    if (mounted && list.isNotEmpty) {
      setState(() {
        _allCommandes = list;
      });
    }
  }

  List<CommandeModel> get _filteredCommandes {
    if (_selectedFilter.statut == null) {
      return _allCommandes;
    }
    return _allCommandes
        .where((c) => c.statut == _selectedFilter.statut)
        .toList();
  }

  void _navigateToDetail(CommandeModel commande) {
    Widget targetScreen;
    switch (commande.statut) {
      case StatutCommande.enAttente:
        targetScreen = DetailsCommandeEnAttenteScreen(commande: commande);
        break;
      case StatutCommande.validee:
        targetScreen = DetailsCommandeValideeScreen(commande: commande);
        break;
      case StatutCommande.recuperee:
        targetScreen = DetailsCommandeRecupereScreen(commande: commande);
        break;
      case StatutCommande.rejette:
        targetScreen = DetailsCommandeRejetteScreen(commande: commande);
        break;
      case StatutCommande.annulee:
        targetScreen = DetailsCommandeAnnulerScreen(commande: commande);
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
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
          'Mes commandes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 14),

          // ==============================================================
          // 1. BARRE D'ONGLETS / FILTRES (Tous les statuts)
          // ==============================================================
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: CommandeTabFilter.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = CommandeTabFilter.values[index];
                final isSelected = filter == _selectedFilter;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                          : (isDark ? AppColors.darkSurface : const Color(0xFFEEE1D6)),
                      borderRadius: BorderRadius.circular(16),
                      border: (!isSelected && isDark) ? Border.all(color: AppColors.darkBorder) : null,
                    ),
                    child: Text(
                      filter.label,
                      style: TextStyle(
                        color: isSelected
                            ? (isDark ? const Color(0xFF1E1610) : Colors.white)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.figmaBrown),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ==============================================================
          // 2. LISTE DES COMMANDES
          // ==============================================================
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchCommandes,
                    color: AppColors.figmaBrown,
                    child: _filteredCommandes.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            itemCount: _filteredCommandes.length,
                            itemBuilder: (context, index) {
                              final cmd = _filteredCommandes[index];
                              return CommandeCardWidget(
                                commande: cmd,
                                onTapDetails: () => _navigateToDetail(cmd),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFFBF4ED),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 36,
                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aucune commande ${_selectedFilter.label.toLowerCase()}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1817),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Retrouvez ici vos commandes de produits capillaires et cosmétiques.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.salons),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.figmaBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Explorer les salons & boutiques',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
