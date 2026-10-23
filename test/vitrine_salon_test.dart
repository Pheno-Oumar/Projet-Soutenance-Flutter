import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/features/salon/data/models/avis_salon_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/coiffeur_salon_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/horaire_salon_model.dart';
import 'package:mobile_hair_style/features/salon/data/models/realisation_salon_model.dart';

void main() {
  group('Vitrine Salon Lot 3 Tests (Coiffeurs, Realisations, Avis, Horaires)', () {
    test('CoiffeurSalonModel fromJson and displayName formatting', () {
      final json = {
        'id': 10,
        'affectationId': 100,
        'coiffeurNom': 'Traoré',
        'coiffeurPrenom': 'Dika',
        'nomAffichage': 'Dika Traoré',
        'biographie': 'Fondatrice & Maître Coiffeuse',
        'anneeExperience': 8,
        'photoProfilUrl': 'https://res.cloudinary.com/test/dika.jpg',
        'description': 'Spécialiste Tresses sculptées, Knotless & Nattes',
        'available': true,
      };

      final coiffeur = CoiffeurSalonModel.fromJson(json);

      expect(coiffeur.id, 10);
      expect(coiffeur.displayName, 'Dika Traoré');
      expect(coiffeur.anneeExperience, 8);
      expect(coiffeur.photoProfilUrl, 'https://res.cloudinary.com/test/dika.jpg');
      expect(coiffeur.available, true);
    });

    test('RealisationSalonModel fromJson and properties', () {
      final json = {
        'id': 50,
        'titre': 'Box Braids Dorées',
        'description': 'Tresses protectrices soignées avec finitions dorées',
        'urlVideo': 'https://res.cloudinary.com/test/video1.mp4',
        'dateRealisation': '2026-10-15',
        'datePublication': '2026-10-16T12:00:00Z',
        'statutPublication': true,
        'salonSlug': 'beauty-by-dika',
        'salonNom': 'Beauty By Dika',
        'coiffeurId': 10,
        'coiffeurNomComplet': 'Dika Traoré',
        'totalLikes': 1240,
        'totalCommentaires': 85,
        'totalVues': 15200,
      };

      final realisation = RealisationSalonModel.fromJson(json);

      expect(realisation.id, 50);
      expect(realisation.titre, 'Box Braids Dorées');
      expect(realisation.salonSlug, 'beauty-by-dika');
      expect(realisation.totalLikes, 1240);
      expect(realisation.totalCommentaires, 85);
      expect(realisation.totalVues, 15200);
      expect(realisation.coiffeurNomComplet, 'Dika Traoré');
    });

    test('AvisSalonModel fromJson and initials calculation', () {
      final json = {
        'id': 1,
        'salonSlug': 'beauty-by-dika',
        'salonNom': 'Beauty By Dika',
        'clientId': 400,
        'clientNomComplet': 'Aminata Coulibaly',
        'note': 5,
        'commentaire': 'Service absolument parfait, accueil au top !',
        'statut': true,
        'dateCreation': '2026-10-14T10:30:00Z',
      };

      final avis = AvisSalonModel.fromJson(json);

      expect(avis.id, 1);
      expect(avis.clientNomComplet, 'Aminata Coulibaly');
      expect(avis.initials, 'AC');
      expect(avis.note, 5);
      expect(avis.commentaire, 'Service absolument parfait, accueil au top !');
    });

    test('HoraireSalonModel fromJson and french day labels', () {
      final json = {
        'id': 1,
        'jourSemaine': 'LUNDI',
        'heureOuverture': '09:00:00',
        'heureFermeture': '20:00:00',
        'actif': true,
      };

      final horaire = HoraireSalonModel.fromJson(json);

      expect(horaire.jourFrancais, 'Lundi');
      expect(horaire.plageHoraire, '09:00 - 20:00');
      expect(horaire.actif, true);

      final fermerJson = {
        'id': 7,
        'jourSemaine': 'DIMANCHE',
        'actif': false,
      };
      final ferme = HoraireSalonModel.fromJson(fermerJson);
      expect(ferme.jourFrancais, 'Dimanche');
      expect(ferme.plageHoraire, 'Fermé');
    });
  });
}
