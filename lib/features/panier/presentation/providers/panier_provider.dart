import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../commandes/data/models/commande_model.dart';
import '../../data/models/panier_model.dart';
import '../../data/panier_repository.dart';

class PanierState {
  final bool isLoading;
  final bool isValidating;
  final String? validatingSalonSlug;
  final List<PanierModel> paniers;
  final String? error;

  const PanierState({
    this.isLoading = false,
    this.isValidating = false,
    this.validatingSalonSlug,
    this.paniers = const [],
    this.error,
  });

  int get totalArticles =>
      paniers.fold<int>(0, (sum, p) => sum + p.nombreArticles);

  double get montantTotalGlobal =>
      paniers.fold<double>(0.0, (sum, p) => sum + p.montantTotal);

  PanierState copyWith({
    bool? isLoading,
    bool? isValidating,
    String? validatingSalonSlug,
    bool clearValidatingSlug = false,
    List<PanierModel>? paniers,
    String? error,
  }) {
    return PanierState(
      isLoading: isLoading ?? this.isLoading,
      isValidating: isValidating ?? this.isValidating,
      validatingSalonSlug: clearValidatingSlug
          ? null
          : (validatingSalonSlug ?? this.validatingSalonSlug),
      paniers: paniers ?? this.paniers,
      error: error,
    );
  }
}

class PanierNotifier extends StateNotifier<PanierState> {
  final PanierRepository _repository;
  final Ref _ref;

  PanierNotifier(this._repository, this._ref) : super(const PanierState()) {
    _init();
    _listenAuth();
  }

