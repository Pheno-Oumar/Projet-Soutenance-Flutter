import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class ParametresScreen extends ConsumerStatefulWidget {
  const ParametresScreen({super.key});

  @override
  ConsumerState<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends ConsumerState<ParametresScreen> {
  String _selectedLangue = 'Français';
  String _selectedVille = 'Bamako, Mali';

  void _showThemePicker(BuildContext context) {
    final currentMode = ref.read(themeModeProvider);
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
                  'Thème de l\'application',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: sheetDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choisissez votre mode d\'affichage',
                  style: TextStyle(
                    fontSize: 13,
                    color: sheetDark ? AppColors.darkTextSecondary : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                _buildRadioTile<ThemeMode>(
                  ctx: ctx,
                  isDark: sheetDark,
                  title: 'Thème Clair',
                  subtitle: 'Affichage lumineux standard',
                  icon: Icons.light_mode_rounded,
                  value: ThemeMode.light,
                  groupValue: currentMode,
                  onChanged: (mode) {
                    ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    Navigator.pop(ctx);
                  },
                ),
                _buildRadioTile<ThemeMode>(
                  ctx: ctx,
                  isDark: sheetDark,
                  title: 'Thème Sombre',
                  subtitle: 'Idéal pour réduire la fatigue visuelle',
                  icon: Icons.dark_mode_rounded,
                  value: ThemeMode.dark,
                  groupValue: currentMode,
                  onChanged: (mode) {
                    ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    Navigator.pop(ctx);
                  },
                ),
                _buildRadioTile<ThemeMode>(
                  ctx: ctx,
                  isDark: sheetDark,
                  title: 'Système',
                  subtitle: 'S\'adapte aux préférences de votre appareil',
                  icon: Icons.brightness_auto_rounded,
                  value: ThemeMode.system,
                  groupValue: currentMode,
                  onChanged: (mode) {
                    ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguePicker(BuildContext context) {
    final langues = ['Français', 'Wolof', 'Bambara', 'English'];
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
                  'Langue de l\'application',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: sheetDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                  ),
                ),
                const SizedBox(height: 16),
                ...langues.map((l) {
                  final isSelected = _selectedLangue == l;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
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
                      title: Text(
                        l,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: sheetDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.figmaActiveGold)
                          : null,
                      onTap: () {
                        setState(() => _selectedLangue = l);
                        Navigator.pop(ctx);
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

  void _showLocalisationPicker(BuildContext context) {
    final villes = ['Bamako, Mali', 'Dakar, Sénégal', 'Abidjan, Côte d\'Ivoire', 'Conakry, Guinée'];
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
                  'Localisation principale',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: sheetDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                  ),
                ),
                const SizedBox(height: 16),
                ...villes.map((v) {
                  final isSelected = _selectedVille == v;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
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
                      leading: Icon(
                        Icons.location_on_rounded,
                        color: sheetDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                        size: 20,
                      ),
                      title: Text(
                        v,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: sheetDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.figmaActiveGold)
                          : null,
                      onTap: () {
                        setState(() => _selectedVille = v);
                        Navigator.pop(ctx);
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

  void _showAideModal(BuildContext context) {
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
                Text(
                  'Aide & Assistance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: sheetDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: sheetDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  ),
                  title: Text(
                    'Support WhatsApp',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: sheetDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                    ),
                  ),
                  subtitle: Text(
                    '+221 77 000 00 00 • Disponible 7j/7',
                    style: TextStyle(
                      color: sheetDark ? AppColors.darkTextSecondary : Colors.grey[600],
                    ),
                  ),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: Icon(
                    Icons.mail_outline_rounded,
                    color: sheetDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  ),
                  title: Text(
                    'Email assistance',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: sheetDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                    ),
                  ),
                  subtitle: Text(
                    'support@mon-salon.com',
                    style: TextStyle(
                      color: sheetDark ? AppColors.darkTextSecondary : Colors.grey[600],
                    ),
                  ),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: Icon(
                    Icons.help_center_outlined,
                    color: sheetDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  ),
                  title: Text(
                    'Foire aux questions (FAQ)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: sheetDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                    ),
                  ),
                  subtitle: Text(
                    'Consulter les réponses fréquentes',
                    style: TextStyle(
                      color: sheetDark ? AppColors.darkTextSecondary : Colors.grey[600],
                    ),
                  ),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAproposModal(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: sheetDark ? AppColors.darkSurfaceVariant : AppColors.figmaBrown,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.content_cut_rounded,
                    color: AppColors.figmaActiveGold,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Mon Salon - Hair Style',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: sheetDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0 (Build 2025.1)',
                  style: TextStyle(
                    fontSize: 13,
                    color: sheetDark ? AppColors.darkTextMuted : Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'La plateforme tout-en-un dédiée à la beauté et à la coiffure afro & moderne. Réservation en salon, suivi de vos prestations et commandes Click & Collect.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: sheetDark ? AppColors.darkTextSecondary : Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sheetDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                      foregroundColor: sheetDark ? const Color(0xFF1E1610) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Fermer',
                      style: TextStyle(
                        color: sheetDark ? const Color(0xFF1E1610) : Colors.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildRadioTile<T>({
    required BuildContext ctx,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required T value,
    required T groupValue,
    required ValueChanged<T> onChanged,
  }) {
    final isSelected = value == groupValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? AppColors.figmaActiveGold
                : (isDark ? AppColors.darkBorder : Colors.grey.shade200),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        tileColor: isSelected
            ? (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F4EE))
            : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected
              ? AppColors.figmaActiveGold
              : (isDark ? AppColors.darkTextMuted : Colors.grey[700]),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.figmaActiveGold)
            : null,
        onTap: () => onChanged(value),
      ),
    );
  }

  Widget _buildParamItem({
    required bool isDark,
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Icône élégante stylisée avec container doux
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF6EFE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 19,
                    color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  ),
                ),
                const SizedBox(width: 14),

                // Titre
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                    ),
                  ),
                ),

                // Valeur optionnelle
                if (value != null) ...[
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // Chevron droite
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF9E9E9E),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 0.8,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: isDark ? AppColors.darkDivider : const Color(0xFFF0EAE1),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeLabel = switch (themeMode) {
      ThemeMode.dark => 'Sombre',
      ThemeMode.light => 'Clair',
      ThemeMode.system => 'Système',
    };
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFDFBF9),
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
          'Paramètres',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SECTION PRÉFÉRENCES
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Préférences',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
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
              child: Column(
                children: [
                  _buildParamItem(
                    isDark: isDark,
                    icon: Icons.language_rounded,
                    title: 'Langue',
                    value: _selectedLangue,
                    onTap: () => _showLanguePicker(context),
                  ),
                  _buildParamItem(
                    isDark: isDark,
                    icon: isDark ? Icons.dark_mode_rounded : Icons.dark_mode_outlined,
                    title: 'Thème',
                    value: themeLabel,
                    onTap: () => _showThemePicker(context),
                  ),
                  _buildParamItem(
                    isDark: isDark,
                    icon: Icons.location_on_outlined,
                    title: 'Localisation',
                    value: _selectedVille,
                    showDivider: false,
                    onTap: () => _showLocalisationPicker(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. SECTION AUTRES
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Autres',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
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
              child: Column(
                children: [
                  _buildParamItem(
                    isDark: isDark,
                    icon: Icons.help_outline_rounded,
                    title: 'Aide & assistance',
                    onTap: () => _showAideModal(context),
                  ),
                  _buildParamItem(
                    isDark: isDark,
                    icon: Icons.info_outline_rounded,
                    title: 'À propos de l\'application',
                    showDivider: false,
                    onTap: () => _showAproposModal(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
