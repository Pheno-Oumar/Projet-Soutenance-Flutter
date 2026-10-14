import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/rendezvous_model.dart';
import '../../data/rendezvous_repository.dart';
import '../providers/rendezvous_provider.dart';
import 'rendezvous_detail_a_venir_view.dart';
import 'rendezvous_detail_annule_view.dart';
import 'rendezvous_detail_passe_view.dart';

class RendezVousDetailScreen extends ConsumerStatefulWidget {
  final int id;
  final RendezVousModel? initialRdv;

  const RendezVousDetailScreen({
    super.key,
    required this.id,
    this.initialRdv,
  });

  @override
  ConsumerState<RendezVousDetailScreen> createState() => _RendezVousDetailScreenState();
}

class _RendezVousDetailScreenState extends ConsumerState<RendezVousDetailScreen> {
  RendezVousModel? _rdv;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rdv = widget.initialRdv;
    if (_rdv == null) {
      _chargerDetail();
    }
  }

  Future<void> _chargerDetail() async {
    setState(() => _isLoading = true);
    // 1. Chercher d'abord dans le provider
    final state = ref.read(mesRendezVousProvider);
    final found = state.allRendezVous.cast<RendezVousModel?>().firstWhere(
      (r) => r?.id == widget.id,
      orElse: () => null,
    );
    if (found != null) {
      if (mounted) setState(() { _rdv = found; _isLoading = false; });
      return;
    }

    // 2. Sinon chercher via le repo
    try {
      final repo = ref.read(rendezVousRepositoryProvider);
      final rdv = await repo.getRendezVousDetail(widget.id);
      if (mounted) setState(() { _rdv = rdv; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si l'état a été modifié (ex: annulation), écouter le provider pour mettre à jour
    final state = ref.watch(mesRendezVousProvider);
    final currentRdv = state.allRendezVous.cast<RendezVousModel?>().firstWhere(
      (r) => r?.id == widget.id,
      orElse: () => _rdv,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        body: const Center(child: CircularProgressIndicator(color: AppColors.figmaBrown)),
      );
    }

    if (currentRdv == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
          title: const Text('Rendez-vous', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Rendez-vous introuvable',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
            ),
          ),
        ),
      );
    }

    void handleBack() => context.pop();

    if (currentRdv.isAVenir) {
      return RendezVousDetailAVenirView(
        rdv: currentRdv,
        onBackPressed: handleBack,
      );
    } else if (currentRdv.isPasse) {
      return RendezVousDetailPasseView(
        rdv: currentRdv,
        onBackPressed: handleBack,
      );
    } else {
      return RendezVousDetailAnnuleView(
        rdv: currentRdv,
        onBackPressed: handleBack,
      );
    }
  }
}
