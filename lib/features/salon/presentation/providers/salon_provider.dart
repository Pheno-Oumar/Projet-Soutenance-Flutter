import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_hair_style/features/salon/data/models/salon_model.dart';
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
