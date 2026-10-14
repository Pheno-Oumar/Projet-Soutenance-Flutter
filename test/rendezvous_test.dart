import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/features/rendezvous/data/models/rendezvous_model.dart';
import 'package:mobile_hair_style/features/rendezvous/data/rendezvous_mock_data.dart';
import 'package:mobile_hair_style/features/rendezvous/presentation/providers/rendezvous_provider.dart';

void main() {
  group('RendezVousModel Tests', () {
    test('Correctly identifies appointment status', () {
      const rdvAVenir = RendezVousModel(
        id: 1,
        statut: 'CONFIRME',
        dureeMinutes: 90,
      );
      expect(rdvAVenir.isAVenir, isTrue);
      expect(rdvAVenir.isPasse, isFalse);
      expect(rdvAVenir.isAnnule, isFalse);
      expect(rdvAVenir.statutLabel, 'À venir');
      expect(rdvAVenir.formattedDuree, '1 h 30 min');
      expect(rdvAVenir.referenceCode, '#RDV-2025-0001');

      const rdvPasse = RendezVousModel(
        id: 2,
        statut: 'PASSE',
        dureeMinutes: 60,
      );
      expect(rdvPasse.isPasse, isTrue);
      expect(rdvPasse.isAVenir, isFalse);
      expect(rdvPasse.statutLabel, 'Passé');
      expect(rdvPasse.formattedDuree, '1 h');

      const rdvAnnule = RendezVousModel(
        id: 3,
        statut: 'ANNULE',
        motif: 'Imprévu client',
      );
      expect(rdvAnnule.isAnnule, isTrue);
      expect(rdvAnnule.statutLabel, 'Annulé');
      expect(rdvAnnule.motif, 'Imprévu client');
    });

    test('LigneRendezVous serialization and deserialization', () {
      final json = {
        'id': 10,
        'nomService': 'Tresses',
        'nomVariante': 'Knotless',
        'prix': 30000.0,
        'dureeMinutes': 120,
      };
      final ligne = LigneRendezVousModel.fromJson(json);
      expect(ligne.id, 10);
      expect(ligne.nomService, 'Tresses');
      expect(ligne.nomVariante, 'Knotless');
      expect(ligne.prix, 30000.0);
      expect(ligne.dureeMinutes, 120);
    });
  });

  group('MesRendezVousState Filtering Tests', () {
    test('Filters by status tab correctly', () {
      final state = MesRendezVousState(
        allRendezVous: RendezVousMockData.mockRendezVous,
        selectedStatutTab: 'A_VENIR',
      );

      final aVenirList = state.rendezVousFiltres;
      expect(aVenirList.every((r) => r.isAVenir), isTrue);

      final statePasse = state.copyWith(selectedStatutTab: 'PASSE');
      expect(statePasse.rendezVousFiltres.every((r) => r.isPasse), isTrue);

      final stateAnnule = state.copyWith(selectedStatutTab: 'ANNULE');
      expect(stateAnnule.rendezVousFiltres.every((r) => r.isAnnule), isTrue);
    });

    test('Filters by selected salon correctly', () {
      final state = MesRendezVousState(
        allRendezVous: RendezVousMockData.mockRendezVous,
        selectedSalonSlug: 'salon-beauty',
      );

      final salonList = state.rendezVousFiltres;
      expect(salonList.every((r) => r.salonSlug == 'salon-beauty'), isTrue);
      expect(salonList.length, 3); // 1 à venir, 1 passé, 1 annulé

      // With salon filter AND tab filter
      final combinedState = state.copyWith(selectedStatutTab: 'A_VENIR');
      expect(combinedState.rendezVousFiltres.length, 1);
      expect(combinedState.rendezVousFiltres.first.isAVenir, isTrue);
    });

    test('Extracts unique available salons dynamically', () {
      final state = MesRendezVousState(
        allRendezVous: RendezVousMockData.mockRendezVous,
      );

      final salons = state.salonsDisponibles;
      expect(salons.length, greaterThanOrEqualTo(3));
      final slugs = salons.map((s) => s.slug).toList();
      expect(slugs.contains('salon-beauty'), isTrue);
      expect(slugs.contains('beauty-by-dika'), isTrue);
      expect(slugs.contains('mathy-hair'), isTrue);
    });
  });
}
