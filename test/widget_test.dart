import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_hair_style/core/network/api_response.dart';
import 'package:mobile_hair_style/features/notification/data/models/notification_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/salon_model.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('MonSalon Unit & Model Tests', () {
    test('ApiResponse deserialization test', () {
      final json = {
        'success': true,
        'message': 'Succès',
        'data': {
          'id': 1,
          'nom': 'Salon Kady Prestige',
          'slug': 'salon-kady-prestige',
          'statut': true,
        },
      };

      final response = ApiResponse<SalonModel>.fromJson(
        json,
        (data) => SalonModel.fromJson(data as Map<String, dynamic>),
      );

      expect(response.success, isTrue);
      expect(response.data?.nom, 'Salon Kady Prestige');
      expect(response.data?.slug, 'salon-kady-prestige');
    });

    test('NotificationModel and Count deserialization test', () {
      final jsonNotif = {
        'id': 42,
        'titre': 'Rendez-vous confirmé',
        'contenu': 'Votre prestation de tresse est validée',
        'lu': false,
      };

      final notif = NotificationModel.fromJson(jsonNotif);
      expect(notif.id, 42);
      expect(notif.titre, 'Rendez-vous confirmé');
      expect(notif.lu, isFalse);

      final jsonCount = {'total': 5, 'nonLues': 2};
      final count = NotificationCountModel.fromJson(jsonCount);
      expect(count.total, 5);
      expect(count.nonLues, 2);
    });
  });
}
