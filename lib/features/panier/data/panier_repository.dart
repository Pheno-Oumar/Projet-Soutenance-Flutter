import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../commandes/data/models/commande_model.dart';
import 'models/panier_model.dart';

final panierRepositoryProvider = Provider<PanierRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PanierRepository(apiClient);
});

class PanierRepository {
  final ApiClient _apiClient;
  static const String _localPaniersKey = 'mon_salon_local_paniers_v1';

  PanierRepository(this._apiClient);

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ==========================================
  // GESTION LOCALE (INVITÉ / HORS-LIGNE)
  // ==========================================

  Future<List<PanierModel>> getLocalPaniers() async {
    try {
      final sp = await _prefs;
      final raw = sp.getString(_localPaniersKey);
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => PanierModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLocalPaniers(List<PanierModel> paniers) async {
    try {
      final sp = await _prefs;
      final active = paniers.where((p) => p.lignes.isNotEmpty).toList();
      if (active.isEmpty) {
        await sp.remove(_localPaniersKey);
      } else {
        final encoded = jsonEncode(active.map((p) => p.toJson()).toList());
        await sp.setString(_localPaniersKey, encoded);
      }
    } catch (_) {}
  }

  Future<void> supprimerPanierLocal(String slugSalon) async {
    try {
      final list = await getLocalPaniers();
      final updated = list.where((p) => p.slugSalon != slugSalon).toList();
      await saveLocalPaniers(updated);
    } catch (_) {}
  }

  Future<void> viderTousLesPaniersLocaux() async {
    try {
      final sp = await _prefs;
      await sp.remove(_localPaniersKey);
    } catch (_) {}
  }

  Future<List<PanierModel>> ajouterArticleLocal({
    required String slugSalon,
    String? salonNom,
    required int produitId,
    required String produitNom,
    required double prixUnitaire,
    required int quantite,
    String? imageUrl,
  }) async {
    final list = await getLocalPaniers();
    final salonIndex = list.indexWhere((p) => p.slugSalon == slugSalon);

    if (salonIndex >= 0) {
      final currentPanier = list[salonIndex];
      final ligneIndex = currentPanier.lignes.indexWhere((l) => l.produitId == produitId);

      List<LignePanierModel> updatedLignes = List.from(currentPanier.lignes);
      if (ligneIndex >= 0) {
        final existing = updatedLignes[ligneIndex];
        final newQte = existing.quantite + quantite;
        updatedLignes[ligneIndex] = existing.copyWith(
          quantite: newQte,
          sousTotal: existing.prixUnitaire * newQte,
        );
      } else {
        updatedLignes.add(LignePanierModel(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          produitId: produitId,
          produitNom: produitNom,
          imageUrl: imageUrl,
          prixUnitaire: prixUnitaire,
          quantite: quantite,
          sousTotal: prixUnitaire * quantite,
          stockDisponible: 99,
        ));
      }

      list[salonIndex] = currentPanier.copyWith(
        lignes: updatedLignes,
        montantTotal: updatedLignes.fold<double>(0.0, (s, l) => s + l.sousTotal),
        nombreArticles: updatedLignes.fold<int>(0, (s, l) => s + l.quantite),
      );
    } else {
      list.add(PanierModel(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        slugSalon: slugSalon,
        salonNom: salonNom ?? slugSalon,
        lignes: [
          LignePanierModel(
            id: DateTime.now().millisecondsSinceEpoch % 100000,
            produitId: produitId,
            produitNom: produitNom,
            imageUrl: imageUrl,
            prixUnitaire: prixUnitaire,
            quantite: quantite,
            sousTotal: prixUnitaire * quantite,
            stockDisponible: 99,
          ),
        ],
        montantTotal: prixUnitaire * quantite,
        nombreArticles: quantite,
      ));
    }

    await saveLocalPaniers(list);
    return list;
  }

  // ==========================================
  // GESTION DISTANTE (AUTHENTIFIÉ SUR SPRING BOOT)
  // ==========================================

  /// Récupère tous les paniers actifs groupés par salon
  Future<List<PanierModel>> getPaniers({bool isAuth = true}) async {
    if (!isAuth) {
      return await getLocalPaniers();
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.clientPaniers);
      final apiResp = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as List<dynamic>,
      );

      final remoteList = apiResp.data != null
          ? apiResp.data!
              .map((item) => PanierModel.fromJson(item as Map<String, dynamic>))
              .where((p) => p.lignes.isNotEmpty)
              .toList()
          : <PanierModel>[];

      // Lorsque l'utilisateur est authentifié et que le serveur répond,
      // la réponse distante est la seule source de vérité.
      // Si la liste distante est vide, le panier est vide côté backend : on purge aussi le local.
      if (remoteList.isEmpty) {
        await viderTousLesPaniersLocaux();
      }
      return remoteList;
    } catch (_) {
      // En cas de problème réseau, basculer sur les paniers locaux
      return await getLocalPaniers();
    }
  }

