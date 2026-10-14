import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SalonAproposTab extends StatefulWidget {
  final String description;
  final String phone;

  const SalonAproposTab({
    super.key,
    this.description =
        'Beauty By Dika est un espace moderne et chaleureux, spécialisé dans la coiffure pour femmes et hommes. Notre équipe de professionnels vous offre des prestations de qualité dans un cadre agréable, pour sublimer votre style.',
    this.phone = '+223 78 99 00 55',
  });

  @override
  State<SalonAproposTab> createState() => _SalonAproposTabState();
}

class _SalonAproposTabState extends State<SalonAproposTab> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Description du salon
        Text(
          widget.description,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4A4A4A),
            fontSize: 13,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
          maxLines: _isDescriptionExpanded ? null : 4,
          overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () {
            setState(() {
              _isDescriptionExpanded = !_isDescriptionExpanded;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isDescriptionExpanded ? 'Voir moins' : 'Voir plus',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isDescriptionExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isDark ? AppColors.darkTextPrimary : Colors.black87,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Carte Contact & Itinéraire (Figma Details salons.svg)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
              width: 1.0,
            ),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Colonne Téléphone & Bouton Itinéraire
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          color: AppColors.figmaBrown,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.phone,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Ouverture de l'itinéraire vers Kalaban..."),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.near_me_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Itinéraire',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Aperçu de la carte avec épingle rouge 📍
              Container(
                width: 110,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFEAEFF5),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFDCE2EB),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Quadrillage stylisé représentant la carte
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          color: isDark ? const Color(0xFF221C18) : const Color(0xFFE8F0F8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(height: 1, color: isDark ? Colors.white12 : Colors.white),
                              Container(height: 1, color: isDark ? Colors.white12 : Colors.white),
                              Container(height: 1, color: isDark ? Colors.white12 : Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Épingle rouge de géolocalisation
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFE53935),
                      size: 26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // ==============================================================
        // 3. SECTION COMPLÈTE DES AVIS SUR LE SALON (Demandée par l'utilisateur)
        // ==============================================================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Avis clients & Évaluations',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : Colors.black,
              ),
            ),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Affichage des 124 avis du salon'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text(
                'Voir tout (124)',
                style: TextStyle(
                  color: AppColors.figmaActiveGold,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Carte récapitulative de la note globale
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
            ),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.figmaActiveGold, size: 16),
                      Icon(Icons.star_rounded, color: AppColors.figmaActiveGold, size: 16),
                      Icon(Icons.star_rounded, color: AppColors.figmaActiveGold, size: 16),
                      Icon(Icons.star_rounded, color: AppColors.figmaActiveGold, size: 16),
                      Icon(Icons.star_half_rounded, color: AppColors.figmaActiveGold, size: 16),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '124 avis vérifiés',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(star: '5★', ratio: 0.82),
                    _buildRatingBar(star: '4★', ratio: 0.12),
                    _buildRatingBar(star: '3★', ratio: 0.04),
                    _buildRatingBar(star: '2★', ratio: 0.01),
                    _buildRatingBar(star: '1★', ratio: 0.01),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Liste des personnes qui ont laissé un avis
        _buildReviewCard(
          author: 'Aminata Coulibaly',
          date: 'Il y a 3 jours',
          rating: 5,
          prestation: 'Prestation : Box Braids & Perles',
          comment:
              'Service absolument impeccable ! Les coiffeuses sont très douces et à l\'écoute. Le salon est ultra propre et moderne. Je recommande à 100% !',
          initials: 'AC',
          bgColor: const Color(0xFF382319),
        ),
        const SizedBox(height: 12),
        _buildReviewCard(
          author: 'Bintou Traoré',
          date: 'Il y a 1 semaine',
          rating: 5,
          prestation: 'Prestation : Soin Kératine Intense',
          comment:
              'Mes cheveux ont retrouvé toute leur brillance et douceur. Accueil très chaleureux avec le sourire. C\'est devenu mon salon de référence à Bamako !',
          initials: 'BT',
          bgColor: const Color(0xFF232D3F),
        ),
        const SizedBox(height: 12),
        _buildReviewCard(
          author: 'Oumar Diarra',
          date: 'Il y a 2 semaines',
          rating: 4,
          prestation: 'Prestation : Coupe Dégradé & Barbe',
          comment:
              'Très bon barbier, finitions nettes et rapides. Prix très corrects pour le quartier. Je valide !',
          initials: 'OD',
          bgColor: const Color(0xFF2C3E2D),
        ),
        const SizedBox(height: 12),
        _buildReviewCard(
          author: 'Kadidiatou Sanogo',
          date: 'Il y a 3 semaines',
          rating: 5,
          prestation: 'Prestation : Tissage Ouvert Ondulé',
          comment:
              'La pose est totalement invisible et tient parfaitement. Toujours satisfaite du résultat.',
          initials: 'KS',
          bgColor: const Color(0xFF3B1E2B),
        ),
      ],
    );
  }

  Widget _buildRatingBar({required String star, required double ratio}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          Text(
            star,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.darkTextSecondary : Colors.black54,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE5DDD5),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.figmaActiveGold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String author,
    required String date,
    required int rating,
    required String prestation,
    required String comment,
    required String initials,
    required Color bgColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DF),
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : Colors.black,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < rating
                        ? AppColors.figmaActiveGold
                        : (isDark ? Colors.white24 : const Color(0xFFD4D4D4)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            prestation,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextPrimary : Colors.black87,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
