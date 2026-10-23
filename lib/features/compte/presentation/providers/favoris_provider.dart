import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/favoris_repository.dart';

class FavorisState {
  final Set<String> salonSlugs;
  final Set<int> coiffureIds;
  final Set<int> produitIds;
  final bool isLoading;

  const FavorisState({
    this.salonSlugs = const {},
    this.coiffureIds = const {},
    this.produitIds = const {},
    this.isLoading = false,
  });

  FavorisState copyWith({
    Set<String>? salonSlugs,
    Set<int>? coiffureIds,
    Set<int>? produitIds,
    bool? isLoading,
  }) {
    return FavorisState(
      salonSlugs: salonSlugs ?? this.salonSlugs,
      coiffureIds: coiffureIds ?? this.coiffureIds,
      produitIds: produitIds ?? this.produitIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool isSalonFav(String slug) => salonSlugs.contains(slug);
  bool isCoiffureFav(int id) => coiffureIds.contains(id);
  bool isProduitFav(int id) => produitIds.contains(id);
}

class FavorisNotifier extends StateNotifier<FavorisState> {
  final FavorisRepository _repository;
  final Ref _ref;

  FavorisNotifier(this._repository, this._ref) : super(const FavorisState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final isAuth = _ref.read(authStateProvider).isAuthenticated;

    if (isAuth) {
      await _loadRemote();
    } else {
      await _loadLocal();
    }
  }

  Future<void> _loadLocal() async {
    final salons = await _repository.getLocalSalons();
    final coiffures = await _repository.getLocalCoiffures();
    final produits = await _repository.getLocalProduits();

    state = state.copyWith(
      salonSlugs: salons,
      coiffureIds: coiffures,
      produitIds: produits,
      isLoading: false,
    );
  }

  Future<void> _loadRemote() async {
    try {
      final remoteSalons = await _repository.getRemoteSalons();
      final remoteCoiffures = await _repository.getRemoteCoiffures();
      final remoteProduits = await _repository.getRemoteProduits();

      final salonSlugs = remoteSalons
          .map((e) => (e['salon'] != null ? e['salon']['slug'] : e['slug']) as String?)
          .whereType<String>()
          .toSet();

      final coiffureIds = remoteCoiffures
          .map((e) => (e['variante'] != null ? e['variante']['id'] : e['id']) as num?)
          .whereType<num>()
          .map((n) => n.toInt())
          .toSet();

      final produitIds = remoteProduits
          .map((e) => (e['produit'] != null ? e['produit']['id'] : e['id']) as num?)
          .whereType<num>()
          .map((n) => n.toInt())
          .toSet();

      state = state.copyWith(
        salonSlugs: salonSlugs,
        coiffureIds: coiffureIds,
        produitIds: produitIds,
        isLoading: false,
      );
    } catch (_) {
      // En cas de problème réseau, basculer sur le local
      await _loadLocal();
    }
  }

  /// Appelé automatiquement après connexion / inscription
  Future<void> synchroniserApresConnexion() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.synchroniserFavoris();
    } catch (_) {}
    await _loadRemote();
  }

  // ==========================================
  // TOGGLE ACTIONS
  // ==========================================

  Future<void> toggleSalon(String slug) async {
    final isAuth = _ref.read(authStateProvider).isAuthenticated;
    final current = Set<String>.from(state.salonSlugs);
    final isCurrentlyFav = current.contains(slug);

    if (isCurrentlyFav) {
      current.remove(slug);
    } else {
      current.add(slug);
    }
    state = state.copyWith(salonSlugs: current);

    if (isAuth) {
      try {
        if (isCurrentlyFav) {
          await _repository.removeRemoteSalon(slug);
        } else {
          await _repository.addRemoteSalon(slug);
        }
      } catch (_) {
        // En cas d'erreur réseau, rollback
        state = state.copyWith(salonSlugs: state.salonSlugs);
      }
    } else {
      await _repository.toggleLocalSalon(slug);
    }
  }

  Future<void> toggleCoiffure(int id) async {
    final isAuth = _ref.read(authStateProvider).isAuthenticated;
    final current = Set<int>.from(state.coiffureIds);
    final isCurrentlyFav = current.contains(id);

    if (isCurrentlyFav) {
      current.remove(id);
    } else {
      current.add(id);
    }
    state = state.copyWith(coiffureIds: current);

    if (isAuth) {
      try {
        if (isCurrentlyFav) {
          await _repository.removeRemoteCoiffure(id);
        } else {
          await _repository.addRemoteCoiffure(id);
        }
      } catch (_) {}
    } else {
      await _repository.toggleLocalCoiffure(id);
    }
  }

  Future<void> toggleProduit(int id) async {
    final isAuth = _ref.read(authStateProvider).isAuthenticated;
    final current = Set<int>.from(state.produitIds);
    final isCurrentlyFav = current.contains(id);

    if (isCurrentlyFav) {
      current.remove(id);
    } else {
      current.add(id);
    }
    state = state.copyWith(produitIds: current);

    if (isAuth) {
      try {
        if (isCurrentlyFav) {
          await _repository.removeRemoteProduit(id);
        } else {
          await _repository.addRemoteProduit(id);
        }
      } catch (_) {}
    } else {
      await _repository.toggleLocalProduit(id);
    }
  }
}

final favorisProvider = StateNotifierProvider<FavorisNotifier, FavorisState>((ref) {
  final repo = ref.watch(favorisRepositoryProvider);
  final notifier = FavorisNotifier(repo, ref);

  // Écouter les changements d'état d'authentification pour déclencher la synchronisation
  ref.listen(authStateProvider, (prev, next) {
    if ((prev == null || !prev.isAuthenticated) && next.isAuthenticated) {
      notifier.synchroniserApresConnexion();
    } else if (prev?.isAuthenticated == true && !next.isAuthenticated) {
      notifier._loadLocal();
    }
  });

  return notifier;
});

final favorisRemoteSalonsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final isAuth = ref.watch(authStateProvider).isAuthenticated;
  if (!isAuth) return [];
  ref.watch(favorisProvider).salonSlugs;
  return await ref.watch(favorisRepositoryProvider).getRemoteSalons();
});

final favorisRemoteCoiffuresProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final isAuth = ref.watch(authStateProvider).isAuthenticated;
  if (!isAuth) return [];
  ref.watch(favorisProvider).coiffureIds;
  return await ref.watch(favorisRepositoryProvider).getRemoteCoiffures();
});

final favorisRemoteProduitsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final isAuth = ref.watch(authStateProvider).isAuthenticated;
  if (!isAuth) return [];
  ref.watch(favorisProvider).produitIds;
  return await ref.watch(favorisRepositoryProvider).getRemoteProduits();
});
