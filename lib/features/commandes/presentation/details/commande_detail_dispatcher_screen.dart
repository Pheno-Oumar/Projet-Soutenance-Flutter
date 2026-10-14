import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/commande_repository.dart';
import '../../data/models/commande_model.dart';
import 'details_commande_annuler_screen.dart';
import 'details_commande_en_attente_screen.dart';
import 'details_commande_recupere_screen.dart';
import 'details_commande_rejette_screen.dart';
import 'details_commande_validee_screen.dart';

class CommandeDetailDispatcherScreen extends ConsumerStatefulWidget {
  final int commandeId;
  final CommandeModel? initialCommande;

  const CommandeDetailDispatcherScreen({
    super.key,
    required this.commandeId,
    this.initialCommande,
  });

  @override
  ConsumerState<CommandeDetailDispatcherScreen> createState() =>
      _CommandeDetailDispatcherScreenState();
}

class _CommandeDetailDispatcherScreenState
    extends ConsumerState<CommandeDetailDispatcherScreen> {
  CommandeModel? _commande;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialCommande != null) {
      _commande = widget.initialCommande;
      _isLoading = false;
    } else {
      _loadCommande();
    }
  }

  Future<void> _loadCommande() async {
    final repo = ref.read(commandeRepositoryProvider);
    final res = await repo.getCommandeDetail(widget.commandeId);
    if (mounted) {
      setState(() {
        _commande = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.figmaBrown),
        ),
      );
    }

    final cmd = _commande!;
    switch (cmd.statut) {
      case StatutCommande.enAttente:
        return DetailsCommandeEnAttenteScreen(commande: cmd);
      case StatutCommande.validee:
        return DetailsCommandeValideeScreen(commande: cmd);
      case StatutCommande.recuperee:
        return DetailsCommandeRecupereScreen(commande: cmd);
      case StatutCommande.rejette:
        return DetailsCommandeRejetteScreen(commande: cmd);
      case StatutCommande.annulee:
        return DetailsCommandeAnnulerScreen(commande: cmd);
    }
  }
}