  Future<void> ajouterArticleRemote({
    required String slugSalon,
    required int produitId,
    required int quantite,
  }) async {
    await _apiClient.post(
      ApiEndpoints.salonPanierArticles(slugSalon),
      data: {
        'produitId': produitId,
        'quantite': quantite,
      },
    );
  }

  Future<void> modifierQuantiteRemote({
    required String slugSalon,
    required int produitId,
    required int quantite,
  }) async {
    await _apiClient.put(
      ApiEndpoints.salonPanierArticle(slugSalon, produitId),
      data: {'quantite': quantite},
    );
  }

  Future<void> supprimerArticleRemote({
    required String slugSalon,
    required int produitId,
  }) async {
    await _apiClient.delete(
      ApiEndpoints.salonPanierArticle(slugSalon, produitId),
    );
  }

  Future<void> viderPanierRemote(String slugSalon) async {
    await _apiClient.delete(ApiEndpoints.salonPanier(slugSalon));
    await supprimerPanierLocal(slugSalon);
  }

  Future<void> viderTousPaniersRemote() async {
    await _apiClient.delete(ApiEndpoints.clientPaniersViderTous);
    await viderTousLesPaniersLocaux();
  }

  /// Passer commande pour un salon spécifique
  Future<CommandeModel?> validerCommandeSalon(String slugSalon) async {
    final response = await _apiClient.post(ApiEndpoints.salonCommande(slugSalon));
    await supprimerPanierLocal(slugSalon);
    if (response.data != null &&
        response.data is Map<String, dynamic> &&
        response.data['data'] != null &&
        response.data['data'] is Map<String, dynamic>) {
      return CommandeModel.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return CommandeModel(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      numeroCommande: '#COM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      dateCommande: DateTime.now(),
      statut: StatutCommande.enAttente,
      montantTotal: 0.0,
      sousTotal: 0.0,
      fraisLivraison: 0.0,
      lignes: const [],
    );
  }

  /// Synchronisation automatique des paniers locaux vers Spring Boot lors de la connexion
  Future<void> synchroniserApresConnexion() async {
    final local = await getLocalPaniers();
    if (local.isEmpty) return;

    final List<PanierModel> nonSynchronises = [];

    for (final panier in local) {
      if (panier.slugSalon == null || panier.lignes.isEmpty) continue;
      final List<LignePanierModel> lignesRestantes = [];
      for (final ligne in panier.lignes) {
        try {
          await ajouterArticleRemote(
            slugSalon: panier.slugSalon!,
            produitId: ligne.produitId,
            quantite: ligne.quantite,
          );
        } catch (_) {
          // En cas d'échec sur une ligne, on la préserve pour ne jamais perdre le panier
          lignesRestantes.add(ligne);
        }
      }
      if (lignesRestantes.isNotEmpty) {
        nonSynchronises.add(panier.copyWith(
          lignes: lignesRestantes,
          nombreArticles: lignesRestantes.fold<int>(0, (s, l) => s + l.quantite),
          montantTotal: lignesRestantes.fold<double>(0.0, (s, l) => s + l.sousTotal),
        ));
      }
    }

    if (nonSynchronises.isEmpty) {
      final sp = await _prefs;
      await sp.remove(_localPaniersKey);
    } else {
      await saveLocalPaniers(nonSynchronises);
    }
  }
}
