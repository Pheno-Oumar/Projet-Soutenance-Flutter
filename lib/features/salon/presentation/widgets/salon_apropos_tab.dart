import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/salon_provider.dart';

class SalonAproposTab extends ConsumerStatefulWidget {
  final String slugSalon;
  final String salonNom;

  const SalonAproposTab({
    super.key,
    this.slugSalon = 'beauty-by-dika',
    this.salonNom = 'Beauty By Dika',
  });

  @override
  ConsumerState<SalonAproposTab> createState() => _SalonAproposTabState();
}

class _SalonAproposTabState extends ConsumerState<SalonAproposTab> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slug = widget.slugSalon;

    final salonAsync = slug.isNotEmpty ? ref.watch(salonDetailProvider(slug)) : null;
    final horairesAsync = slug.isNotEmpty ? ref.watch(salonHorairesProvider(slug)) : null;
    final avisAsync = slug.isNotEmpty ? ref.watch(salonAvisProvider(slug)) : null;

    final salon = salonAsync?.value;
    final description = (salon?.description != null && salon!.description!.isNotEmpty)
        ? salon.description!
        : 'Bienvenue chez ${salon?.nom ?? widget.salonNom}. Découvrez nos prestations et réservez votre rendez-vous en ligne.';
    final phone = (salon?.telephone != null && salon!.telephone!.isNotEmpty)
        ? salon.telephone!
        : 'Non renseigné';
    final address = (salon?.adresse != null && salon!.adresse!.isNotEmpty)
        ? salon.adresse!
        : 'Adresse non renseignée';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Description du salon
        Text(
          description,
          style: TextStyle(
            color: context.adaptiveSubtextColor(),
            fontSize: context.fontSize(13),
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
                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                  fontSize: context.fontSize(12.5),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isDescriptionExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Carte Contact & Itinéraire
        Container(
          padding: const EdgeInsets.all(14),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              phone,
                              style: TextStyle(
                                fontSize: context.fontSize(13),
                                fontWeight: FontWeight.w700,
                                color: context.adaptiveTextColor(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_pin,
                          color: AppColors.figmaBrown,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: context.fontSize(11.5),
                              color: context.adaptiveSubtextColor(),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Itinéraire vers $address"),
                            duration: const Duration(seconds: 1),
                            backgroundColor: AppColors.figmaBrown,
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

              // Aperçu stylisé de la carte avec épingle
              Container(
                width: context.responsiveValue(compact: 95.0, standard: 110.0),
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFEAEFF5),
                  border: context.symmetricBorder(),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
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

        const SizedBox(height: 18),

        // 3. Horaires d'ouverture réels du salon
        _buildHorairesSection(context, isDark, horairesAsync),

        const SizedBox(height: 22),

        // 4. Section Avis & Évaluations réels
        _buildAvisSection(context, isDark, avisAsync, salon),
      ],
    );
  }

  Widget _buildHorairesSection(
    BuildContext context,
    bool isDark,
    AsyncValue? horairesAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: context.symmetricBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppColors.figmaActiveGold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Horaires d\'ouverture',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: context.adaptiveTextColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (horairesAsync != null && horairesAsync.hasValue && horairesAsync.value.isNotEmpty)
            ...horairesAsync.value.map((h) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      h.jourFrancais,
                      style: TextStyle(
                        fontSize: context.fontSize(12.5),
                        color: context.adaptiveTextColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: h.actif
                            ? (isDark ? const Color(0xFF1B3820) : const Color(0xFFE8F5E9))
                            : (isDark ? const Color(0xFF3E1E1E) : const Color(0xFFFFEBEE)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        h.plageHoraire,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: h.actif ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Horaires d\'ouverture non renseignés',
                style: TextStyle(
                  fontSize: context.fontSize(12.5),
                  color: context.adaptiveSubtextColor(),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvisSection(
    BuildContext context,
    bool isDark,
    AsyncValue? avisAsync,
    dynamic salon,
  ) {
    final List apiAvis = (avisAsync != null && avisAsync.hasValue) ? avisAsync.value : [];
    final count = apiAvis.length;

    double noteMoyenne = count > 0
        ? (apiAvis.fold<num>(0, (sum, a) => sum + a.note) / count)
        : (salon != null ? (salon.noteMoyenne as double) : 0.0);

    final double ratio5 = count > 0 ? apiAvis.where((a) => a.note == 5).length / count : 0.0;
    final double ratio4 = count > 0 ? apiAvis.where((a) => a.note == 4).length / count : 0.0;
    final double ratio3 = count > 0 ? apiAvis.where((a) => a.note == 3).length / count : 0.0;
    final double ratio2 = count > 0 ? apiAvis.where((a) => a.note == 2).length / count : 0.0;
    final double ratio1 = count > 0 ? apiAvis.where((a) => a.note == 1).length / count : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            Text(
              count > 0 ? '$count avis vérifié${count > 1 ? "s" : ""}' : '0 avis',
              style: const TextStyle(
                color: AppColors.figmaActiveGold,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
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
            border: context.symmetricBorder(),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    noteMoyenne > 0 ? noteMoyenne.toStringAsFixed(1) : '-',
                    style: TextStyle(
                      fontSize: context.fontSize(32),
                      fontWeight: FontWeight.w900,
                      color: context.adaptiveTextColor(),
                    ),
                  ),
                  Row(
                    children: [
                      for (int i = 0; i < 5; i++)
                        Icon(
                          i < noteMoyenne.floor()
                              ? Icons.star_rounded
                              : (i < noteMoyenne ? Icons.star_half_rounded : Icons.star_outline_rounded),
                          color: AppColors.figmaActiveGold,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    count > 0 ? '$count avis vérifié${count > 1 ? "s" : ""}' : 'Aucun avis vérifié',
                    style: TextStyle(
                      fontSize: context.fontSize(10.5),
                      color: context.adaptiveSubtextColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(star: '5★', ratio: ratio5),
                    _buildRatingBar(star: '4★', ratio: ratio4),
                    _buildRatingBar(star: '3★', ratio: ratio3),
                    _buildRatingBar(star: '2★', ratio: ratio2),
                    _buildRatingBar(star: '1★', ratio: ratio1),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Liste des avis réels
        if (count > 0)
          ...apiAvis.map((a) {
            final dateStr = a.dateCreation != null
                ? 'Le ${a.dateCreation!.day.toString().padLeft(2, '0')}/${a.dateCreation!.month.toString().padLeft(2, '0')}/${a.dateCreation!.year}'
                : 'Récemment';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildReviewCard(
                author: a.clientNomComplet,
                date: dateStr,
                rating: a.note,
                prestation: 'Prestation vérifiée',
                comment: a.commentaire ?? 'Expérience remarquable, équipe très professionnelle !',
                initials: a.initials,
                bgColor: const Color(0xFF382319),
              ),
            );
          })
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.figmaInputBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: context.symmetricBorder(),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.rate_review_outlined,
                  color: AppColors.figmaActiveGold,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  'Aucun avis pour le moment',
                  style: TextStyle(
                    fontSize: context.fontSize(14),
                    fontWeight: FontWeight.w700,
                    color: context.adaptiveTextColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Soyez le premier client à partager votre expérience !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.fontSize(12),
                    color: context.adaptiveSubtextColor(),
                  ),
                ),
              ],
            ),
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
                value: ratio.clamp(0.0, 1.0),
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
        border: context.symmetricBorder(),
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
                        fontSize: context.fontSize(13),
                        fontWeight: FontWeight.w700,
                        color: context.adaptiveTextColor(),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: context.fontSize(10.5),
                        color: context.adaptiveSubtextColor(),
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
              fontSize: context.fontSize(11),
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: TextStyle(
              fontSize: context.fontSize(12),
              color: context.adaptiveTextColor(),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
