import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_hair_style/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_hair_style/features/compte/data/models/compte_model.dart';
import 'package:mobile_hair_style/features/compte/data/compte_repository.dart';

final clientProfileProvider = FutureProvider.autoDispose<CompteModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (!authState.isAuthenticated) return null;

  final repo = ref.watch(compteRepositoryProvider);
  return await repo.getCompte();
});
