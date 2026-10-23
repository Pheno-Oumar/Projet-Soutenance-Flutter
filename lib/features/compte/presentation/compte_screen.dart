import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routing/route_names.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../notification/presentation/providers/notification_provider.dart';
import 'providers/compte_provider.dart';

class CompteScreen extends ConsumerWidget {
  const CompteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Si non connecté, afficher la vue d'accueil invité
    if (!authState.isAuthenticated) {
      return _buildGuestView(context, isDark);
    }

    final profileAsync = ref.watch(clientProfileProvider);
    final profile = profileAsync.valueOrNull;
    final unreadNotifs = ref.watch(unreadNotificationCountProvider);

    final userName = (profile != null && profile.prenom.isNotEmpty)
        ? '${profile.prenom} ${profile.nom}'
        : (authState.user?.prenom != null && authState.user!.prenom!.isNotEmpty
            ? '${authState.user!.prenom} ${authState.user?.nom ?? ''}'
            : 'Client Mon Salon');

    final userEmail = profile?.email ?? authState.user?.email ?? 'Non renseigné';
    final userPhone = profile?.telephone ?? authState.user?.telephone ?? '';

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
        'icon': Icons.star_outline_rounded,
        'action': () => _showAvisModal(context, ref),
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

    final avatarSize = context.responsiveValue(compact: 74.0, standard: 82.0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 16,
          bottom: context.responsiveValue(compact: 70.0, standard: 80.0),
        ),
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
                      width: avatarSize,
                      height: avatarSize,
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
                            child: Text(
                              'AD',
                              style: TextStyle(
                                color: AppColors.figmaActiveGold,
                                fontSize: context.fontSize(24),
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
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontSize: context.fontSize(18),
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : Colors.black,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: context.fontSize(13),
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
                          fontSize: context.fontSize(13),
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                                  fontSize: context.fontSize(14.5),
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
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.fontSize(11),
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
                  border: context.symmetricBorder(
                    borderColor: isDark ? const Color(0xFFD32F2F).withValues(alpha: 0.7) : AppColors.figmaBrown,
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Se déconnecter',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFEF5350) : AppColors.figmaBrown,
                          fontSize: context.fontSize(14.5),
                          fontWeight: FontWeight.w700,
                        ),
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

  Widget _buildGuestView(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFDFBF9),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: context.responsiveValue(compact: 20.0, standard: 30.0),
        ),
        child: Column(
          children: [
            // Avatar décoratif
            Container(
              width: context.responsiveValue(compact: 76.0, standard: 88.0),
              height: context.responsiveValue(compact: 76.0, standard: 88.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF6EFE7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.figmaActiveGold,
                  width: 2.0,
                ),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: context.responsiveValue(compact: 42.0, standard: 48.0),
                color: AppColors.figmaActiveGold,
              ),
            ),
            const SizedBox(height: 16),

            // Titre & description
            Text(
              'Bienvenue sur Mon Salon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.fontSize(20),
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connectez-vous pour retrouver vos réservations de rendez-vous, vos commandes Click & Collect et synchroniser vos favoris.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.fontSize(13.5),
                color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Bouton Principal "Se connecter"
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => context.push(RouteNames.login),
                icon: const Icon(Icons.login_rounded, size: 19),
                label: Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: context.fontSize(15),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.figmaBrown,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bouton Secondaire "Créer un compte"
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.push(RouteNames.register),
                icon: const Icon(Icons.person_add_outlined, size: 19),
                label: Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: context.fontSize(15),
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.figmaBrown,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Section raccourcis accessibles en mode invité
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: context.symmetricBorder(),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.favorite_border_rounded, color: AppColors.figmaActiveGold, size: 22),
                    title: Text(
                      'Mes favoris',
                      style: TextStyle(
                        fontSize: context.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                      ),
                    ),
                    subtitle: Text(
                      'Sauvegardés sur cet appareil',
                      style: TextStyle(
                        fontSize: context.fontSize(12),
                        color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => context.push(RouteNames.mesFavoris),
                  ),
                  Divider(
                    height: 1,
                    indent: 52,
                    color: isDark ? AppColors.darkDivider : const Color(0xFFF0EAE1),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings_outlined,
                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      size: 22,
                    ),
                    title: Text(
                      'Paramètres de l\'application',
                      style: TextStyle(
                        fontSize: context.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => context.push(RouteNames.parametres),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvisModal(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: context.heightPercent(0.65, min: 380.0, max: 560.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mes avis & Évaluations',
                      style: TextStyle(
                        fontSize: context.fontSize(16),
                        fontWeight: FontWeight.w800,
                        color: context.adaptiveTextColor(),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: context.adaptiveSubtextColor(),
                    ),
                  ],
                ),
              ),
              Divider(
                color: isDark ? AppColors.darkBorder : AppColors.figmaCardBorder,
                thickness: 0.8,
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.rate_review_outlined,
                          color: AppColors.figmaActiveGold,
                          size: 48,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Aucun avis publié pour l\'instant',
                          style: TextStyle(
                            fontSize: context.fontSize(15),
                            fontWeight: FontWeight.w800,
                            color: context.adaptiveTextColor(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Après avoir réalisé un rendez-vous dans un salon partenaire ou commandé un produit, vous pourrez déposer vos notes et commentaires certifiés ici.',
                          style: TextStyle(
                            fontSize: context.fontSize(12.5),
                            color: context.adaptiveSubtextColor(),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            context.push(RouteNames.salons);
                          },
                          icon: const Icon(Icons.search_rounded, size: 16),
                          label: const Text('Explorer les salons'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.figmaBrown,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

