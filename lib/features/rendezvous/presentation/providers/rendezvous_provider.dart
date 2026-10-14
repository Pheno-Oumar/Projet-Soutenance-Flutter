import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/rendezvous_model.dart';
import '../../data/rendezvous_mock_data.dart';
import '../../data/rendezvous_repository.dart';

class MesRendezVousState {
  final bool isLoading;
  final List<RendezVousModel> allRendezVous;
  final String selectedStatutTab; // 'TOUT', 'A_VENIR', 'PASSE', 'ANNULE'
  final String? selectedSalonSlug; // null = tous les salons
  final String? error;

  const MesRendezVousState({
    this.isLoading = false,
    this.allRendezVous = const [],
    this.selectedStatutTab = 'TOUT',
    this.selectedSalonSlug,
    this.error,
  });

  /// Liste des salons uniques ayant au moins un rendez-vous
  List<SalonItem> get salonsDisponibles {
    final Map<String, SalonItem> map = {};
    for (final r in allRendezVous) {
      final slug = r.salonSlug ?? 'salon-${r.salonNom?.toLowerCase().replaceAll(' ', '-') ?? 'inconnu'}';
      if (!map.containsKey(slug)) {
        map[slug] = SalonItem(
          slug: slug,
          nom: r.salonNom ?? 'Salon de beauté',
          adresse: r.salonAdresse ?? 'Dakar, Almadies',
          logo: r.salonLogo ?? 'assets/images/rdv_tous_0.png',
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
  List<RendezVousModel> get rendezVousFiltres {
    return allRendezVous.where((r) {
      // 1. Filtre par salon
      if (selectedSalonSlug != null) {
        final slug = r.salonSlug ?? 'salon-${r.salonNom?.toLowerCase().replaceAll(' ', '-') ?? ''}';
        if (slug != selectedSalonSlug) return false;
      }

      // 2. Filtre par statut
      switch (selectedStatutTab) {
        case 'A_VENIR':
          return r.isAVenir;
        case 'PASSE':
          return r.isPasse;
        case 'ANNULE':
          return r.isAnnule;
        case 'TOUT':
        default:
          return true;
      }
    }).toList();
  }

  MesRendezVousState copyWith({
    bool? isLoading,
    List<RendezVousModel>? allRendezVous,
    String? selectedStatutTab,
    String? selectedSalonSlug,
    bool clearSalonFilter = false,
    String? error,
  }) {
    return MesRendezVousState(
      isLoading: isLoading ?? this.isLoading,
      allRendezVous: allRendezVous ?? this.allRendezVous,
      selectedStatutTab: selectedStatutTab ?? this.selectedStatutTab,
      selectedSalonSlug: clearSalonFilter ? null : (selectedSalonSlug ?? this.selectedSalonSlug),
      error: error,
    );
  }
}

class MesRendezVousNotifier extends StateNotifier<MesRendezVousState> {
  final RendezVousRepository _repository;

  MesRendezVousNotifier(this._repository)
      : super(MesRendezVousState(
          isLoading: false,
          allRendezVous: RendezVousMockData.mockRendezVous,
        )) {
    chargerRendezVous();
  }

  Future<void> chargerRendezVous() async {
    try {
      final page = await _repository.listerMesRendezVous();
      if (page.content.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          allRendezVous: page.content,
        );
      } else {
        // En l'absence de données backend, conserver les données de test mock
        state = state.copyWith(
          isLoading: false,
          allRendezVous: RendezVousMockData.mockRendezVous,
        );
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        allRendezVous: RendezVousMockData.mockRendezVous,
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

  Future<void> annuler(int id, {String raison = 'Annulé par le client'}) async {
    try {
      await _repository.annulerRendezVous(id, raison: raison);
      // Mettre à jour l'élément localement
      final updatedList = state.allRendezVous.map((r) {
        if (r.id == id) {
          return r.copyWith(
            statut: 'ANNULE',
            motif: raison,
          );
        }
        return r;
      }).toList();
      state = state.copyWith(allRendezVous: updatedList);
    } catch (_) {}
  }
}

final mesRendezVousProvider =
    StateNotifierProvider.autoDispose<MesRendezVousNotifier, MesRendezVousState>((ref) {
  final repo = ref.watch(rendezVousRepositoryProvider);
  return MesRendezVousNotifier(repo);
});
