import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../rendezvous/data/rendezvous_mock_data.dart';

class ReclamationSalonSelector extends StatelessWidget {
  final SalonItem? selectedSalon;
  final List<SalonItem> salons;
  final int totalReclamations;
  final ValueChanged<String?> onSalonSelected;

  const ReclamationSalonSelector({
    super.key,
    required this.selectedSalon,
    required this.salons,
    required this.totalReclamations,
    required this.onSalonSelected,
  });

  void _showSalonPicker(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                Text(
                  'Sélectionnez un salon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: sheetDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Filtrez vos réclamations par salon',
                  style: TextStyle(
                    fontSize: 13,
                    color: sheetDark ? AppColors.darkTextSecondary : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),

                // Option: Tous les salons
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selectedSalon == null
                          ? AppColors.figmaActiveGold
                          : (sheetDark ? AppColors.darkBorder : Colors.grey.shade200),
                      width: selectedSalon == null ? 1.5 : 1.0,
                    ),
                  ),
                  tileColor: selectedSalon == null
                      ? (sheetDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F4EE))
                      : Colors.transparent,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sheetDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.figmaBrown.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.storefront_rounded,
                      color: sheetDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Tous les salons',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: sheetDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                    ),
                  ),
                  subtitle: Text(
                    '$totalReclamations réclamation${totalReclamations > 1 ? 's' : ''} au total',
                    style: TextStyle(
                      color: sheetDark ? AppColors.darkTextSecondary : Colors.grey[600],
                    ),
                  ),
                  trailing: selectedSalon == null
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.figmaActiveGold)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    onSalonSelected(null);
                  },
                ),

                const SizedBox(height: 8),

                // Salons individuels
                ...salons.map((salon) {
                  final isSelected = selectedSalon?.slug == salon.slug;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.figmaActiveGold
                              : (sheetDark ? AppColors.darkBorder : Colors.grey.shade200),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      tileColor: isSelected
                          ? (sheetDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F4EE))
                          : Colors.transparent,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: sheetDark ? AppColors.darkBorder : Colors.grey.shade300,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            salon.logo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.figmaBrown,
                              alignment: Alignment.center,
                              child: Text(
                                salon.nom.isNotEmpty ? salon.nom[0] : 'S',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        salon.nom,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: sheetDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                        ),
                      ),
                      subtitle: Text(
                        salon.adresse,
                        style: TextStyle(
                          fontSize: 12,
                          color: sheetDark ? AppColors.darkTextSecondary : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.figmaActiveGold)
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        onSalonSelected(salon.slug);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = selectedSalon?.nom ?? 'Tous les salons';
    final subtitle = selectedSalon?.adresse ?? 'Afficher toutes vos réclamations';
    final logoPath = selectedSalon?.logo ?? 'assets/images/rdv_tous_0.png';

    return GestureDetector(
      onTap: () => _showSalonPicker(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF6EFE7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFD8A868),
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
        child: Row(
          children: [
            // Logo circulaire du salon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: selectedSalon != null
                    ? Image.asset(
                        logoPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/images/detail_img_1.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.figmaBrown,
                            alignment: Alignment.center,
                            child: Text(
                              title.isNotEmpty ? title[0] : 'S',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.figmaActiveGold,
                          size: 22,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Nom + adresse
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2E1C15),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        selectedSalon != null
                            ? Icons.location_on_rounded
                            : Icons.filter_list_rounded,
                        size: 13,
                        color: isDark ? AppColors.figmaActiveGold : Colors.grey[700],
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron droite
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.figmaActiveGold : const Color(0xFF8D6E63),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
