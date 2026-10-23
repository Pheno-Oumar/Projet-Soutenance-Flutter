import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/features/salon/data/models/story_salon_model.dart';
import 'package:mobile_hair_style/features/kadys/data/models/kadys_commentaire_model.dart';

void main() {
  group('StorySalonModel & SalonStoriesGroupModel Tests', () {
    test('StorySalonModel deserializes json correctly', () {
      final json = {
        'id': 42,
        'mediaUrl': 'https://example.com/story.jpg',
        'typeMedia': 'IMAGE',
        'dateCreation': '2026-10-18T14:00:00.000',
        'dateExpiration': '2026-10-19T14:00:00.000',
        'salonSlug': 'aura-paris',
        'salonNom': 'Aura Paris',
        'salonLogoUrl': 'https://example.com/logo.jpg',
      };

      final story = StorySalonModel.fromJson(json);

      expect(story.id, 42);
      expect(story.mediaUrl, 'https://example.com/story.jpg');
      expect(story.typeMedia, 'IMAGE');
      expect(story.isVideo, false);
      expect(story.salonSlug, 'aura-paris');
      expect(story.salonNom, 'Aura Paris');
      expect(story.salonLogoUrl, 'https://example.com/logo.jpg');
      expect(story.dateCreation, isNotNull);
      expect(story.dateExpiration, isNotNull);

      final exported = story.toJson();
      expect(exported['id'], 42);
      expect(exported['mediaUrl'], 'https://example.com/story.jpg');
    });

    test('StorySalonModel detects video media type', () {
      const story = StorySalonModel(
        id: 1,
        mediaUrl: 'https://example.com/video.mp4',
        typeMedia: 'VIDEO',
      );
      expect(story.isVideo, true);
    });

    test('SalonStoriesGroupModel deserializes group and nested stories', () {
      final json = {
        'salonId': 5,
        'salonNom': 'Beauty By Dika',
        'salonSlug': 'beauty-by-dika',
        'salonLogoUrl': 'https://example.com/logo.png',
        'nombreStories': 2,
        'stories': [
          {
            'id': 101,
            'mediaUrl': 'https://example.com/s1.jpg',
            'typeMedia': 'IMAGE',
          },
          {
            'id': 102,
            'mediaUrl': 'https://example.com/s2.jpg',
            'typeMedia': 'IMAGE',
          },
        ],
      };

      final group = SalonStoriesGroupModel.fromJson(json);

      expect(group.salonId, 5);
      expect(group.salonNom, 'Beauty By Dika');
      expect(group.salonSlug, 'beauty-by-dika');
      expect(group.nombreStories, 2);
      expect(group.stories.length, 2);
      expect(group.stories[0].id, 101);
      expect(group.stories[1].id, 102);
    });
  });

  group('KadysCommentaireModel Tests', () {
    test('KadysCommentaireModel deserializes correctly and computes initials', () {
      final json = {
        'id': 12,
        'realisationId': 99,
        'auteurNomComplet': 'Fatoumata Traore',
        'auteurPhotoUrl': 'https://example.com/photo.jpg',
        'contenu': 'Magnifique coupe et tresses très nettes !',
        'dateCreation': '2026-10-18T10:30:00.000',
        'isMine': true,
      };

      final comment = KadysCommentaireModel.fromJson(json);

      expect(comment.id, 12);
      expect(comment.realisationId, 99);
      expect(comment.auteurNomComplet, 'Fatoumata Traore');
      expect(comment.auteurPhotoUrl, 'https://example.com/photo.jpg');
      expect(comment.contenu, 'Magnifique coupe et tresses très nettes !');
      expect(comment.isMine, true);
      expect(comment.initials, 'FT');
    });

    test('KadysCommentaireModel single name fallback initials', () {
      const comment = KadysCommentaireModel(
        id: 1,
        realisationId: 1,
        auteurNomComplet: 'Aminata',
        contenu: 'Superbe !',
      );
      expect(comment.initials, 'AM');
    });
  });
}
