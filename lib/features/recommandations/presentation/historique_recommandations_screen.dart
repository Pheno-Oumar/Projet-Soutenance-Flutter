import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import 'providers/recommandation_provider.dart';

class HistoriqueRecommandationsScreen extends ConsumerWidget {
  const HistoriqueRecommandationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historiqueAsync = ref.watch(historiqueRecommandationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Historique des diagnostics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
            onPressed: () => ref.refresh(historiqueRecommandationsProvider),
          ),
        ],
      ),
      body: historiqueAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.figmaBrown),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Impossible de charger l\'historique',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E140C),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(historiqueRecommandationsProvider),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.figmaBrown),
                  child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        data: (liste) {
          if (liste.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 48,
                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun historique disponible',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E140C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vos routines et diagnostics capillaires précédents apparaîtront ici.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF7E7369),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            itemCount: liste.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final reco = liste[index];
              final dateStr = DateFormat('dd MMMM yyyy', 'fr_FR').format(reco.dateRecommandation);

              final profileParts = [
                reco.typeCheveux,
                reco.porosite,
                reco.cuirChevelu,
              ].where((s) => s != null && s.isNotEmpty).toList();

              final profileSummary = profileParts.isNotEmpty
                  ? profileParts.join(' • ')
                  : 'Diagnostic personnalisé';

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.push(
                      '/recommandations/${reco.id}',
                      extra: reco,
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFEAE2D8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF1E140C),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32).withValues(alpha: isDark ? 0.25 : 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${reco.scoreGlobal}% match',
                                      style: const TextStyle(
                                        color: Color(0xFF2E7D32),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profileSummary,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF7E7369),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Réf : ${reco.reference}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : const Color(0xFFA0968C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
