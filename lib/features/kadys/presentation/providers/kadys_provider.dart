import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_hair_style/features/kadys/data/models/kadys_model.dart';
import 'package:mobile_hair_style/features/kadys/data/kadys_repository.dart';

class KadysFeedState {
  final bool isLoading;
  final List<KadysModel> items;
  final String? error;

  const KadysFeedState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  KadysFeedState copyWith({
    bool? isLoading,
    List<KadysModel>? items,
    String? error,
  }) {
    return KadysFeedState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class KadysFeedNotifier extends StateNotifier<KadysFeedState> {
  final KadysRepository _repository;

  KadysFeedNotifier(this._repository) : super(const KadysFeedState()) {
    chargerFeed();
  }

  Future<void> chargerFeed() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final page = await _repository.getFeed();
      state = state.copyWith(isLoading: false, items: page.content);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleLike(int id) async {
    final itemIndex = state.items.indexWhere((it) => it.id == id);
    if (itemIndex == -1) return;

    final item = state.items[itemIndex];
    final newLiked = !item.isLikedByCurrentUser;
    final newCount = item.totalLikes + (newLiked ? 1 : -1);

    final updatedItems = List<KadysModel>.from(state.items);
    updatedItems[itemIndex] = item.copyWith(
      isLikedByCurrentUser: newLiked,
      totalLikes: newCount < 0 ? 0 : newCount,
    );
    state = state.copyWith(items: updatedItems);

    try {
      await _repository.toggleLike(id);
    } catch (_) {
      // Annuler en cas d'erreur
      updatedItems[itemIndex] = item;
      state = state.copyWith(items: updatedItems);
    }
  }
}

final kadysFeedProvider =
    StateNotifierProvider<KadysFeedNotifier, KadysFeedState>((ref) {
  final repo = ref.watch(kadysRepositoryProvider);
  return KadysFeedNotifier(repo);
});
