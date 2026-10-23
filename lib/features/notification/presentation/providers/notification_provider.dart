import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/notification_repository.dart';

class NotificationListState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final String selectedTab; // 'TOUTES' ou 'NON_LUES'
  final String? error;

  const NotificationListState({
    this.isLoading = false,
    this.notifications = const [],
    this.selectedTab = 'TOUTES',
    this.error,
  });

  int get totalCount => notifications.length;

  int get unreadCount => notifications.where((n) => !n.lu).length;

  List<NotificationModel> get notificationsFiltrees {
    if (selectedTab == 'NON_LUES') {
      return notifications.where((n) => !n.lu).toList();
    }
    return notifications;
  }

  NotificationListState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    String? selectedTab,
    String? error,
  }) {
    return NotificationListState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      selectedTab: selectedTab ?? this.selectedTab,
      error: error,
    );
  }
}

class NotificationListNotifier extends StateNotifier<NotificationListState> {
  final NotificationRepository _repository;

  NotificationListNotifier(this._repository)
      : super(
          const NotificationListState(
            isLoading: true,
            notifications: [],
          ),
        ) {
    chargerNotifications();
  }

  void changerTab(String tab) {
    state = state.copyWith(selectedTab: tab);
  }

  Future<void> chargerNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final page = await _repository.listerMesNotifications();
      state = state.copyWith(isLoading: false, notifications: page.content);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        notifications: const [],
        error: e.toString(),
      );
    }
  }

  Future<void> marquerLu(int id) async {
    // 1. Mise à jour immédiate synchrone locale pour réactivité instantanée
    final updatedList = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(lu: true);
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updatedList);

    // 2. Synchronisation backend
    try {
      await _repository.marquerCommeLu(id);
    } catch (_) {}
  }

  Future<void> toutMarquerLu() async {
    // 1. Mise à jour immédiate synchrone locale
    final updatedList = state.notifications.map((n) => n.copyWith(lu: true)).toList();
    state = state.copyWith(notifications: updatedList);

    // 2. Synchronisation backend
    try {
      await _repository.toutMarquerCommeLu();
    } catch (_) {}
  }

  Future<void> supprimer(int id) async {
    final updatedList = state.notifications.where((n) => n.id != id).toList();
    state = state.copyWith(notifications: updatedList);
    try {
      await _repository.supprimerNotification(id);
    } catch (_) {}
  }
}

final notificationListProvider =
    StateNotifierProvider<NotificationListNotifier, NotificationListState>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationListNotifier(repo);
});

/// Provider dédié au compteur de notifications non lues (pour badges NavigationBar et Compte)
final unreadNotificationCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationListProvider);
  return state.unreadCount;
});
