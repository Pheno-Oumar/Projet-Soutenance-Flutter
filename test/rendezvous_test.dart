import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/features/rendezvous/data/models/rendezvous_model.dart';
import 'package:mobile_hair_style/features/rendezvous/data/models/rendezvous_panier_model.dart';
import 'package:mobile_hair_style/features/rendezvous/presentation/providers/rendezvous_panier_provider.dart';
import 'package:mobile_hair_style/features/rendezvous/presentation/providers/rendezvous_provider.dart';
import 'package:mobile_hair_style/features/salon/data/models/creneau_disponible_model.dart';

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
    final sampleRendezVous = [
      const RendezVousModel(
        id: 1,
        salonSlug: 'salon-beauty',
        salonNom: 'Salon Beauty',
        statut: 'CONFIRME',
        dureeMinutes: 60,
      ),
      const RendezVousModel(
        id: 2,
        salonSlug: 'salon-beauty',
        salonNom: 'Salon Beauty',
        statut: 'PASSE',
        dureeMinutes: 60,
      ),
      const RendezVousModel(
        id: 3,
        salonSlug: 'salon-beauty',
        salonNom: 'Salon Beauty',
        statut: 'ANNULE',
        dureeMinutes: 60,
      ),
      const RendezVousModel(
        id: 4,
        salonSlug: 'beauty-by-dika',
        salonNom: 'Beauty by Dika',
        statut: 'CONFIRME',
        dureeMinutes: 90,
      ),
      const RendezVousModel(
        id: 5,
        salonSlug: 'mathy-hair',
        salonNom: 'Mathy Hair',
        statut: 'PASSE',
        dureeMinutes: 45,
      ),
    ];

    test('Filters by status tab correctly', () {
      final state = MesRendezVousState(
        allRendezVous: sampleRendezVous,
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
        allRendezVous: sampleRendezVous,
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
        allRendezVous: sampleRendezVous,
      );

      final salons = state.salonsDisponibles;
      expect(salons.length, greaterThanOrEqualTo(3));
      final slugs = salons.map((s) => s.slug).toList();
      expect(slugs.contains('salon-beauty'), isTrue);
      expect(slugs.contains('beauty-by-dika'), isTrue);
      expect(slugs.contains('mathy-hair'), isTrue);
    });
  });

  group('SalonRendezVousPanierModel & Tunnel RDV Tests', () {
    test('LignePrestationPanierModel formatted duration and json mapping', () {
      const presta = LignePrestationPanierModel(
        varianteId: 101,
        serviceId: 10,
        serviceNom: 'Coiffure Protectrice',
        varianteNom: 'Box Braids Longues',
        prix: 25000,
        dureeMinutes: 150,
      );

      expect(presta.dureeFormatee, '2h 30m');
      expect(presta.prix, 25000.0);

      final json = presta.toJson();
      final fromJson = LignePrestationPanierModel.fromJson(json);
      expect(fromJson.varianteId, 101);
      expect(fromJson.serviceNom, 'Coiffure Protectrice');
      expect(fromJson.varianteNom, 'Box Braids Longues');
      expect(fromJson.dureeMinutes, 150);
    });

    test('SalonRendezVousPanierModel calculates totals and supports clearCoiffeur', () {
      final salon = SalonRendezVousPanierModel(
        slugSalon: 'beauty-by-dika',
        salonNom: 'Beauty By Dika',
        coiffeurId: 12,
        coiffeurNom: 'Awa Diop',
        prestations: const [
          LignePrestationPanierModel(
            varianteId: 1,
            serviceNom: 'Tresses',
            varianteNom: 'Moyennes',
            prix: 15000,
            dureeMinutes: 60,
          ),
          LignePrestationPanierModel(
            varianteId: 2,
            serviceNom: 'Soin',
            varianteNom: 'Profond',
            prix: 10000,
            dureeMinutes: 45,
          ),
        ],
      );

      expect(salon.montantTotal, 25000.0);
      expect(salon.dureeTotaleMinutes, 105);
      expect(salon.dureeTotaleFormatee, '1h 45m');

      // Test clearing coiffeur via copyWith(clearCoiffeur: true)
      final salonSansPref = salon.copyWith(clearCoiffeur: true);
      expect(salonSansPref.coiffeurId, isNull);
      expect(salonSansPref.coiffeurNom, isNull);
      expect(salonSansPref.prestations.length, 2);

      // Test setting new coiffeur
      final salonAutreCoiffeur = salon.copyWith(
        coiffeurId: 99,
        coiffeurNom: 'Fatou Sow',
      );
      expect(salonAutreCoiffeur.coiffeurId, 99);
      expect(salonAutreCoiffeur.coiffeurNom, 'Fatou Sow');
    });

    test('RendezvousPanierState computes total prestation count across salons', () {
      final state = RendezvousPanierState(
        paniers: [
          SalonRendezVousPanierModel(
            slugSalon: 'salon-1',
            salonNom: 'Salon 1',
            prestations: const [
              LignePrestationPanierModel(
                varianteId: 1,
                serviceNom: 'S1',
                varianteNom: 'V1',
                prix: 5000,
              ),
            ],
          ),
          SalonRendezVousPanierModel(
            slugSalon: 'salon-2',
            salonNom: 'Salon 2',
            prestations: const [
              LignePrestationPanierModel(
                varianteId: 2,
                serviceNom: 'S2',
                varianteNom: 'V2',
                prix: 6000,
              ),
              LignePrestationPanierModel(
                varianteId: 3,
                serviceNom: 'S3',
                varianteNom: 'V3',
                prix: 8000,
              ),
            ],
          ),
        ],
      );

      expect(state.rdvPanierCount, 3);
    });

    test('CreneauDisponibleModel fromJson, formatting, and assigned coiffeur', () {
      final json = {
        'heureDebut': '14:30:00',
        'heureFin': '16:00:00',
        'dureeTotale': 90,
        'montantTotal': 25000.0,
        'lignesProposees': [
          {
            'varianteId': 101,
            'varianteNom': 'Box Braids Longues',
            'coiffeurAffectationId': 15,
            'coiffeurNom': 'Diop',
            'coiffeurPrenom': 'Awa',
            'heureDebut': '14:30:00',
            'heureFin': '16:00:00',
            'dureeMinutes': 90,
            'prix': 25000.0,
          }
        ],
      };

      final model = CreneauDisponibleModel.fromJson(json);
      expect(model.heureDebutFormatee, '14:30');
      expect(model.heureFinFormatee, '16:00');
      expect(model.plageFormatee, '14:30 - 16:00');
      expect(model.heure, 14);
      expect(model.minute, 30);
      expect(model.dureeTotale, 90);
      expect(model.montantTotal, 25000.0);
      expect(model.coiffeurAffectationId, 15);
      expect(model.coiffeurNom, 'Awa Diop');
    });
  });
}

