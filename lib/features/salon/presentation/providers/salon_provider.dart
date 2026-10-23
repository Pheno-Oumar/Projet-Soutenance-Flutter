import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_hair_style/features/salon/data/models/produit_salon_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/salon_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/service_salon_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/realisation_salon_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/coiffeur_salon_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/avis_salon_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/horaire_salon_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/creneau_disponible_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/story_salon_model.dart';
import 'package:mobile_hair_style/features/salon/data/salon_repository.dart';

class SalonsListState {
  final bool isLoading;
  final List<SalonModel> salons;
  final String? error;
  final String searchQuery;

  const SalonsListState({
    this.isLoading = false,
    this.salons = const [],
    this.error,
    this.searchQuery = '',
  });

  SalonsListState copyWith({
    bool? isLoading,
    List<SalonModel>? salons,
    String? error,
    String? searchQuery,
  }) {
    return SalonsListState(
      isLoading: isLoading ?? this.isLoading,
      salons: salons ?? this.salons,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SalonsListNotifier extends StateNotifier<SalonsListState> {
  final SalonRepository _repository;

  SalonsListNotifier(this._repository) : super(const SalonsListState()) {
    chargerSalons();
  }

  Future<void> chargerSalons({String? query}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      searchQuery: query ?? state.searchQuery,
    );

    try {
      final page = await _repository.listerSalons(query: query ?? state.searchQuery);
      state = state.copyWith(isLoading: false, salons: page.content);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void search(String query) {
    chargerSalons(query: query);
  }

  Future<void> chargerSalonsNearby({
    required double lat,
    required double lng,
    double rayonKm = 5.0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final salons = await _repository.listerSalonsNearby(
        lat: lat,
        lng: lng,
        rayonKm: rayonKm,
      );
      state = state.copyWith(isLoading: false, salons: salons);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final salonsListProvider =
    StateNotifierProvider<SalonsListNotifier, SalonsListState>((ref) {
  final repo = ref.watch(salonRepositoryProvider);
  return SalonsListNotifier(repo);
});

final salonDetailProvider =
    FutureProvider.family<SalonModel, String>((ref, slug) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getSalonBySlug(slug);
});

final salonServicesProvider =
    FutureProvider.family<List<ServiceSalonModel>, String>((ref, slug) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getServicesSalon(slug);
});

final serviceDetailProvider = FutureProvider.family<ServiceSalonModel,
    ({String slug, int serviceId})>((ref, arg) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getServiceDetail(arg.slug, arg.serviceId);
});

final salonCategoriesProvider =
    FutureProvider.family<List<CategorieProduitModel>, String>((ref, slug) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getCategoriesProduits(slug);
});

final salonCategorieDetailProvider = FutureProvider.family<CategorieProduitModel,
    ({String slug, int categorieId})>((ref, arg) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getCategorieProduitDetail(arg.slug, arg.categorieId);
});

final salonProduitsProvider = FutureProvider.family<List<ProduitSalonModel>,
    ({String slug, int? categorieId})>((ref, arg) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getProduitsSalon(arg.slug, categorieId: arg.categorieId);
});

final salonProduitDetailProvider = FutureProvider.family<ProduitSalonModel,
    ({String slug, int produitId})>((ref, arg) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getProduitSalonDetail(arg.slug, arg.produitId);
});

final salonRealisationsProvider =
    FutureProvider.family<List<RealisationSalonModel>, String>((ref, slug) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getRealisationsSalon(slug);
});

final salonAvisProvider =
    FutureProvider.family<List<AvisSalonModel>, String>((ref, slug) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getAvisSalon(slug);
});

final salonCoiffeursProvider =
    FutureProvider.family<List<CoiffeurSalonModel>, String>((ref, slug) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getCoiffeursSalon(slug);
});

final salonHorairesProvider =
    FutureProvider.family<List<HoraireSalonModel>, String>((ref, slug) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getHorairesSalon(slug);
});

final realisationsTransversalesProvider =
    FutureProvider<List<RealisationSalonModel>>((ref) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.listerRealisationsTransversales();
});

final servicesTransversauxProvider =
    FutureProvider.family<List<ServiceSalonModel>, String?>((ref, query) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.listerServicesTransversal(query: query);
});

final produitsTransversauxProvider =
    FutureProvider.family<List<ProduitSalonModel>, int?>((ref, categorieId) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.listerProduitsTransversal(categorieId: categorieId);
});

typedef DisponibiliteParam = ({
  String slug,
  DateTime date,
  List<int> varianteIds,
  int? coiffeurId,
  String? heureMinimale,
});

final salonDisponibilitesProvider = FutureProvider.family<
    List<CreneauDisponibleModel>,
    DisponibiliteParam>((ref, param) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getDisponibilitesSalon(
    slug: param.slug,
    date: param.date,
    varianteIds: param.varianteIds,
    coiffeurId: param.coiffeurId,
    heureMinimale: param.heureMinimale,
  );
});

final salonStoriesProvider =
    FutureProvider.family<List<StorySalonModel>, String>((ref, slug) async {
  if (slug.isEmpty) return [];
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getStoriesSalon(slug);
});

final kadysStoriesGroupsProvider =
    FutureProvider<List<SalonStoriesGroupModel>>((ref) async {
  final repo = ref.watch(salonRepositoryProvider);
  return await repo.getKadysStories();
});


