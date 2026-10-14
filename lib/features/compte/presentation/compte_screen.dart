import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../notification/presentation/providers/notification_provider.dart';
import 'providers/compte_provider.dart';

class CompteScreen extends ConsumerWidget {
  const CompteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(clientProfileProvider);
    final profile = profileAsync.valueOrNull;
    final unreadNotifs = ref.watch(unreadNotificationCountProvider);

    final userName = (profile != null && profile.prenom.isNotEmpty)
        ? '${profile.prenom} ${profile.nom}'
        : 'Aïcha Diallo';
    final userEmail = profile?.email ?? 'aicha.diallo@gmail.com';
    final userPhone = profile?.telephone ?? '+221 77 123 45 67';

    final menuItems = [
      {
        'title': 'Modifier mon profil',
        'icon': Icons.edit_outlined,
        'action': () => context.push(RouteNames.modifierProfil),
      },
      {
        'title': 'Mes favoris',
        'icon': Icons.favorite_border_rounded,
        'action': () => context.push(RouteNames.mesFavoris),
      },
      {
        'title': 'Mes commandes',
        'icon': Icons.shopping_cart_outlined,
        'action': () => context.push(RouteNames.mesCommandes),
      },
      {
        'title': 'Mes rendez-vous',
        'icon': Icons.calendar_month_outlined,
        'action': () => context.push(RouteNames.mesRendezVous),
      },
      {
        'title': 'Mes prestations',
        'icon': Icons.content_cut_rounded, // Icône ajustée
        'action': () => context.push(RouteNames.mesPrestations),
      },
      {
        'title': 'Mes avis',
        'icon': Icons.star_outline_rounded, // Icône ajustée
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vos avis et évaluations'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      },
      {
        'title': 'Mes réclamations',
        'icon': Icons.report_problem_outlined,
        'action': () => context.push(RouteNames.mesReclamations),
      },
      {
        'title': 'Mes recommandations',
        'icon': Icons.auto_awesome_rounded,
        'action': () => context.push(RouteNames.mesRecommandations),
      },
      // NOTIFICATIONS AVEC BADGE
      {
        'title': 'Notifications',
        'icon': Icons.notifications_none_rounded,
        'badge': unreadNotifs,
        'action': () => context.push(RouteNames.notifications),
      },
      {
        'title': 'Paramètres',
        'icon': Icons.settings_outlined,
        'action': () => context.push(RouteNames.parametres),
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: [
            // ==============================================================
            // 1. EN-TÊTE PROFIL UTILISATEUR (Avatar + Caméra + Nom + Contacts)
            // ==============================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar circulaire avec bouton caméra
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE5DCD3),
                          width: 2.0,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/compte_img_1.jpeg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFF2E1C15),
                            alignment: Alignment.center,
                            child: const Text(
                              'AD',
                              style: TextStyle(
                                color: AppColors.figmaActiveGold,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bouton caméra blanc avec icône appareil photo
                    GestureDetector(
                      onTap: () => context.push(RouteNames.modifierProfil),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.figmaActiveGold : const Color(0xFF382319),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 14,
                          color: isDark ? AppColors.figmaActiveGold : const Color(0xFF382319),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 18),

                // Informations textuelles (Nom, Email, Téléphone)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userPhone,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ==============================================================
            // 2. LISTE DU MENU (100% Column / Row / Container selon Figma)
            // ==============================================================
            Column(
              children: menuItems.map((item) {
                return Column(
                  children: [
                    InkWell(
                      onTap: item['action'] as VoidCallback,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            // Icône du menu (Ajustée selon la maquette)
                            Icon(
                              item['icon'] as IconData,
                              size: 22,
                              color: isDark ? AppColors.figmaActiveGold : const Color(0xFF382319),
                            ),
                            const SizedBox(width: 16),

                            // Libellé
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                                ),
                              ),
                            ),

                            // Badge de notification non lue
                            if (item['badge'] != null && (item['badge'] as int) > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD32F2F),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${item['badge']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],

                            // Chevron flèche droite
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Trait séparateur fin
                    Container(
                      height: 0.8,
                      margin: const EdgeInsets.only(left: 38),
                      color: isDark ? AppColors.darkDivider : const Color(0xFFF0EBE5),
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ==============================================================
            // 3. BOUTON SE DÉCONNECTER (Bordure marron arrondie selon Figma)
            // ==============================================================
            InkWell(
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vous avez été déconnecté'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFFD32F2F).withValues(alpha: 0.7) : AppColors.figmaBrown,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: isDark ? const Color(0xFFEF5350) : AppColors.figmaBrown,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Se déconnecter',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFEF5350) : AppColors.figmaBrown,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
