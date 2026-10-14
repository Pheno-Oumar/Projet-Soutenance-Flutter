import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/profil_capillaire_model.dart';
import '../../data/models/recommandation_capillaire_model.dart';
import '../../data/recommandation_service.dart';

// État de la dernière recommandation
final derniereRecommandationProvider =
    AsyncNotifierProvider<DerniereRecommandationNotifier, RecommandationCapillaireModel?>(
  DerniereRecommandationNotifier.new,
);

class DerniereRecommandationNotifier
    extends AsyncNotifier<RecommandationCapillaireModel?> {
  @override
  Future<RecommandationCapillaireModel?> build() async {
    final service = ref.watch(recommandationServiceProvider);
    return await service.getDerniereRecommandation();
  }

  Future<void> rafraichir() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(recommandationServiceProvider);
      return await service.getDerniereRecommandation();
    });
  }

  Future<void> genererRoutine() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(recommandationServiceProvider);
      final nouvelle = await service.genererRecommandation();
      // Rafraîchir l'historique aussi
      ref.invalidate(historiqueRecommandationsProvider);
      return nouvelle;
    });
  }
}

// État de l'historique
final historiqueRecommandationsProvider =
    FutureProvider.autoDispose<List<RecommandationCapillaireModel>>((ref) async {
  final service = ref.watch(recommandationServiceProvider);
  return await service.getHistorique();
});

// Détail d'une recommandation par son ID
final detailRecommandationProvider =
    FutureProvider.autoDispose.family<RecommandationCapillaireModel, int>((ref, id) async {
  final service = ref.watch(recommandationServiceProvider);
  return await service.getDetailRecommandation(id);
});

// État du profil capillaire
final profilCapillaireProvider =
    AsyncNotifierProvider<ProfilCapillaireNotifier, ProfilCapillaireModel?>(
  ProfilCapillaireNotifier.new,
);

class ProfilCapillaireNotifier extends AsyncNotifier<ProfilCapillaireModel?> {
  @override
  Future<ProfilCapillaireModel?> build() async {
    final service = ref.watch(recommandationServiceProvider);
    return await service.getMonProfilCapillaire();
  }

  Future<void> enregistrerProfil(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(recommandationServiceProvider);
      final profil = await service.enregistrerOuModifierProfil(data);
      return profil;
    });
  }

  Future<bool> changerPin(String pin) async {
    final service = ref.read(recommandationServiceProvider);
    final ok = await service.definirCodePin(pin);
    if (ok && state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(hasCodeProfil: true));
    }
    return ok;
  }
}
