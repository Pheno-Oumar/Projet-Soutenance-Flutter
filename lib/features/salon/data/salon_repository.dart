import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/salon_model.dart';
import 'models/service_salon_model.dart';
import 'models/produit_salon_model.dart';
import 'models/realisation_salon_model.dart';
import 'models/coiffeur_salon_model.dart';
import 'models/avis_salon_model.dart';
import 'models/horaire_salon_model.dart';
import 'models/creneau_disponible_model.dart';
import 'models/story_salon_model.dart';

final salonRepositoryProvider = Provider<SalonRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SalonRepository(apiClient);
});

class SalonRepository {
  final ApiClient _apiClient;

  SalonRepository(this._apiClient);

  Future<PageResponse<SalonModel>> listerSalons({
    int page = 0,
    int size = 15,
    String? query,
  }) async {
    final endpoint = query != null && query.isNotEmpty
        ? ApiEndpoints.salonSearch
        : ApiEndpoints.salons;

    final queryParams = <String, dynamic>{'page': page, 'size': size};
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    final response = await _apiClient.get(
      endpoint,
      queryParameters: queryParams,
    );

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      // Si la réponse est une liste directe (comme /salons/search)
      if (payload is List) {
        final salons = payload
            .map((item) => SalonModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return PageResponse<SalonModel>(
          content: salons,
          totalElements: salons.length,
          totalPages: 1,
          size: size,
          number: page,
        );
      } else if (payload is Map<String, dynamic>) {
        return PageResponse<SalonModel>.fromJson(
          payload,
          (item) => SalonModel.fromJson(item),
        );
      }
    }
    return const PageResponse(content: [], totalElements: 0, totalPages: 0, size: 15, number: 0);
  }

  /// Récupère la liste géolocalisée des salons filtrés par Hibernate / MySQL Spatial
  Future<List<SalonModel>> listerSalonsNearby({
    required double lat,
    required double lng,
    double rayonKm = 5.0,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.salonNearby,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'rayonKm': rayonKm,
        },
      );

