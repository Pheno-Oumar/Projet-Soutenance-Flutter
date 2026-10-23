import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/core/theme/theme_provider.dart';
import 'package:mobile_hair_style/features/notification/data/models/notification_model.dart';
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
    const List<NotificationModel> testNotifications = [
      NotificationModel(
        id: 1,
        titre: 'Rappel de rendez-vous demain',
        contenu: 'Votre rdv est prévu demain à 14:30.',
        type: 'RENDEZ_VOUS',
        referenceMetier: 'RDV-2025-0145',
        lu: false,
        dateCreation: 'Il y a 25 minutes',
      ),
      NotificationModel(
        id: 2,
        titre: 'Acompte confirmé',
        contenu: 'Votre acompte a été validé.',
        type: 'PAIEMENT',
        referenceMetier: 'PAY-2025-0891',
        lu: true,
        dateCreation: 'Hier à 16:42',
      ),
      NotificationModel(
        id: 3,
        titre: 'Réponse du Manager',
        contenu: 'Le salon vous a répondu.',
        type: 'RECLAMATION',
        referenceMetier: 'REC-2025-0012',
        lu: true,
        dateCreation: '17 Septembre',
      ),
      NotificationModel(
        id: 4,
        titre: 'Nouveau protocole capillaire disponible',
        contenu: 'Découvrez le soin.',
        type: 'SERVICE',
        referenceMetier: 'SRV-2025-0004',
        lu: true,
        dateCreation: '12 Septembre',
      ),
    ];

    test('NotificationListState correctly calculates unread and total counts', () {
      const state = NotificationListState(
        notifications: testNotifications,
      );

      expect(state.totalCount, 4);
      expect(state.unreadCount, 1);
      expect(state.notificationsFiltrees.length, 4);

      final nonLuesState = state.copyWith(selectedTab: 'NON_LUES');
      expect(nonLuesState.notificationsFiltrees.length, 1);
      expect(nonLuesState.notificationsFiltrees.first.lu, isFalse);
    });

    test('Marking notification as read decrements unread count', () {
      var state = const NotificationListState(
        notifications: testNotifications,
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
      var state = const NotificationListState(
        notifications: testNotifications,
      );

      final updated = state.notifications.map((n) => n.copyWith(lu: true)).toList();
      state = state.copyWith(notifications: updated);

      expect(state.unreadCount, 0);
      final nonLues = state.copyWith(selectedTab: 'NON_LUES');
      expect(nonLues.notificationsFiltrees.isEmpty, isTrue);
    });
  });
}
