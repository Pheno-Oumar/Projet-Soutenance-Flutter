import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_hair_style/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_hair_style/features/panier/data/models/panier_model.dart';
import 'package:mobile_hair_style/features/panier/data/panier_repository.dart';

final localPanierCountProvider = StateProvider<int>((ref) => 0);

final panierCountProvider = Provider<int>((ref) {
  final local = ref.watch(localPanierCountProvider);
  final panier = ref.watch(panierStateProvider).panier;
  return (panier?.nombreArticles ?? 0) + local;
});

class PanierState {
  final bool isLoading;
  final PanierModel? panier;
  final String? error;

  const PanierState({
    this.isLoading = false,
    this.panier,
    this.error,
  });

  PanierState copyWith({
    bool? isLoading,
    PanierModel? panier,
    String? error,
  }) {
    return PanierState(
      isLoading: isLoading ?? this.isLoading,
      panier: panier ?? this.panier,
      error: error,
    );
  }
}

class PanierNotifier extends StateNotifier<PanierState> {
  final PanierRepository _repository;
  final Ref _ref;

  PanierNotifier(this._repository, this._ref) : super(const PanierState()) {
    chargerPanier();
  }

  Future<void> chargerPanier({String? slugSalon}) async {
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      state = const PanierState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final panier = await _repository.getPanier(slugSalon: slugSalon);
      state = state.copyWith(isLoading: false, panier: panier);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> modifierQuantite(String slugSalon, int produitId, int quantite) async {
    try {
      final updated = await _repository.modifierQuantite(
        slugSalon: slugSalon,
        produitId: produitId,
        quantite: quantite,
      );
      state = state.copyWith(panier: updated);
    } catch (_) {}
  }

  Future<void> supprimerArticle(String slugSalon, int produitId) async {
    try {
      final updated = await _repository.supprimerArticle(
        slugSalon: slugSalon,
        produitId: produitId,
      );
      state = state.copyWith(panier: updated);
    } catch (_) {}
  }

  Future<void> vider(String slugSalon) async {
    try {
      await _repository.viderPanier(slugSalon);
      state = state.copyWith(panier: null);
    } catch (_) {}
  }
}

final panierStateProvider =
    StateNotifierProvider<PanierNotifier, PanierState>((ref) {
  final repo = ref.watch(panierRepositoryProvider);
  return PanierNotifier(repo, ref);
});