      final rawData = response.data;
      if (rawData is Map<String, dynamic>) {
        final payload = rawData['data'];
        if (payload is List) {
          return payload
              .map((item) => SalonModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<SalonModel> getSalonBySlug(String slug) async {
    final response = await _apiClient.get(ApiEndpoints.salonDetail(slug));

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      return SalonModel.fromJson(apiResp.data!);
    }
    throw Exception(apiResp.message ?? 'Salon introuvable');
  }

  /// Récupère la liste des services et variantes d'un salon
  Future<List<ServiceSalonModel>> getServicesSalon(String slug) async {
    final response = await _apiClient.get(ApiEndpoints.salonServices(slug));

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is List) {
        return payload
            .map((item) =>
                ServiceSalonModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Récupère le détail d'un service précis d'un salon
  Future<ServiceSalonModel> getServiceDetail(String slug, int serviceId) async {
    final response =
        await _apiClient.get(ApiEndpoints.salonServiceDetail(slug, serviceId));

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is Map<String, dynamic>) {
        return ServiceSalonModel.fromJson(payload);
      }
    }
    throw Exception('Service introuvable');
  }

  /// Récupère la liste des catégories de produits d'un salon
  Future<List<CategorieProduitModel>> getCategoriesProduits(String slug) async {
    final response =
        await _apiClient.get(ApiEndpoints.salonCategoriesProduits(slug));

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is List) {
        return payload
            .map((item) =>
                CategorieProduitModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Récupère le détail d'une catégorie de produit avec ses produits
  Future<CategorieProduitModel> getCategorieProduitDetail(
      String slug, int categorieId) async {
    final response = await _apiClient
        .get(ApiEndpoints.salonCategorieProduitDetail(slug, categorieId));

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is Map<String, dynamic>) {
        return CategorieProduitModel.fromJson(payload);
      }
    }
    throw Exception('Catégorie introuvable');
  }

  /// Récupère les produits d'un salon (avec filtre optionnel par catégorie)
  Future<List<ProduitSalonModel>> getProduitsSalon(String slug,
      {int? categorieId}) async {
    final queryParams = <String, dynamic>{};
    if (categorieId != null) {
      queryParams['categorieId'] = categorieId;
    }

    final response = await _apiClient.get(
      ApiEndpoints.salonProduits(slug),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is List) {
        return payload
            .map((item) =>
                ProduitSalonModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Récupère le détail d'un produit précis d'un salon
  Future<ProduitSalonModel> getProduitSalonDetail(
      String slug, int produitId) async {
    final response =
        await _apiClient.get(ApiEndpoints.salonProduitDetail(slug, produitId));

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is Map<String, dynamic>) {
        return ProduitSalonModel.fromJson(payload);
      }
    }
    throw Exception('Produit introuvable');
  }

  /// Récupère le catalogue transversal des produits (tous salons)
  Future<List<ProduitSalonModel>> listerProduitsTransversal(
      {int? categorieId}) async {
    final queryParams = <String, dynamic>{};
    if (categorieId != null) {
      queryParams['categorieId'] = categorieId;
    }

    final response = await _apiClient.get(
      ApiEndpoints.produitsTransversal,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is List) {
        return payload
            .map((item) =>
                ProduitSalonModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Récupère le catalogue transversal des prestations proposées (tous salons)
  Future<List<ServiceSalonModel>> listerServicesTransversal(
      {String? query}) async {
    final queryParams = <String, dynamic>{};
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    final response = await _apiClient.get(
      ApiEndpoints.servicesTransversal,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is List) {
        return payload
            .map((item) =>
                ServiceSalonModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Récupère la galerie des réalisations publiées d'un salon
  Future<List<RealisationSalonModel>> getRealisationsSalon(String slug) async {
    final response = await _apiClient.get(ApiEndpoints.salonRealisations(slug));
    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is List) {
        return payload
            .map((item) =>
                RealisationSalonModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Récupère les avis clients publiés d'un salon
  Future<List<AvisSalonModel>> getAvisSalon(String slug) async {
    final response = await _apiClient.get(ApiEndpoints.salonAvis(slug));
    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is List) {
        return payload
            .map((item) => AvisSalonModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Récupère l'équipe des coiffeurs d'un salon
  Future<List<CoiffeurSalonModel>> getCoiffeursSalon(String slug) async {
    final response = await _apiClient.get(ApiEndpoints.salonCoiffeurs(slug));
    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is List) {
        return payload
            .map((item) =>
                CoiffeurSalonModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Récupère les horaires d'ouverture d'un salon
  Future<List<HoraireSalonModel>> getHorairesSalon(String slug) async {
    final response = await _apiClient.get(ApiEndpoints.salonHoraires(slug));
    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is List) {
        return payload
            .map((item) =>
                HoraireSalonModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Récupère les réalisations transversales (tous salons confondus)
  Future<List<RealisationSalonModel>> listerRealisationsTransversales() async {
    final response = await _apiClient.get(ApiEndpoints.realisationsTransversal);
    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['data'];
      if (payload is List) {
        return payload
            .map((item) =>
                RealisationSalonModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Calcule et récupère les créneaux disponibles depuis le backend selon variantes, date et coiffeur
  Future<List<CreneauDisponibleModel>> getDisponibilitesSalon({
    required String slug,
    required DateTime date,
    required List<int> varianteIds,
    int? coiffeurId,
    String? heureMinimale,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final payload = <String, dynamic>{
      'date': dateStr,
      'varianteIds': varianteIds,
    };
    if (coiffeurId != null) payload['coiffeurId'] = coiffeurId;
    if (heureMinimale != null && heureMinimale.isNotEmpty) {
      payload['heureMinimale'] = heureMinimale;
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.salonDisponibilites(slug),
        data: payload,
      );

      final rawData = response.data;
      if (rawData is Map<String, dynamic>) {
        final data = rawData['data'];
        if (data is List) {
          return data
              .map((item) =>
                  CreneauDisponibleModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Récupère les stories actives (< 24h) d'un salon spécifique
  Future<List<StorySalonModel>> getStoriesSalon(String slug) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.salonStories(slug));
      final rawData = response.data;
      if (rawData is Map<String, dynamic>) {
        final data = rawData['data'];
        if (data is List) {
          return data
              .map((item) => StorySalonModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Récupère toutes les stories actives groupées par salon pour Kady's / Accueil
  Future<List<SalonStoriesGroupModel>> getKadysStories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.kadysStories);
      final rawData = response.data;
      if (rawData is List) {
        return rawData
            .map((item) => SalonStoriesGroupModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (rawData is Map<String, dynamic>) {
        final data = rawData['data'];
        if (data is List) {
          return data
              .map((item) => SalonStoriesGroupModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }
}
