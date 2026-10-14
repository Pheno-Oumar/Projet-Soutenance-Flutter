import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reclamation_model.dart';
import '../../data/reclamation_mock_data.dart';
import '../../data/reclamation_repository.dart';
import 'package:mobile_hair_style/features/rendezvous/data/rendezvous_mock_data.dart' show SalonItem;

class MesReclamationsState {
  final bool isLoading;
  final List<ReclamationModel> allReclamations;
  final String selectedStatutTab; // 'TOUT', 'EN_ATTENTE', 'EN_COURS', 'RESOLUE', 'REJETEE'
  final String? selectedSalonSlug; // null = tous les salons
  final String? error;

  const MesReclamationsState({
    this.isLoading = false,
    this.allReclamations = const [],
    this.selectedStatutTab = 'TOUT',
    this.selectedSalonSlug,
    this.error,
  });

  /// Liste des salons uniques ayant au moins une réclamation
  List<SalonItem> get salonsDisponibles {
    final Map<String, SalonItem> map = {};
    for (final r in allReclamations) {
      if (!map.containsKey(r.salonSlug)) {
        map[r.salonSlug] = SalonItem(
          slug: r.salonSlug,
          nom: r.salonNom,
          adresse: r.salonAdresse,
          logo: r.salonLogo,
        );
      }
    }
    return map.values.toList();
  }

  /// Salon actuellement sélectionné (ou null pour "Tous les salons")
  SalonItem? get currentSalon {
    if (selectedSalonSlug == null) return null;
    return salonsDisponibles.firstWhere(
      (s) => s.slug == selectedSalonSlug,
      orElse: () => SalonItem(
        slug: selectedSalonSlug!,
        nom: 'Salon sélectionné',
        adresse: 'Dakar',
        logo: 'assets/images/rdv_tous_0.png',
      ),
    );
  }

  /// Liste filtrée selon le salon ET l'onglet de statut
  List<ReclamationModel> get reclamationsFiltrees {
    return allReclamations.where((r) {
      // 1. Filtre par salon
      if (selectedSalonSlug != null && r.salonSlug != selectedSalonSlug) {
        return false;
      }

      // 2. Filtre par statut
      switch (selectedStatutTab) {
        case 'EN_ATTENTE':
          return r.isEnAttente;
        case 'EN_COURS':
          return r.isEnCours;
        case 'RESOLUE':
          return r.isResolue;
        case 'REJETEE':
        case 'REJETE':
          return r.isRejetee;
        case 'TOUT':
        default:
          return true;
      }
    }).toList();
  }

  MesReclamationsState copyWith({
    bool? isLoading,
    List<ReclamationModel>? allReclamations,
    String? selectedStatutTab,
    String? selectedSalonSlug,
    bool clearSalonFilter = false,
    String? error,
  }) {
    return MesReclamationsState(
      isLoading: isLoading ?? this.isLoading,
      allReclamations: allReclamations ?? this.allReclamations,
      selectedStatutTab: selectedStatutTab ?? this.selectedStatutTab,
      selectedSalonSlug: clearSalonFilter ? null : (selectedSalonSlug ?? this.selectedSalonSlug),
      error: error,
    );
  }
}

class MesReclamationsNotifier extends StateNotifier<MesReclamationsState> {
  final ReclamationRepository _repository;

  MesReclamationsNotifier(this._repository)
      : super(MesReclamationsState(
          isLoading: false,
          allReclamations: ReclamationMockData.mockReclamations,
        )) {
    chargerReclamations();
  }

  Future<void> chargerReclamations() async {
    try {
      final list = await _repository.listerMesReclamations();
      if (list.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          allReclamations: list,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          allReclamations: ReclamationMockData.mockReclamations,
        );
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        allReclamations: ReclamationMockData.mockReclamations,
      );
    }
  }

  void changerStatutTab(String tab) {
    state = state.copyWith(selectedStatutTab: tab);
  }

  void selectionnerSalon(String? salonSlug) {
    if (salonSlug == null) {
      state = state.copyWith(clearSalonFilter: true);
    } else {
      state = state.copyWith(selectedSalonSlug: salonSlug);
    }
  }

  Future<void> ajouterReclamation({
    required String salonSlug,
    required String salonNom,
    required String salonAdresse,
    required String salonLogo,
    required String type,
    required String objet,
    required String description,
  }) async {
    final nouvelle = await _repository.creerReclamation(
      salonSlug: salonSlug,
      salonNom: salonNom,
      salonAdresse: salonAdresse,
      salonLogo: salonLogo,
      type: type,
      objet: objet,
      description: description,
    );

    state = state.copyWith(
      allReclamations: [nouvelle, ...state.allReclamations],
    );
  }

  Future<void> relancerReclamation(int id) async {
    await _repository.relancerReclamation(id);
    final updated = state.allReclamations.map((r) {
      if (r.id == id) {
        return r.copyWith(
          statut: 'EN_ATTENTE',
          reponseTraitement: null,
          reponseAuteur: null,
        );
      }
      return r;
    }).toList();
    state = state.copyWith(allReclamations: updated);
  }
}

final mesReclamationsProvider =
    StateNotifierProvider.autoDispose<MesReclamationsNotifier, MesReclamationsState>((ref) {
  final repo = ref.watch(reclamationRepositoryProvider);
  return MesReclamationsNotifier(repo);
});
