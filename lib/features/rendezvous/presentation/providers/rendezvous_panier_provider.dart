import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/rendezvous_panier_model.dart';
import '../../data/rendezvous_panier_repository.dart';

class RendezvousPanierState {
  final bool isLoading;
  final bool isValidating;
  final List<SalonRendezVousPanierModel> paniers;
  final String? error;

  const RendezvousPanierState({
    this.isLoading = false,
    this.isValidating = false,
    this.paniers = const [],
    this.error,
  });

  /// Nombre total de prestations sélectionnées tous salons confondus (badge Calendar AppBar)
  int get rdvPanierCount =>
      paniers.fold<int>(0, (sum, p) => sum + p.prestations.length);

  RendezvousPanierState copyWith({
    bool? isLoading,
    bool? isValidating,
    List<SalonRendezVousPanierModel>? paniers,
    String? error,
  }) {
    return RendezvousPanierState(
      isLoading: isLoading ?? this.isLoading,
      isValidating: isValidating ?? this.isValidating,
      paniers: paniers ?? this.paniers,
      error: error,
    );
  }
}

class RendezvousPanierNotifier extends StateNotifier<RendezvousPanierState> {
  final RendezvousPanierRepository _repository;

  RendezvousPanierNotifier(this._repository) : super(const RendezvousPanierState()) {
    chargerPanier();
  }

  Future<void> chargerPanier() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getLocalPaniers();
      state = state.copyWith(isLoading: false, paniers: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> ajouterPrestation({
    required String slugSalon,
    required String salonNom,
    String? salonLogo,
    required LignePrestationPanierModel prestation,
  }) async {
    final updated = await _repository.ajouterPrestationLocal(
      slugSalon: slugSalon,
      salonNom: salonNom,
      salonLogo: salonLogo,
      prestation: prestation,
    );
    state = state.copyWith(paniers: updated);
  }

  Future<void> retirerPrestation(String slugSalon, int varianteId) async {
    final updated = await _repository.retirerPrestationLocal(slugSalon, varianteId);
    state = state.copyWith(paniers: updated);
  }

  Future<void> definirDateHeure(String slugSalon, DateTime dateHeure) async {
    final updated = await _repository.definirDateHeureLocal(slugSalon, dateHeure);
    state = state.copyWith(paniers: updated);
  }

  Future<void> definirCoiffeur(String slugSalon, int? coiffeurId, String? coiffeurNom) async {
    final updated = await _repository.definirCoiffeurLocal(slugSalon, coiffeurId, coiffeurNom);
    state = state.copyWith(paniers: updated);
  }

  Future<void> definirNotes(String slugSalon, String notes) async {
    final updated = await _repository.definirNotesLocal(slugSalon, notes);
    state = state.copyWith(paniers: updated);
  }

  Future<void> viderSalon(String slugSalon) async {
    final updated = await _repository.viderSalonLocal(slugSalon);
    state = state.copyWith(paniers: updated);
  }

  /// Validation STRICTEMENT PAR SALON
  Future<bool> validerSalon(String slugSalon) async {
    final salon = state.paniers.firstWhere(
      (p) => p.slugSalon == slugSalon,
      orElse: () => throw Exception('Salon introuvable dans le panier'),
    );

    if (salon.prestations.isEmpty) {
      throw Exception('Aucune prestation sélectionnée pour ce salon');
    }

    // Si aucune date n'a été choisie, par défaut demain à 10:00
    final datePrevue = salon.dateHeurePrevue ??
        DateTime.now().add(const Duration(days: 1)).copyWith(hour: 10, minute: 0, second: 0);

    state = state.copyWith(isValidating: true, error: null);

    try {
      await _repository.validerRendezVousSalon(
        slugSalon: slugSalon,
        dateHeurePrevue: datePrevue,
        varianteIds: salon.prestations.map((p) => p.varianteId).toList(),
        coiffeurId: salon.coiffeurId,
        notes: salon.notes,
      );

      final updated = await _repository.getLocalPaniers();
      state = state.copyWith(isValidating: false, paniers: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isValidating: false, error: e.toString());
      rethrow;
    }
  }
}

final rendezvousPanierProvider =
    StateNotifierProvider<RendezvousPanierNotifier, RendezvousPanierState>((ref) {
  final repository = ref.watch(rendezvousPanierRepositoryProvider);
  return RendezvousPanierNotifier(repository);
});

final rdvPanierCountProvider = Provider<int>((ref) {
  return ref.watch(rendezvousPanierProvider).rdvPanierCount;
});
