import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/features/assistant/data/assistant_repository.dart';
import 'package:mobile_hair_style/features/assistant/data/models/assistant_models.dart';
import 'package:mobile_hair_style/features/assistant/presentation/assistant_screen.dart';

class FakeAssistantRepository implements AssistantRepository {
  @override
  Future<AssistantChatResponse> sendMessage({
    required String message,
    required String sessionId,
    String? slugSalon,
    String pageCourante = 'ACCUEIL',
    double? latitude,
    double? longitude,
  }) async {
    if (message.contains('Salons')) {
      return AssistantChatResponse(
        texte: 'Voici nos salons partenaires recommandés :',
        cartes: [
          AssistantCarte(
            type: 'SALON',
            titre: 'Salons recommandés',
            donnees: [
              {
                'nom': 'Salon Kady Afro & Chic',
                'adresse': 'Hamdallaye ACI 2000, Bamako',
                'score': 4.9,
                'slug': 'salon-kady-afro-chic',
              }
            ],
          ),
        ],
        suggestions: ['Prendre rendez-vous', 'Voir les tarifs'],
      );
    }
    return AssistantChatResponse(
      texte: 'Réponse simulée pour : $message',
      suggestions: ['Autre question', 'Retour accueil'],
    );
  }
}

void main() {
  testWidgets('AssistantScreen renders initial greeting and handles sending messages', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assistantRepositoryProvider.overrideWithValue(FakeAssistantRepository() as dynamic),
        ],
        child: const MaterialApp(
          home: AssistantScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial concierge welcome text
    expect(find.textContaining('concierge virtuel Mon Salon'), findsOneWidget);

    // Verify initial suggestions chips are rendered
    expect(find.text('Salons à proximité'), findsWidgets);
    expect(find.text('Tresses & Coiffures tendance'), findsWidgets);

    // Tap on the first suggestion "Salons à proximité"
    await tester.tap(find.text('Salons à proximité').first);
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify user message appeared
    expect(find.text('Salons à proximité'), findsWidgets);

    // Verify response from FakeAssistantRepository
    expect(find.textContaining('Voici nos salons partenaires recommandés'), findsOneWidget);
    expect(find.text('Salon Kady Afro & Chic'), findsOneWidget);

    // Verify new suggestions appeared
    expect(find.text('Prendre rendez-vous'), findsWidgets);
  });
}
