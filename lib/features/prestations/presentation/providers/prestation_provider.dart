import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../salon/data/models/salon_item_model.dart';
import '../../data/models/prestation_model.dart';
import '../../data/prestation_repository.dart';

class MesPrestationsState {
  final List<PrestationModel> allPrestations;
  final String selectedStatutTab; // 'TOUT', 'TERMINEE', 'ANNULEE'
  final String? selectedSalonSlug; // null = Tous les salons
  final bool isLoading;

  const MesPrestationsState({
    this.allPrestations = const [],
    this.selectedStatutTab = 'TOUT',
    this.selectedSalonSlug,
    this.isLoading = false,
  });

  List<PrestationModel> get prestationsFiltrees {
    return allPrestations.where((p) {
      // 1. Filtre par salon
      if (selectedSalonSlug != null && p.salonSlug != selectedSalonSlug) {
        return false;
      }
      // 2. Filtre par onglet de statut
      switch (selectedStatutTab) {
        case 'TERMINEE':
          return p.isTerminee;
        case 'ANNULEE':
          return p.isAnnulee;
        case 'TOUT':
        default:
          return true;
      }
    }).toList();
  }

  List<SalonItem> get salonsDisponibles {
    final Map<String, SalonItem> map = {};
    for (final p in allPrestations) {
      if (!map.containsKey(p.salonSlug)) {
        map[p.salonSlug] = SalonItem(
          nom: p.salonNom,
          slug: p.salonSlug,
          adresse: p.salonAdresse,
          logo: p.salonLogo,
        );
      }
    }
    return map.values.toList();
  }

  SalonItem? get currentSalon {
    if (selectedSalonSlug == null) return null;
    return salonsDisponibles.cast<SalonItem?>().firstWhere(
      (s) => s?.slug == selectedSalonSlug,
      orElse: () => null,
    );
  }

  MesPrestationsState copyWith({
    List<PrestationModel>? allPrestations,
    String? selectedStatutTab,
    String? selectedSalonSlug,
    bool clearSalon = false,
    bool? isLoading,
  }) {
    return MesPrestationsState(
      allPrestations: allPrestations ?? this.allPrestations,
      selectedStatutTab: selectedStatutTab ?? this.selectedStatutTab,
      selectedSalonSlug: clearSalon ? null : (selectedSalonSlug ?? this.selectedSalonSlug),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MesPrestationsNotifier extends StateNotifier<MesPrestationsState> {
  final PrestationRepository _repository;

  MesPrestationsNotifier(this._repository)
      : super(const MesPrestationsState(isLoading: true)) {
    chargerPrestations();
  }

  void changerStatutTab(String tab) {
    state = state.copyWith(selectedStatutTab: tab);
  }

  void selectionnerSalon(String? slug) {
    if (slug == null) {
      state = state.copyWith(clearSalon: true);
    } else {
      state = state.copyWith(selectedSalonSlug: slug);
    }
  }

  Future<void> chargerPrestations() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.listerMesPrestations(
        slugSalon: state.selectedSalonSlug,
        statut: state.selectedStatutTab,
      );
      state = state.copyWith(
        allPrestations: list,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        allPrestations: const [],
        isLoading: false,
      );
    }
  }
}

final mesPrestationsProvider =
    StateNotifierProvider.autoDispose<MesPrestationsNotifier, MesPrestationsState>((ref) {
  final repository = ref.watch(prestationRepositoryProvider);
  return MesPrestationsNotifier(repository);
});
