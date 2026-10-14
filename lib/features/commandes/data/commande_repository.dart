import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/commande_model.dart';

final commandeRepositoryProvider = Provider<CommandeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommandeRepository(apiClient);
});

class CommandeRepository {
  final ApiClient _apiClient;

  CommandeRepository(this._apiClient);

  List<CommandeModel> getMockCommandesSync({StatutCommande? filtreStatut}) {
    final mockLignes1 = [
      const LigneCommandeModel(
        id: 1,
        produitId: 101,
        produitNom: 'Care - Soin Capillaire 250ml',
        quantite: 1,
        prixUnitaire: 12500,
        sousTotal: 12500,
        imagePath: 'assets/images/produit_cat_img_0.jpg',
      ),
      const LigneCommandeModel(
        id: 2,
        produitId: 102,
        produitNom: 'Huile de Ricin Pure 100ml',
        quantite: 2,
        prixUnitaire: 5000,
        sousTotal: 10000,
        imagePath: 'assets/images/produit_cat_img_1.jpg',
      ),
    ];

    final mockLignes2 = [
      const LigneCommandeModel(
        id: 3,
        produitId: 103,
        produitNom: 'Shampoing Bio Kérastase 300ml',
        quantite: 1,
        prixUnitaire: 15000,
        sousTotal: 15000,
        imagePath: 'assets/images/produit_cat_img_2.jpg',
      ),
      const LigneCommandeModel(
        id: 4,
        produitId: 104,
        produitNom: 'Sérum Réparateur Pointes 50ml',
        quantite: 1,
        prixUnitaire: 14500,
        sousTotal: 14500,
        imagePath: 'assets/images/produit_cat_img_3.jpg',
      ),
    ];

    final allCommandes = [
      // 1. COMMANDE VALIDÉE (comme sur Mes commandes.svg)
      CommandeModel(
        id: 2,
        numeroCommande: '#COM-2025-0048',
        dateCommande: DateTime(2025, 4, 12, 11, 20),
        statut: StatutCommande.validee,
        montantTotal: 25000,
        sousTotal: 22500,
        fraisLivraison: 2500,
        codeRetrait: 'RET-2025-4892',
        clientNom: 'Aïcha Diallo',
        clientTelephone: '+221 77 123 45 67',
        adresseLivraison: 'Almadies, près de la pharmacie du rond-point',
        lignes: mockLignes1,
      ),

      // 2. COMMANDE EN ATTENTE (comme sur Details commande en attente.svg)
      CommandeModel(
        id: 1,
        numeroCommande: '#COM-2026-0048',
        dateCommande: DateTime(2026, 9, 12, 15, 42),
        statut: StatutCommande.enAttente,
        montantTotal: 25000,
        sousTotal: 22500,
        fraisLivraison: 2500,
        clientNom: 'Aïcha Diallo',
        clientTelephone: '+221 77 123 45 67',
        adresseLivraison: 'Almadies, près de la pharmacie du rond-point',
        lignes: mockLignes1,
      ),

      // 3. COMMANDE RÉCUPÉRÉE (comme sur Mes commandes recuperer.svg)
      CommandeModel(
        id: 3,
        numeroCommande: '#COM-2025-0049',
        dateCommande: DateTime(2025, 4, 12, 14, 15),
        statut: StatutCommande.recuperee,
        montantTotal: 25000,
        sousTotal: 22500,
        fraisLivraison: 2500,
        modePaiement: 'Wave',
        numeroFacture: 'FACT-2025-0812',
        clientNom: 'Aïcha Diallo',
        clientTelephone: '+221 77 123 45 67',
        adresseLivraison: 'Almadies, près de la pharmacie du rond-point',
        lignes: mockLignes1,
      ),

      // 4. COMMANDE VALIDÉE 2 (deuxième carte validée comme dans la maquette)
      CommandeModel(
        id: 7,
        numeroCommande: '#COM-2025-0053',
        dateCommande: DateTime(2025, 4, 10, 16, 30),
        statut: StatutCommande.validee,
        montantTotal: 32000,
        sousTotal: 29500,
        fraisLivraison: 2500,
        codeRetrait: 'RET-2025-5310',
        clientNom: 'Aïcha Diallo',
        clientTelephone: '+221 77 123 45 67',
        adresseLivraison: 'Almadies, près de la pharmacie du rond-point',
        lignes: mockLignes2,
      ),

      // 5. COMMANDE ANNULÉE (comme sur Mes commandes.svg)
      CommandeModel(
        id: 5,
        numeroCommande: '#COM-2025-0051',
        dateCommande: DateTime(2025, 4, 8, 16, 45),
        statut: StatutCommande.annulee,
        montantTotal: 25000,
        sousTotal: 22500,
        fraisLivraison: 2500,
        clientNom: 'Aïcha Diallo',
        clientTelephone: '+221 77 123 45 67',
        adresseLivraison: 'Almadies, près de la pharmacie du rond-point',
        lignes: mockLignes1,
      ),

      // 6. COMMANDE REJETÉE (comme sur Details commande rejette.svg)
      CommandeModel(
        id: 4,
        numeroCommande: '#COM-2025-0050',
        dateCommande: DateTime(2025, 4, 10, 9, 30),
        statut: StatutCommande.rejette,
        montantTotal: 25000,
        sousTotal: 22500,
        fraisLivraison: 2500,
        motifRejet:
            'Rupture de stock momentanée sur le produit Care Soin Capillaire 250ml auprès du salon partenaire.',
        clientNom: 'Aïcha Diallo',
        clientTelephone: '+221 77 123 45 67',
        adresseLivraison: 'Almadies, près de la pharmacie du rond-point',
        lignes: mockLignes1,
      ),

      // 7. COMMANDE EN ATTENTE 2
      CommandeModel(
        id: 6,
        numeroCommande: '#COM-2026-0052',
        dateCommande: DateTime(2026, 9, 13, 10, 15),
        statut: StatutCommande.enAttente,
        montantTotal: 29500,
        sousTotal: 27000,
        fraisLivraison: 2500,
        clientNom: 'Aïcha Diallo',
        clientTelephone: '+221 77 123 45 67',
        adresseLivraison: 'Almadies, près de la pharmacie du rond-point',
        lignes: mockLignes2,
      ),

      // 8. COMMANDE RÉCUPÉRÉE 2
      CommandeModel(
        id: 8,
        numeroCommande: '#COM-2025-0054',
        dateCommande: DateTime(2025, 4, 5, 18, 00),
        statut: StatutCommande.recuperee,
        montantTotal: 25000,
        sousTotal: 22500,
        fraisLivraison: 2500,
        modePaiement: 'Wave',
        numeroFacture: 'FACT-2025-0744',
        clientNom: 'Aïcha Diallo',
        clientTelephone: '+221 77 123 45 67',
        adresseLivraison: 'Almadies, près de la pharmacie du rond-point',
        lignes: mockLignes1,
      ),

      // 9. COMMANDE RÉCUPÉRÉE 3
      CommandeModel(
        id: 9,
        numeroCommande: '#COM-2025-0055',
        dateCommande: DateTime(2025, 3, 28, 12, 40),
        statut: StatutCommande.recuperee,
        montantTotal: 32000,
        sousTotal: 29500,
        fraisLivraison: 2500,
        modePaiement: 'Orange Money',
        numeroFacture: 'FACT-2025-0691',
        clientNom: 'Aïcha Diallo',
        clientTelephone: '+221 77 123 45 67',
        adresseLivraison: 'Almadies, près de la pharmacie du rond-point',
        lignes: mockLignes2,
      ),

      // 10. COMMANDE REJETÉE 2
      CommandeModel(
        id: 10,
        numeroCommande: '#COM-2025-0056',
        dateCommande: DateTime(2025, 4, 2, 14, 00),
        statut: StatutCommande.rejette,
        montantTotal: 19500,
        sousTotal: 17000,
        fraisLivraison: 2500,
        motifRejet: 'Article momentanément indisponible chez le fournisseur.',
        clientNom: 'Aïcha Diallo',
        clientTelephone: '+221 77 123 45 67',
        adresseLivraison: 'Almadies, près de la pharmacie du rond-point',
        lignes: mockLignes1,
      ),

      // 11. COMMANDE ANNULÉE 2
      CommandeModel(
        id: 11,
        numeroCommande: '#COM-2025-0057',
        dateCommande: DateTime(2025, 3, 25, 11, 10),
        statut: StatutCommande.annulee,
        montantTotal: 17500,
        sousTotal: 15000,
        fraisLivraison: 2500,
        clientNom: 'Aïcha Diallo',
        clientTelephone: '+221 77 123 45 67',
        adresseLivraison: 'Almadies, près de la pharmacie du rond-point',
        lignes: mockLignes2,
      ),
    ];

    if (filtreStatut == null) {
      return allCommandes;
    }
    return allCommandes.where((c) => c.statut == filtreStatut).toList();
  }

  Future<List<CommandeModel>> getCommandes({StatutCommande? filtreStatut}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (filtreStatut != null) {
        queryParams['statut'] = filtreStatut.code;
      }
      final response = await _apiClient.get(
        ApiEndpoints.clientCommandes,
        queryParameters: queryParams,
      );
      if (response.data != null && response.data['data'] is List) {
        final list = (response.data['data'] as List)
            .map((e) => CommandeModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {
      // Ignorer l'erreur réseau et retourner les données statiques
    }

    return getMockCommandesSync(filtreStatut: filtreStatut);
  }

  Future<CommandeModel> getCommandeDetail(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.clientCommandeDetail(id));
      if (response.data != null && response.data['data'] != null) {
        return CommandeModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}

    final all = getMockCommandesSync();
    return all.firstWhere((c) => c.id == id, orElse: () => all.first);
  }

  Future<bool> annulerCommande(int id) async {
    try {
      await _apiClient.post('${ApiEndpoints.clientCommandes}/$id/annuler');
      return true;
    } catch (_) {
      return true; // Mode démo
    }
  }
}
