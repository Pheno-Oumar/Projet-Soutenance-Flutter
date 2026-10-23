import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/features/prestations/data/models/prestation_model.dart';
import 'package:mobile_hair_style/features/prestations/presentation/providers/prestation_provider.dart';

void main() {
  group('PrestationModel Tests', () {
    test('Correctly identifies status and multiple service variants', () {
      final terminee = PrestationModel(
        id: 1,
        codeReference: '#PRES-2025-0001',
        salonSlug: 'salon-beauty',
        salonNom: 'Salon Beauty',
        salonAdresse: 'Dakar',
        salonLogo: 'logo.png',
        salonCover: 'cover.jpg',
        dateHeureDebut: '15/04/2025 • 10:00',
        statut: 'TERMINEE',
        montantTotal: 25000.0,
        lignes: const [
          LignePrestationModel(
            id: 1,
            varianteServiceId: 10,
            nomService: 'Soin capillaire',
            nomVariante: 'Hydratant',
            prix: 15000.0,
          ),
          LignePrestationModel(
            id: 2,
            varianteServiceId: 11,
            nomService: 'Brushing',
            nomVariante: 'Lisse',
            prix: 10000.0,
          ),
        ],
      );

      expect(terminee.isTerminee, isTrue);
      expect(terminee.isAnnulee, isFalse);
      expect(terminee.statutLabel, 'Terminée');
      expect(terminee.hasMultipleVariants, isTrue);
      expect(terminee.variantsCount, 2);
      expect(terminee.primaryNomService, 'Soin capillaire');

      final annulee = PrestationModel(
        id: 2,
        salonSlug: 'hair-co',
        salonNom: 'Hair & Co',
        salonAdresse: 'Mermoz',
        salonLogo: 'logo.png',
        salonCover: 'cover.jpg',
        dateHeureDebut: '18/03/2025 • 11:30',
        statut: 'ANNULEE',
        montantTotal: 35000.0,
        lignes: const [
          LignePrestationModel(
            id: 3,
            varianteServiceId: 12,
            nomService: 'Coloration',
            nomVariante: 'Balayage',
            prix: 35000.0,
          ),
        ],
      );

      expect(annulee.isTerminee, isFalse);
      expect(annulee.isAnnulee, isTrue);
      expect(annulee.statutLabel, 'Annulée');
      expect(annulee.hasMultipleVariants, isFalse);
      expect(annulee.variantsCount, 1);
      expect(annulee.referenceCode, '#PRES-2025-0002');
    });

    test('LignePrestation serialization and deserialization', () {
      final json = {
        'id': 101,
        'varianteServiceId': 12,
        'nomService': 'Coupe',
        'nomVariante': 'Dégradé',
        'prixReel': 8000.0,
        'dureeMinutes': 30,
        'imageUrl': 'assets/images/service_img_0.jpg',
      };

      final model = LignePrestationModel.fromJson(json);
      expect(model.id, 101);
      expect(model.nomService, 'Coupe');
      expect(model.nomVariante, 'Dégradé');
      expect(model.prix, 8000.0);
      expect(model.dureeMinutes, 30);
    });
  });

  group('MesPrestationsState Filtering Tests', () {
    final List<PrestationModel> samplePrestations = [
      const PrestationModel(
        id: 1,
        salonSlug: 'salon-beauty',
        salonNom: 'Salon Beauty',
        salonAdresse: 'Dakar Plateau',
        salonLogo: 'assets/images/logo.png',
        salonCover: 'assets/images/cover.jpg',
        dateHeureDebut: '15/04/2025 • 10:00',
        statut: 'TERMINEE',
        montantTotal: 10000,
        lignes: [
          LignePrestationModel(
            id: 1,
            varianteServiceId: 101,
            nomService: 'Soin',
            nomVariante: 'Standard',
            prix: 10000,
          ),
        ],
      ),
      const PrestationModel(
        id: 2,
        salonSlug: 'salon-beauty',
        salonNom: 'Salon Beauty',
        salonAdresse: 'Dakar Plateau',
        salonLogo: 'assets/images/logo.png',
        salonCover: 'assets/images/cover.jpg',
        dateHeureDebut: '18/03/2025 • 11:30',
        statut: 'ANNULEE',
        montantTotal: 8000,
        lignes: [
          LignePrestationModel(
            id: 2,
            varianteServiceId: 102,
            nomService: 'Coupe',
            nomVariante: 'Simple',
            prix: 8000,
          ),
        ],
      ),
      const PrestationModel(
        id: 3,
        salonSlug: 'hair-co',
        salonNom: 'Hair & Co',
        salonAdresse: 'Mermoz',
        salonLogo: 'assets/images/logo.png',
        salonCover: 'assets/images/cover.jpg',
        dateHeureDebut: '20/02/2025 • 14:00',
        statut: 'TERMINEE',
        montantTotal: 20000,
        lignes: [
          LignePrestationModel(
            id: 3,
            varianteServiceId: 103,
            nomService: 'Tresses',
            nomVariante: 'Box braids',
            prix: 20000,
          ),
        ],
      ),
    ];

    test('Filters by status tab correctly', () {
      final state = MesPrestationsState(
        allPrestations: samplePrestations,
      );

      // TOUT
      expect(state.prestationsFiltrees.length, samplePrestations.length);

      // TERMINEE
      final termineeState = state.copyWith(selectedStatutTab: 'TERMINEE');
      expect(termineeState.prestationsFiltrees.every((p) => p.isTerminee), isTrue);
      expect(termineeState.prestationsFiltrees.length, 2);

      // ANNULEE
      final annuleeState = state.copyWith(selectedStatutTab: 'ANNULEE');
      expect(annuleeState.prestationsFiltrees.every((p) => p.isAnnulee), isTrue);
      expect(annuleeState.prestationsFiltrees.length, 1);
    });

    test('Filters by selected salon correctly', () {
      final state = MesPrestationsState(
        allPrestations: samplePrestations,
        selectedSalonSlug: 'salon-beauty',
      );

      expect(state.prestationsFiltrees.every((p) => p.salonSlug == 'salon-beauty'), isTrue);
      expect(state.currentSalon?.slug, 'salon-beauty');
    });

    test('Extracts unique available salons dynamically', () {
      final state = MesPrestationsState(
        allPrestations: samplePrestations,
      );

      final salons = state.salonsDisponibles;
      final slugs = salons.map((s) => s.slug).toSet();
      expect(slugs.length, salons.length); // no duplicates
      expect(slugs.contains('salon-beauty'), isTrue);
      expect(slugs.contains('hair-co'), isTrue);
    });
  });
}
