import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../data/models/notification_model.dart';
import 'providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _showNotificationDetailModal(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notif,
  ) {
    // Marquer comme lu à l'ouverture du détail
    if (!notif.lu) {
      ref.read(notificationListProvider.notifier).marquerLu(notif.id);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final sheetDark = Theme.of(ctx).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sheetDark ? AppColors.darkBorder : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // En-tête de la notification
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: sheetDark ? AppColors.darkSurfaceVariant : const Color(0xFFF6EFE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: sheetDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif.titre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: sheetDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.dateCreation ?? 'Récemment',
                            style: TextStyle(
                              fontSize: 12,
                              color: sheetDark ? AppColors.darkTextMuted : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Corps du message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sheetDark ? AppColors.darkSurfaceVariant : const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sheetDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
                    ),
                  ),
                  child: Text(
                    notif.contenu,
                    style: TextStyle(
                      fontSize: 14,
                      color: sheetDark ? AppColors.darkTextPrimary : const Color(0xFF2E1C15),
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton d'action selon le type de notification
                if (notif.type == 'RENDEZ_VOUS') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(RouteNames.mesRendezVous);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sheetDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        foregroundColor: sheetDark ? const Color(0xFF1E1610) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Voir mes rendez-vous',
                        style: TextStyle(
                          color: sheetDark ? const Color(0xFF1E1610) : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else if (notif.type == 'RECLAMATION') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(RouteNames.mesReclamations);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sheetDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        foregroundColor: sheetDark ? const Color(0xFF1E1610) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Voir mes réclamations',
                        style: TextStyle(
                          color: sheetDark ? const Color(0xFF1E1610) : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Bouton Fermer
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: sheetDark ? AppColors.darkBorder : const Color(0xFFE5DCD3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Fermer',
                      style: TextStyle(
                        color: sheetDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabPill({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
        : (isDark ? AppColors.darkSurface : const Color(0xFFF5EEE6));
    final textColor = isSelected
        ? (isDark ? const Color(0xFF1E1610) : Colors.white)
        : (isDark ? AppColors.darkTextSecondary : AppColors.figmaBrown);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: (!isSelected && isDark) ? Border.all(color: AppColors.darkBorder) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                        .withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required WidgetRef ref,
    required NotificationModel notif,
    required bool isDark,
  }) {
    final notifier = ref.read(notificationListProvider.notifier);

    return Dismissible(
      key: ValueKey('notif-${notif.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => notifier.supprimer(notif.id),
      child: GestureDetector(
        onTap: () => _showNotificationDetailModal(context, ref, notif),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Icône calendrier / cloche selon Figma
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF6EFE7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                ),
              ),
              const SizedBox(width: 12),

              // 2. Contenu textuel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      notif.titre,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Corps du texte
                    Text(
                      notif.contenu,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Date & catégorie
                    Text(
                      notif.dateCreation ?? 'Aujourd\'hui',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.darkTextMuted : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Pastille rouge pour non lu
              if (!notif.lu)
                Container(
                  margin: const EdgeInsets.only(top: 4, left: 6),
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationListProvider);
    final notifier = ref.read(notificationListProvider.notifier);
    final listeFiltree = state.notificationsFiltrees;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tout marquer comme lu',
            icon: const Icon(
              Icons.done_all_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              notifier.toutMarquerLu();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les notifications ont été marquées comme lues'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Onglets de filtrage (Toutes(4) et Non lues(1)) selon Figma
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildTabPill(
                  label: 'Toutes(${state.totalCount})',
                  isSelected: state.selectedTab == 'TOUTES',
                  isDark: isDark,
                  onTap: () => notifier.changerTab('TOUTES'),
                ),
                const SizedBox(width: 10),
                _buildTabPill(
                  label: 'Non lues (${state.unreadCount})',
                  isSelected: state.selectedTab == 'NON_LUES',
                  isDark: isDark,
                  onTap: () => notifier.changerTab('NON_LUES'),
                ),
              ],
            ),
          ),

          // 2. Liste des notifications
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => notifier.chargerNotifications(),
              child: listeFiltree.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF6EFE7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.notifications_none_rounded,
                                      size: 32,
                                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.selectedTab == 'NON_LUES'
                                        ? 'Aucune notification non lue'
                                        : 'Aucune notification reçue pour l\'instant',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Vos alertes de rendez-vous et commandes apparaîtront ici.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: listeFiltree.length,
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        final notif = listeFiltree[index];
                        return _buildNotificationCard(
                          context: context,
                          ref: ref,
                          notif: notif,
                          isDark: isDark,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