  void _listenAuth() {
    _ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (prev?.isAuthenticated == false && next.isAuthenticated) {
        synchroniserApresConnexion();
      } else {
        chargerPaniers();
      }
    });
  }

  Future<void> _init() async {
    await chargerPaniers();
  }

  Future<void> chargerPaniers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final isAuth = _ref.read(authStateProvider).isAuthenticated;
      final paniers = await _repository.getPaniers(isAuth: isAuth);
      state = state.copyWith(isLoading: false, paniers: paniers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> ajouterArticle({
    required String slugSalon,
    String? salonNom,
    required int produitId,
    required String produitNom,
    required double prixUnitaire,
    required int quantite,
    String? imageUrl,
  }) async {
    final isAuth = _ref.read(authStateProvider).isAuthenticated;
    if (isAuth) {
      try {
        await _repository.ajouterArticleRemote(
          slugSalon: slugSalon,
          produitId: produitId,
          quantite: quantite,
        );
        await chargerPaniers();
      } catch (_) {}
    } else {
      final updated = await _repository.ajouterArticleLocal(
        slugSalon: slugSalon,
        salonNom: salonNom,
        produitId: produitId,
        produitNom: produitNom,
        prixUnitaire: prixUnitaire,
        quantite: quantite,
        imageUrl: imageUrl,
      );
      state = state.copyWith(paniers: updated);
    }
  }

  Future<void> modifierQuantite({
    required String slugSalon,
    required int produitId,
    required int quantite,
  }) async {
    final isAuth = _ref.read(authStateProvider).isAuthenticated;
    if (isAuth) {
      try {
        await _repository.modifierQuantiteRemote(
          slugSalon: slugSalon,
          produitId: produitId,
          quantite: quantite,
        );
        await chargerPaniers();
      } catch (_) {}
    } else {
      final current = List<PanierModel>.from(state.paniers);
      final pIndex = current.indexWhere((p) => p.slugSalon == slugSalon);
      if (pIndex >= 0) {
        final panier = current[pIndex];
        final updatedLignes = panier.lignes.map((l) {
          if (l.produitId == produitId) {
            return l.copyWith(
              quantite: quantite,
              sousTotal: l.prixUnitaire * quantite,
            );
          }
          return l;
        }).where((l) => l.quantite > 0).toList();

        current[pIndex] = panier.copyWith(
          lignes: updatedLignes,
          montantTotal: updatedLignes.fold<double>(0.0, (s, l) => s + l.sousTotal),
          nombreArticles: updatedLignes.fold<int>(0, (s, l) => s + l.quantite),
        );
        await _repository.saveLocalPaniers(current);
        state = state.copyWith(paniers: current.where((p) => p.lignes.isNotEmpty).toList());
      }
    }
  }

  Future<void> supprimerArticle({
    required String slugSalon,
    required int produitId,
  }) async {
    final isAuth = _ref.read(authStateProvider).isAuthenticated;
    if (isAuth) {
      try {
        await _repository.supprimerArticleRemote(
          slugSalon: slugSalon,
          produitId: produitId,
        );
        await chargerPaniers();
      } catch (_) {}
    } else {
      final current = List<PanierModel>.from(state.paniers);
      final pIndex = current.indexWhere((p) => p.slugSalon == slugSalon);
      if (pIndex >= 0) {
        final panier = current[pIndex];
        final updatedLignes = panier.lignes.where((l) => l.produitId != produitId).toList();
        current[pIndex] = panier.copyWith(
          lignes: updatedLignes,
          montantTotal: updatedLignes.fold<double>(0.0, (s, l) => s + l.sousTotal),
          nombreArticles: updatedLignes.fold<int>(0, (s, l) => s + l.quantite),
        );
        final filtered = current.where((p) => p.lignes.isNotEmpty).toList();
        await _repository.saveLocalPaniers(filtered);
        state = state.copyWith(paniers: filtered);
      }
    }
  }

  Future<void> viderPanier(String slugSalon) async {
    final isAuth = _ref.read(authStateProvider).isAuthenticated;
    if (isAuth) {
      try {
        await _repository.viderPanierRemote(slugSalon);
        await chargerPaniers();
      } catch (_) {}
    } else {
      final updated = state.paniers.where((p) => p.slugSalon != slugSalon).toList();
      await _repository.saveLocalPaniers(updated);
      state = state.copyWith(paniers: updated);
    }
  }

  Future<void> viderTous() async {
    final isAuth = _ref.read(authStateProvider).isAuthenticated;
    if (isAuth) {
      try {
        await _repository.viderTousPaniersRemote();
        await chargerPaniers();
      } catch (_) {}
    } else {
      await _repository.saveLocalPaniers([]);
      state = state.copyWith(paniers: []);
    }
  }

  /// Valider la commande pour un salon spécifique
  Future<CommandeModel?> validerPanierSalon(String slugSalon) async {
    state = state.copyWith(isValidating: true, validatingSalonSlug: slugSalon, error: null);
    try {
      final cmd = await _repository.validerCommandeSalon(slugSalon);
      state = state.copyWith(isValidating: false, clearValidatingSlug: true);
      return cmd;
    } catch (e) {
      await chargerPaniers();
      String message = 'Échec de validation de la commande';
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data['message'] != null) {
          message = data['message'].toString();
        }
      } else {
        message = e.toString();
      }
      state = state.copyWith(isValidating: false, clearValidatingSlug: true, error: message);
      return null;
    }
  }

  /// Valider les commandes de tous les salons
  Future<List<CommandeModel>> validerTousLesPaniers() async {
    state = state.copyWith(isValidating: true, clearValidatingSlug: true, error: null);
    final List<CommandeModel> createdOrders = [];
    final List<PanierModel> paniersAValider = List<PanierModel>.from(state.paniers);
    try {
      for (final p in paniersAValider) {
        if (p.slugSalon != null && p.lignes.isNotEmpty) {
          final cmd = await _repository.validerCommandeSalon(p.slugSalon!);
          if (cmd != null) {
            createdOrders.add(cmd);
          }
        }
      }
      await _repository.viderTousLesPaniersLocaux();
      state = state.copyWith(isValidating: false);
      return createdOrders;
    } catch (e) {
      await _repository.viderTousLesPaniersLocaux();
      await chargerPaniers();
      String message = 'Une erreur est survenue lors de la validation des commandes';
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data['message'] != null) {
          message = data['message'].toString();
        }
      } else {
        message = e.toString();
      }
      state = state.copyWith(isValidating: false, error: message);
      return createdOrders;
    }
  }

  Future<void> synchroniserApresConnexion() async {
    await _repository.synchroniserApresConnexion();
    await chargerPaniers();
  }
}

final localPanierCountProvider = StateProvider<int>((ref) => 0);

final panierStateProvider =
    StateNotifierProvider<PanierNotifier, PanierState>((ref) {
  final repo = ref.watch(panierRepositoryProvider);
  return PanierNotifier(repo, ref);
});

final panierCountProvider = Provider<int>((ref) {
  return ref.watch(panierStateProvider).totalArticles;
});
