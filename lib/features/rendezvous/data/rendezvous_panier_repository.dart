import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/rendezvous_panier_model.dart';

final rendezvousPanierRepositoryProvider = Provider<RendezvousPanierRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RendezvousPanierRepository(apiClient);
});

class RendezvousPanierRepository {
  final ApiClient _apiClient;
  static const String _localRdvPanierKey = 'mon_salon_local_rdv_panier_v1';

  RendezvousPanierRepository(this._apiClient);

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ==========================================
  // PERSISTANCE LOCALE (MULTI-SALON RDV)
  // ==========================================

  Future<List<SalonRendezVousPanierModel>> getLocalPaniers() async {
    try {
      final sp = await _prefs;
      final raw = sp.getString(_localRdvPanierKey);
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => SalonRendezVousPanierModel.fromJson(item as Map<String, dynamic>))
          .where((s) => s.prestations.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLocalPaniers(List<SalonRendezVousPanierModel> paniers) async {
    try {
      final sp = await _prefs;
      final active = paniers.where((p) => p.prestations.isNotEmpty).toList();
      final encoded = jsonEncode(active.map((p) => p.toJson()).toList());
      await sp.setString(_localRdvPanierKey, encoded);
    } catch (_) {}
  }

  Future<List<SalonRendezVousPanierModel>> ajouterPrestationLocal({
    required String slugSalon,
    required String salonNom,
    String? salonLogo,
    required LignePrestationPanierModel prestation,
  }) async {
    final list = await getLocalPaniers();
    final index = list.indexWhere((p) => p.slugSalon == slugSalon);

    if (index >= 0) {
      final current = list[index];
      final prestas = List<LignePrestationPanierModel>.from(current.prestations);
      final pIndex = prestas.indexWhere((p) => p.varianteId == prestation.varianteId);
      if (pIndex >= 0) {
        // Déjà présente, on met à jour les infos
        prestas[pIndex] = prestation;
      } else {
        prestas.add(prestation);
      }
      list[index] = current.copyWith(
        prestations: prestas,
        salonNom: salonNom,
        salonLogo: salonLogo ?? current.salonLogo,
      );
    } else {
      list.add(SalonRendezVousPanierModel(
        slugSalon: slugSalon,
        salonNom: salonNom,
        salonLogo: salonLogo,
        prestations: [prestation],
      ));
    }

    await saveLocalPaniers(list);
    return list;
  }

  Future<List<SalonRendezVousPanierModel>> retirerPrestationLocal(
    String slugSalon,
    int varianteId,
  ) async {
    final list = await getLocalPaniers();
    final index = list.indexWhere((p) => p.slugSalon == slugSalon);

    if (index >= 0) {
      final current = list[index];
      final updatedPrestas = current.prestations.where((p) => p.varianteId != varianteId).toList();
      if (updatedPrestas.isEmpty) {
        list.removeAt(index);
      } else {
        list[index] = current.copyWith(prestations: updatedPrestas);
      }
      await saveLocalPaniers(list);
    }
    return list;
  }

  Future<List<SalonRendezVousPanierModel>> definirDateHeureLocal(
    String slugSalon,
    DateTime dateHeure,
  ) async {
    final list = await getLocalPaniers();
    final index = list.indexWhere((p) => p.slugSalon == slugSalon);
    if (index >= 0) {
      list[index] = list[index].copyWith(dateHeurePrevue: dateHeure);
      await saveLocalPaniers(list);
    }
    return list;
  }

  Future<List<SalonRendezVousPanierModel>> definirCoiffeurLocal(
    String slugSalon,
    int? coiffeurId,
    String? coiffeurNom,
  ) async {
    final list = await getLocalPaniers();
    final index = list.indexWhere((p) => p.slugSalon == slugSalon);
    if (index >= 0) {
      list[index] = list[index].copyWith(
        coiffeurId: coiffeurId,
        coiffeurNom: coiffeurNom,
        clearCoiffeur: coiffeurId == null,
      );
      await saveLocalPaniers(list);
    }
    return list;
  }

  Future<List<SalonRendezVousPanierModel>> definirNotesLocal(
    String slugSalon,
    String notes,
  ) async {
    final list = await getLocalPaniers();
    final index = list.indexWhere((p) => p.slugSalon == slugSalon);
    if (index >= 0) {
      list[index] = list[index].copyWith(notes: notes);
      await saveLocalPaniers(list);
    }
    return list;
  }

  Future<List<SalonRendezVousPanierModel>> viderSalonLocal(String slugSalon) async {
    final list = await getLocalPaniers();
    list.removeWhere((p) => p.slugSalon == slugSalon);
    await saveLocalPaniers(list);
    return list;
  }

  Future<void> viderToutLocal() async {
    final sp = await _prefs;
    await sp.remove(_localRdvPanierKey);
  }

  // ==========================================
  // VALIDATION PAR SALON VERS SPRING BOOT
  // ==========================================

  /// Validation stricte PAR SALON
  Future<void> validerRendezVousSalon({
    required String slugSalon,
    required DateTime dateHeurePrevue,
    required List<int> varianteIds,
    int? coiffeurId,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'dateHeurePrevue': dateHeurePrevue.toIso8601String(),
      'varianteIds': varianteIds,
    };
    if (coiffeurId != null) payload['coiffeurId'] = coiffeurId;
    if (notes != null && notes.isNotEmpty) payload['notes'] = notes;

    try {
      // 1. Essai via le point de terminaison authentifié du salon
      await _apiClient.post(
        ApiEndpoints.salonClientRendezVous(slugSalon),
        data: payload,
      );
    } catch (_) {
      // 2. Si le client est en mode vitrine ou route alternative
      await _apiClient.post(
        ApiEndpoints.salonVitrineRendezVous(slugSalon),
        data: payload,
      );
    }

    // Après confirmation, retirer ce salon du panier de rendez-vous
    await viderSalonLocal(slugSalon);
  }
}
