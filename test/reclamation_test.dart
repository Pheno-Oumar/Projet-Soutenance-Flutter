import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/features/reclamations/data/models/reclamation_model.dart';
import 'package:mobile_hair_style/features/reclamations/presentation/providers/reclamation_provider.dart';

void main() {
  group('ReclamationModel Tests', () {
    test('Correctly identifies status and reference code', () {
      const rec = ReclamationModel(
        id: 1,
        codeReference: '#REC-2025-0123',
        salonNom: 'Salon Beauty',
        salonSlug: 'salon-beauty',
        type: 'SERVICE',
        objet: 'Retard sur prestation',
        description: 'Explication du problème',
        statut: 'RESOLUE',
        reponseTraitement: 'Pardon pour le retard',
        dateCreation: '12/04/2025',
      );

      expect(rec.referenceCode, '#REC-2025-0123');
      expect(rec.isResolue, isTrue);
      expect(rec.isEnAttente, isFalse);
      expect(rec.isEnCours, isFalse);
      expect(rec.isRejetee, isFalse);
      expect(rec.statutLabel, 'Résolue');
      expect(rec.typeLabel, 'Service');
    });

    test('Default reference code generation from ID', () {
      const rec = ReclamationModel(
        id: 42,
        salonNom: 'Salon Beauty',
        salonSlug: 'salon-beauty',
        objet: 'Objet',
        description: 'Description',
        dateCreation: '12/04/2025',
      );

      expect(rec.referenceCode, '#REC-2025-0042');
    });
  });

  group('MesReclamationsState Filtering Tests', () {
    const testReclamations = [
      ReclamationModel(
        id: 1,
        codeReference: '#REC-2025-0001',
        salonNom: 'Salon Beauty',
        salonSlug: 'salon-beauty',
        type: 'SERVICE',
        objet: 'Retard 1',
        description: 'Desc 1',
        statut: 'EN_ATTENTE',
        dateCreation: '12/04/2025',
      ),
      ReclamationModel(
        id: 2,
        codeReference: '#REC-2025-0002',
        salonNom: 'Salon Beauty',
        salonSlug: 'salon-beauty',
        type: 'PRODUIT',
        objet: 'Produit 2',
        description: 'Desc 2',
        statut: 'EN_COURS',
        dateCreation: '12/04/2025',
      ),
      ReclamationModel(
        id: 3,
        codeReference: '#REC-2025-0003',
        salonNom: 'Salon Beauty',
        salonSlug: 'salon-beauty',
        type: 'SERVICE',
        objet: 'Service 3',
        description: 'Desc 3',
        statut: 'RESOLUE',
        dateCreation: '12/04/2025',
      ),
      ReclamationModel(
        id: 4,
        codeReference: '#REC-2025-0004',
        salonNom: 'Salon Beauty',
        salonSlug: 'salon-beauty',
        type: 'PAIEMENT',
        objet: 'Paiement 4',
        description: 'Desc 4',
        statut: 'REJETEE',
        dateCreation: '12/04/2025',
      ),
      ReclamationModel(
        id: 5,
        codeReference: '#REC-2025-0005',
        salonNom: 'Beauty By Dika',
        salonSlug: 'beauty-by-dika',
        type: 'SERVICE',
        objet: 'Service 5',
        description: 'Desc 5',
        statut: 'EN_ATTENTE',
        dateCreation: '12/04/2025',
      ),
      ReclamationModel(
        id: 6,
        codeReference: '#REC-2025-0006',
        salonNom: 'Mathy Hair',
        salonSlug: 'mathy-hair',
        type: 'SALON',
        objet: 'Salon 6',
        description: 'Desc 6',
        statut: 'EN_COURS',
        dateCreation: '12/04/2025',
      ),
    ];

    test('Filters by status tab correctly', () {
      const state = MesReclamationsState(
        allReclamations: testReclamations,
        selectedStatutTab: 'EN_ATTENTE',
      );

      final attenteList = state.reclamationsFiltrees;
      expect(attenteList.every((r) => r.isEnAttente), isTrue);

      final stateEnCours = state.copyWith(selectedStatutTab: 'EN_COURS');
      expect(stateEnCours.reclamationsFiltrees.every((r) => r.isEnCours), isTrue);

      final stateResolue = state.copyWith(selectedStatutTab: 'RESOLUE');
      expect(stateResolue.reclamationsFiltrees.every((r) => r.isResolue), isTrue);

      final stateRejetee = state.copyWith(selectedStatutTab: 'REJETEE');
      expect(stateRejetee.reclamationsFiltrees.every((r) => r.isRejetee), isTrue);
    });

    test('Filters by salon correctly', () {
      const state = MesReclamationsState(
        allReclamations: testReclamations,
        selectedSalonSlug: 'salon-beauty',
      );

      final salonList = state.reclamationsFiltrees;
      expect(salonList.every((r) => r.salonSlug == 'salon-beauty'), isTrue);
      expect(salonList.length, 4); // 1 en attente, 1 en cours, 1 résolue, 1 rejetée
    });

    test('Extracts unique available salons dynamically', () {
      const state = MesReclamationsState(
        allReclamations: testReclamations,
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
