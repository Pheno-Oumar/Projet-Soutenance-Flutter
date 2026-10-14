import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/core/theme/theme_provider.dart';
import 'package:mobile_hair_style/features/notification/data/notification_mock_data.dart';
import 'package:mobile_hair_style/features/notification/presentation/providers/notification_provider.dart';

void main() {
  group('ThemeMode Tests', () {
    test('ThemeModeNotifier switches themes correctly', () {
      final notifier = ThemeModeNotifier();
      expect(notifier.state, ThemeMode.light);
      expect(notifier.currentThemeLabel, 'Clair');

      notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, ThemeMode.dark);
      expect(notifier.currentThemeLabel, 'Sombre');

      notifier.toggleTheme();
      expect(notifier.state, ThemeMode.light);

      notifier.setThemeMode(ThemeMode.system);
      expect(notifier.state, ThemeMode.system);
      expect(notifier.currentThemeLabel, 'Système');
    });
  });

  group('Notification & Badge Tests', () {
    test('NotificationListState correctly calculates unread and total counts', () {
      final state = NotificationListState(
        notifications: NotificationMockData.mockNotifications,
      );

      expect(state.totalCount, 4);
      expect(state.unreadCount, 1);
      expect(state.notificationsFiltrees.length, 4);

      final nonLuesState = state.copyWith(selectedTab: 'NON_LUES');
      expect(nonLuesState.notificationsFiltrees.length, 1);
      expect(nonLuesState.notificationsFiltrees.first.lu, isFalse);
    });

    test('Marking notification as read decrements unread count', () {
      var state = NotificationListState(
        notifications: NotificationMockData.mockNotifications,
      );

      expect(state.unreadCount, 1);

      // Simulate marking notification id 1 as read
      final updated = state.notifications.map((n) {
        if (n.id == 1) return n.copyWith(lu: true);
        return n;
      }).toList();

      state = state.copyWith(notifications: updated);
      expect(state.unreadCount, 0);
      expect(state.notifications.every((n) => n.lu), isTrue);
    });

    test('Marking all notifications as read sets all to true', () {
      var state = NotificationListState(
        notifications: NotificationMockData.mockNotifications,
      );

      final updated = state.notifications.map((n) => n.copyWith(lu: true)).toList();
      state = state.copyWith(notifications: updated);

      expect(state.unreadCount, 0);
      final nonLues = state.copyWith(selectedTab: 'NON_LUES');
      expect(nonLues.notificationsFiltrees.isEmpty, isTrue);
    });
  });
}
