import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/features/assistant/data/models/assistant_models.dart';

void main() {
  group('Assistant Models & Deserialization Tests', () {
    test('AssistantChatResponse deserialization with cards and suggestions', () {
      final json = {
        'texte': 'Bienvenue sur Mon Salon. Découvrez notre sélection :',
        'contexte': 'PLATEFORME_VISITEUR',
        'suggestions': [
          'Salons à proximité',
          'Tresses & Coiffures tendance',
          'Comment fonctionne la réservation ?',
        ],
        'cartes': [
          {
            'type': 'SALONS',
            'titre': 'Salons partenaires',
            'donnees': [
              {
                'id': 1,
                'nom': 'Élégance & Co',
                'slug': 'elegance-co-1',
                'adresse': 'Bamako ACI 2000',
              },
              {
                'id': 2,
                'nom': 'L\'écrin de Beauté',
                'slug': 'lecrin-de-beaute',
                'adresse': 'Badalabougou',
              }
            ],
          },
          {
            'type': 'PRODUITS',
            'titre': 'Cosmétiques recommandés',
            'donnees': [
              {
                'nom': 'Huile de Ricin Pure',
                'prixVente': 4500,
              }
            ],
          }
        ],
        'actionsUi': [
          {
            'type': 'ui_demander_connexion',
            'payload': {'raison': 'MES_RDV'},
          }
        ],
      };

      final response = AssistantChatResponse.fromJson(json);

      expect(response.texte, contains('Bienvenue sur Mon Salon'));
      expect(response.contexte, 'PLATEFORME_VISITEUR');
      expect(response.suggestions.length, 3);
      expect(response.suggestions.first, 'Salons à proximité');
      expect(response.cartes.length, 2);
      expect(response.cartes[0].type, 'SALONS');
      expect(response.cartes[0].donnees.length, 2);
      expect(response.cartes[0].donnees[0]['nom'], 'Élégance & Co');
      expect(response.cartes[1].type, 'PRODUITS');
      expect(response.actionsUi.length, 1);
      expect(response.actionsUi[0].type, 'ui_demander_connexion');
      expect(response.actionsUi[0].payload['raison'], 'MES_RDV');
    });

    test('MessageChat user vs assistant message properties', () {
      final userMsg = MessageChat(text: 'Bonjour', isUser: true);
      expect(userMsg.isUser, isTrue);
      expect(userMsg.text, 'Bonjour');
      expect(userMsg.cartes, isEmpty);

      final assistantMsg = MessageChat(
        text: 'En quoi puis-je vous aider ?',
        isUser: false,
        suggestions: ['Prendre RDV'],
      );
      expect(assistantMsg.isUser, isFalse);
      expect(assistantMsg.suggestions, contains('Prendre RDV'));
    });
  });
}
