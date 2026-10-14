import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/features/recommandations/data/models/astuce_naturelle_model.dart';
import 'package:mobile_hair_style/features/recommandations/data/models/produit_conseil_model.dart';
import 'package:mobile_hair_style/features/recommandations/data/recommandation_mock_data.dart';

void main() {
  group('Recommandations & Profil Capillaire Tests', () {
    test('ProduitConseilModel fromJson et labels d\'étape', () {
      final json = {
        'id': 101,
        'nom': 'Shampoing Doux Hydratant',
        'marque': 'Kérastase',
        'description': 'Nettoie en douceur.',
        'modeUtilisation': 'Appliquer et masser 2 minutes.',
        'etapeRoutine': 'LAVAGE',
        'typesCheveuxCibles': ['CREPUS', 'BOUCLES'],
        'scoreAffinite': 96,
      };

      final produit = ProduitConseilModel.fromJson(json);
      expect(produit.id, 101);
      expect(produit.nom, 'Shampoing Doux Hydratant');
      expect(produit.etapeRoutine, 'LAVAGE');
      expect(produit.etapeLabel, 'Étape 1 : Lavage');
      expect(produit.etapeShortLabel, 'Lavage');
      expect(produit.scoreAffinite, 96);
      expect(produit.typesCheveuxCibles, contains('CREPUS'));
    });

    test('ProfilCapillaireModel complet et JSON mapping', () {
      final profil = RecommandationMockData.mockProfilCapillaire;
      expect(profil.isComplet, isTrue);
      expect(profil.typeCheveux, 'CREPUS');
      expect(profil.porosite, 'FORTE');
      expect(profil.cuirChevelu, 'SEC');

      final json = profil.toJson();
      expect(json['typeCheveux'], 'CREPUS');
      expect(json['porosite'], 'FORTE');
    });

    test('RecommandationCapillaireModel routine 4 étapes et cooldown', () {
      final reco = RecommandationMockData.mockDerniereRecommandation;
      expect(reco.reference, startsWith('REC-'));
      expect(reco.scoreGlobal, 95);
      expect(reco.isCooldownActive, isTrue);
      expect(reco.joursRestantsAvantProchainDiagnostic, 27);
      expect(reco.tousLesProduits.length, 4);

      expect(reco.produitLavage?.etapeRoutine, 'LAVAGE');
      expect(reco.produitSoinProfond?.etapeRoutine, 'SOIN_PROFOND');
      expect(reco.produitHydratation?.etapeRoutine, 'HYDRATATION');
      expect(reco.produitFinition?.etapeRoutine, 'FINITION');
    });

    test('AstuceNaturelleModel liste d\'astuces par défaut 0 FCFA', () {
      final astuces = AstuceNaturelleModel.astucesParDefaut;
      expect(astuces.isNotEmpty, isTrue);
      expect(astuces.first.type, 'Petit Budget');
      expect(astuces.first.ingredients.isNotEmpty, isTrue);
    });
  });
}
