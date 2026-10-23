import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../routing/route_names.dart';
import '../../data/models/coiffeur_salon_model.dart';
import '../providers/salon_provider.dart';

class SalonCoiffeursTab extends ConsumerWidget {
  final String slugSalon;
  final String salonNom;

  const SalonCoiffeursTab({
    super.key,
    this.slugSalon = 'beauty-by-dika',
    this.salonNom = 'Beauty By Dika',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coiffeursAsync = ref.watch(salonCoiffeursProvider(slugSalon));

    return coiffeursAsync.when(
      loading: () => _buildLoadingList(context, isDark),
      error: (_, _) => _buildEmptyState(context, isDark),
      data: (coiffeurs) {
        if (coiffeurs.isEmpty) {
          return _buildEmptyState(context, isDark);
        }

        return Column(
          children: coiffeurs.map((c) => _buildCoiffeurCard(context, isDark, c)).toList(),
        );
      },
    );
  }

  Widget _buildCoiffeurCard(
    BuildContext context,
    bool isDark,
    CoiffeurSalonModel c,
  ) {
    final photo = c.photoProfilUrl;
    final isNetwork = photo != null && photo.startsWith('http');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: context.symmetricBorder(),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo du coiffeur avec badge de disponibilité
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: isNetwork
                        ? Image.network(
                            photo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildAvatarPlaceholder(c.displayName),
                          )
                        : Image.asset(
                            photo != null && photo.isNotEmpty
                                ? photo
                                : 'assets/images/realisation_img_5.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildAvatarPlaceholder(c.displayName),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.available ? const Color(0xFF2E7D32) : Colors.black38,
                      border: Border.all(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Informations du coiffeur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          c.displayName,
                          style: TextStyle(
                            fontSize: context.fontSize(14.5),
                            fontWeight: FontWeight.w800,
                            color: context.adaptiveTextColor(),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.figmaInputBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.figmaActiveGold,
                              size: 13,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: context.fontSize(10),
                                fontWeight: FontWeight.w700,
                                color: context.adaptiveTextColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.biographie != null && c.biographie!.isNotEmpty
                        ? c.biographie!
                        : '${c.anneeExperience} ans d\'expérience',
                    style: TextStyle(
                      fontSize: context.fontSize(11.5),
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.description != null && c.description!.isNotEmpty
                        ? c.description!
                        : 'Expert coiffure & soins capillaires professionnels',
                    style: TextStyle(
                      fontSize: context.fontSize(11),
                      color: context.adaptiveSubtextColor(),
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Bouton de réservation avec ce salon
                  InkWell(
                    onTap: () {
                      context.push(RouteNames.panierRendezVous);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Prendre rendez-vous',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.fontSize(11),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: context.symmetricBorder(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.figmaActiveGold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: AppColors.figmaActiveGold,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Aucun coiffeur répertorié',
            style: TextStyle(
              fontSize: context.fontSize(15),
              fontWeight: FontWeight.w800,
              color: context.adaptiveTextColor(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'L\'équipe des coiffeurs de ce salon sera affichée ici dès sa publication.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.fontSize(12.5),
              color: context.adaptiveSubtextColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      width: 72,
      height: 72,
      color: const Color(0xFF2E1C15),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white70,
        size: 32,
      ),
    );
  }

  Widget _buildLoadingList(BuildContext context, bool isDark) {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }),
    );
  }
}
