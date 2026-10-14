import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/reclamation_model.dart';
import '../../data/reclamation_repository.dart';
import '../providers/reclamation_provider.dart';
import 'reclamation_detail_en_attente_view.dart';
import 'reclamation_detail_en_cours_view.dart';
import 'reclamation_detail_rejete_view.dart';
import 'reclamation_detail_resolue_view.dart';

class ReclamationDetailScreen extends ConsumerStatefulWidget {
  final int id;
  final ReclamationModel? initialReclamation;

  const ReclamationDetailScreen({
    super.key,
    required this.id,
    this.initialReclamation,
  });

  @override
  ConsumerState<ReclamationDetailScreen> createState() => _ReclamationDetailScreenState();
}

class _ReclamationDetailScreenState extends ConsumerState<ReclamationDetailScreen> {
  ReclamationModel? _reclamation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reclamation = widget.initialReclamation;
    if (_reclamation == null) {
      _chargerDetail();
    }
  }

  Future<void> _chargerDetail() async {
    setState(() => _isLoading = true);
    // 1. Chercher dans le state local
    final state = ref.read(mesReclamationsProvider);
    final found = state.allReclamations.cast<ReclamationModel?>().firstWhere(
      (r) => r?.id == widget.id,
      orElse: () => null,
    );
    if (found != null) {
      if (mounted) setState(() { _reclamation = found; _isLoading = false; });
      return;
    }

    // 2. Sinon chercher via le repo
    try {
      final repo = ref.read(reclamationRepositoryProvider);
      final r = await repo.getReclamationDetail(widget.id);
      if (mounted) setState(() { _reclamation = r; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écouter le provider pour réagir aux mises à jour (ex: relance)
    final state = ref.watch(mesReclamationsProvider);
    final current = state.allReclamations.cast<ReclamationModel?>().firstWhere(
      (r) => r?.id == widget.id,
      orElse: () => _reclamation,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        body: const Center(child: CircularProgressIndicator(color: AppColors.figmaBrown)),
      );
    }

    if (current == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
          title: const Text('Réclamation', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Réclamation introuvable',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
            ),
          ),
        ),
      );
    }

    void handleBack() => context.pop();

    if (current.isEnAttente) {
      return ReclamationDetailEnAttenteView(
        reclamation: current,
        onBackPressed: handleBack,
      );
    } else if (current.isEnCours) {
      return ReclamationDetailEnCoursView(
        reclamation: current,
        onBackPressed: handleBack,
      );
    } else if (current.isResolue) {
      return ReclamationDetailResolueView(
        reclamation: current,
        onBackPressed: handleBack,
      );
    } else {
      return ReclamationDetailRejeteView(
        reclamation: current,
        onBackPressed: handleBack,
      );
    }
  }
}
