import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../rendezvous/data/rendezvous_mock_data.dart';
import '../../data/models/prestation_model.dart';
import '../../data/prestation_mock_data.dart';

class MesPrestationsState {
  final List<PrestationModel> allPrestations;
  final String selectedStatutTab; // 'TOUT', 'TERMINEE', 'ANNULEE'
  final String? selectedSalonSlug; // null = Tous les salons
  final bool isLoading;

  const MesPrestationsState({
    required this.allPrestations,
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
  MesPrestationsNotifier()
      : super(
          MesPrestationsState(
            allPrestations: List.from(PrestationMockData.mockPrestations),
          ),
        );

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

  void chargerPrestations() {
    state = state.copyWith(isLoading: true);
    // Synchrone pour réactivité immédiate
    state = state.copyWith(
      allPrestations: List.from(PrestationMockData.mockPrestations),
      isLoading: false,
    );
  }
}

final mesPrestationsProvider =
    StateNotifierProvider<MesPrestationsNotifier, MesPrestationsState>((ref) {
  return MesPrestationsNotifier();
});
