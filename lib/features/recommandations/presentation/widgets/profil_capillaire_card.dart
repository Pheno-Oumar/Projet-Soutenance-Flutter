import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/profil_capillaire_model.dart';

class ProfilCapillaireCard extends StatelessWidget {
  final ProfilCapillaireModel? profil;
  final VoidCallback onEditTap;

  const ProfilCapillaireCard({
    super.key,
    required this.profil,
    required this.onEditTap,
  });

  String _formatEnum(String? val) {
    if (val == null || val.isEmpty) return '';
    switch (val.toUpperCase()) {
      case 'CREPUS':
        return 'Crépus';
      case 'FRISES':
        return 'Frisés';
      case 'BOUCLES':
        return 'Bouclés';
      case 'ONDULES':
        return 'Ondulés';
      case 'LISSES':
        return 'Lisses';
      case 'FAIBLE':
        return 'Faible porosité';
      case 'MOYENNE':
        return 'Porosité moyenne';
      case 'FORTE':
        return 'Forte porosité';
      case 'FINS':
        return 'Fins';
      case 'MOYENS':
        return 'Moyens';
      case 'EPAIS':
        return 'Épais';
      case 'COURTS':
        return 'Courts';
      case 'MI_LONGS':
        return 'Mi-longs';
      case 'LONGS':
        return 'Longs';
      case 'SEC':
        return 'Cuir sec';
      case 'GRAS':
        return 'Cuir gras';
      case 'NORMAL':
        return 'Cuir normal';
      case 'SENSIBLE':
        return 'Sensible';
      case 'PELLICULES':
        return 'Pellicules';
      default:
        return val;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = profil;

    final typeStr = _formatEnum(p?.typeCheveux);
    final porositeStr = _formatEnum(p?.porosite);
    final cuirStr = _formatEnum(p?.cuirChevelu);
    final textureStr = _formatEnum(p?.texture);

    final summaryParts = [typeStr, porositeStr, cuirStr, textureStr]
        .where((s) => s.isNotEmpty)
        .toList();

    final summaryText = summaryParts.isNotEmpty
        ? summaryParts.join(' • ')
        : 'Diagnostic capillaire non renseigné';

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil Capillaire',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summaryText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF221814),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onEditTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              foregroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
              backgroundColor: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                  .withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Modifier',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
