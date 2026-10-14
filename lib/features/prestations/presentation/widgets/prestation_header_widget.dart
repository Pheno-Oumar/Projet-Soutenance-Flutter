import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/prestation_model.dart';

class PrestationHeaderWidget extends StatelessWidget {
  final PrestationModel prestation;
  final VoidCallback onBackPressed;

  const PrestationHeaderWidget({
    super.key,
    required this.prestation,
    required this.onBackPressed,
  });

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    if (prestation.isTerminee) {
      bgColor = const Color(0xFF164E2E);
      textColor = Colors.white;
      label = '★ Terminée';
    } else if (prestation.isAnnulee) {
      bgColor = const Color(0xFFD32F2F);
      textColor = Colors.white;
      label = 'Annulée';
    } else {
      bgColor = const Color(0xFF757575);
      textColor = Colors.white;
      label = prestation.statutLabel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coverPath = prestation.salonCover;
    final logoPath = prestation.salonLogo;
    final salonName = prestation.salonNom;
    final location = prestation.salonAdresse;
    final dateStr = prestation.dateHeureDebut;

    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Image de couverture du salon
          Image.asset(
            coverPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Image.asset(
              'assets/images/detail_img_0.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF382319),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),

          // 2. Dégradé sombre pour la lisibilité
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // 3. Bouton Retour en haut
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bouton retour circulaire
                    GestureDetector(
                      onTap: onBackPressed,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.figmaBrown.withValues(alpha: 0.9),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    // Titre au centre de la barre
                    const Text(
                      'Détails de la prestation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    // Placeholder pour l'équilibre visuel
                    const SizedBox(width: 38),
                  ],
                ),
              ),
            ),
          ),

          // 4. Bloc d'informations au bas du cover (Logo, Nom, Adresse, Date et Statut)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Logo circulaire avec bordure blanche
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      logoPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset(
                        'assets/images/detail_img_1.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFF2E1C15),
                          alignment: Alignment.center,
                          child: Text(
                            salonName.isNotEmpty ? salonName[0] : 'S',
                            style: const TextStyle(
                              color: AppColors.figmaActiveGold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Nom du salon + Localisation + Date & Heure
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        salonName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white70,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Statut de la prestation
                _buildStatusBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
