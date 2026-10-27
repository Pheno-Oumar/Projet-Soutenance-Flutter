import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import 'package:mobile_hair_style/features/salon/presentation/providers/salon_provider.dart';
import 'package:mobile_hair_style/features/rendezvous/data/rendezvous_mock_data.dart' show SalonItem;
import 'package:mobile_hair_style/features/rendezvous/presentation/providers/rendezvous_provider.dart';
import 'package:mobile_hair_style/features/reclamations/data/models/reclamation_model.dart';
import 'package:mobile_hair_style/features/reclamations/data/reclamation_repository.dart';
import 'providers/reclamation_provider.dart';
import 'widgets/salon_search_sheet.dart';

class NouvelleReclamationScreen extends ConsumerStatefulWidget {
  const NouvelleReclamationScreen({super.key});

  @override
  ConsumerState<NouvelleReclamationScreen> createState() => _NouvelleReclamationScreenState();
}

class _NouvelleReclamationScreenState extends ConsumerState<NouvelleReclamationScreen> {
  final _objetController = TextEditingController();
  final _descriptionController = TextEditingController();

  SalonItem? _selectedSalon;
  List<TypeReclamationModel> _typesDisponibles = [];
  bool _isLoadingTypes = false;
  TypeReclamationModel? _selectedTypeModel;
  String? _ineligibleNotice;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salonsState = ref.read(salonsListProvider);
      if (salonsState.salons.isNotEmpty) {
        final mesRecState = ref.read(mesReclamationsProvider);
        final mesRdvState = ref.read(mesRendezVousProvider);
        final Set<String> frequentSlugs = {
          ...mesRecState.allReclamations.map((r) => r.salonSlug),
          ...mesRdvState.allRendezVous
              .map((rdv) => rdv.salonSlug)
              .whereType<String>()
              .where((s) => s.isNotEmpty),
        };

        // Prioriser un salon fréquenté si disponible
        final salons = salonsState.salons.map((s) => SalonItem(
          slug: s.slug,
          nom: s.nom,
          adresse: s.adresse ?? 'Bamako, Mali',
          logo: s.logoUrl ?? s.coverUrl ?? 'assets/images/rdv_tous_0.png',
        )).toList();

        final firstSalon = salons.where((s) => frequentSlugs.contains(s.slug)).firstOrNull ?? salons.first;
        setState(() => _selectedSalon = firstSalon);
        _chargerTypesEligibles(firstSalon.slug);
      }
    });
  }

  @override
  void dispose() {
    _objetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _chargerTypesEligibles(String slug) async {
    setState(() {
      _isLoadingTypes = true;
      _ineligibleNotice = null;
    });
    try {
      final types = await ref.read(reclamationRepositoryProvider).getTypesEligibles(slug);
      if (mounted) {
        setState(() {
          _typesDisponibles = types;
          _isLoadingTypes = false;
          // Sélectionner automatiquement le 1er type éligible ou le premier de la liste
          final premierEligible = types.where((t) => t.eligible).firstOrNull;
          _selectedTypeModel = premierEligible ?? (types.isNotEmpty ? types.first : null);
          if (_selectedTypeModel != null && !_selectedTypeModel!.eligible) {
            _ineligibleNotice = _selectedTypeModel!.motifIneligibilite;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingTypes = false);
      }
    }
  }

  void _ouvrirSelecteurSalon(
    BuildContext context,
    List<SalonItem> salons,
    Set<String> frequentSlugs,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SalonSearchSheet(
        salons: salons,
        selectedSalon: _selectedSalon,
        frequentSalonSlugs: frequentSlugs,
        onSalonSelected: (salon) {
          if (salon.slug != _selectedSalon?.slug) {
            setState(() => _selectedSalon = salon);
            _chargerTypesEligibles(salon.slug);
            AppToast.show(
              context,
              message: 'Salon « ${salon.nom} » sélectionné',
              type: ToastType.info,
            );
          }
        },
      ),
    );
  }

  Widget _buildSalonAvatar(String logo, String nom, bool isDark, {double size = 44}) {
    Widget imageWidget;
    if (logo.startsWith('http://') || logo.startsWith('https://')) {
      imageWidget = Image.network(
        logo,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackInitial(nom),
      );
    } else if (logo.isNotEmpty && logo.startsWith('assets/')) {
      imageWidget = Image.asset(
        logo,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackInitial(nom),
      );
    } else {
      imageWidget = _buildFallbackInitial(nom);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: ClipOval(child: imageWidget),
    );
  }

  Widget _buildFallbackInitial(String nom) {
    return Container(
      color: AppColors.figmaBrown,
      alignment: Alignment.center,
      child: Text(
        nom.isNotEmpty ? nom[0].toUpperCase() : 'S',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Future<void> _soumettre(SalonItem? salon) async {
    if (salon == null) {
      AppToast.show(
        context,
        message: 'Veuillez sélectionner un salon.',
        type: ToastType.warning,
      );
      return;
    }

    if (_selectedTypeModel == null) {
      AppToast.show(
        context,
        message: 'Veuillez sélectionner un type de réclamation.',
        type: ToastType.warning,
      );
      return;
    }

    if (!_selectedTypeModel!.eligible) {
      AppToast.show(
        context,
        message: _selectedTypeModel!.motifIneligibilite ?? 'Vous n\'êtes pas éligible pour ce type de réclamation.',
        type: ToastType.warning,
      );
      return;
    }

    final objet = _objetController.text.trim();
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      AppToast.show(
        context,
        message: 'Veuillez décrire votre réclamation en détail.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(mesReclamationsProvider.notifier).ajouterReclamation(
            salonSlug: salon.slug,
            salonNom: salon.nom,
            salonAdresse: salon.adresse,
            salonLogo: salon.logo,
            type: _selectedTypeModel!.type,
            objet: objet.isNotEmpty ? objet : 'Réclamation sur ${_selectedTypeModel!.libelle.toLowerCase()}',
            description: description,
          );

      if (mounted) {
        AppToast.show(
          context,
          message: 'Votre réclamation a été envoyée avec succès.',
          type: ToastType.success,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: e.toString().replaceAll('Exception: ', '').replaceAll('Failure: ', ''),
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final salonsState = ref.watch(salonsListProvider);
    final mesRecState = ref.watch(mesReclamationsProvider);
    final mesRdvState = ref.watch(mesRendezVousProvider);

    final Set<String> frequentSlugs = {
      ...mesRecState.allReclamations.map((r) => r.salonSlug),
      ...mesRdvState.allRendezVous
          .map((rdv) => rdv.salonSlug)
          .whereType<String>()
          .where((s) => s.isNotEmpty),
    };

    final salons = salonsState.salons.map((s) => SalonItem(
      slug: s.slug,
      nom: s.nom,
      adresse: s.adresse ?? 'Bamako, Mali',
      logo: s.logoUrl ?? s.coverUrl ?? 'assets/images/rdv_tous_0.png',
    )).toList();

    final defaultSalon = salons.where((s) => frequentSlugs.contains(s.slug)).firstOrNull ??
        (salons.isNotEmpty ? salons.first : null);

    final currentSalon = (_selectedSalon != null && salons.any((s) => s.slug == _selectedSalon!.slug))
        ? salons.firstWhere((s) => s.slug == _selectedSalon!.slug)
        : defaultSalon;

    if (_selectedSalon == null && currentSalon != null && _typesDisponibles.isEmpty && !_isLoadingTypes) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedSalon == null) {
          setState(() => _selectedSalon = currentSalon);
          _chargerTypesEligibles(currentSalon.slug);
        }
      });
    }

    final canSubmit = currentSalon != null &&
        _selectedTypeModel != null &&
        _selectedTypeModel!.eligible &&
        !_isSubmitting;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Nouvelle réclamation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Sélectionnez le salon *
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1. Sélectionnez le salon *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                  ),
                ),
                if (salons.isNotEmpty)
                  GestureDetector(
                    onTap: () => _ouvrirSelecteurSalon(context, salons, frequentSlugs),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 16,
                            color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Rechercher (${salons.length})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Card Salon Sélectionné cliquable
            GestureDetector(
              onTap: salons.isEmpty ? null : () => _ouvrirSelecteurSalon(context, salons, frequentSlugs),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
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
                child: salons.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          salonsState.isLoading ? 'Chargement des salons...' : 'Aucun salon disponible',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          _buildSalonAvatar(
                            currentSalon?.logo ?? '',
                            currentSalon?.nom ?? 'S',
                            isDark,
                            size: 46,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        currentSalon?.nom ?? 'Sélectionnez un salon',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (currentSalon != null && frequentSlugs.contains(currentSalon.slug)) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.figmaActiveGold.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppColors.figmaActiveGold,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Fréquenté',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.figmaBrown,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 13,
                                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        currentSalon?.adresse ?? 'Bamako, Mali',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
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
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFEFE7DE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Changer',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 22),

            // 2. Type de réclamation *
            Row(
              children: [
                Text(
                  '2. Type de réclamation *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                  ),
                ),
                if (_isLoadingTypes) ...[
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.figmaBrown),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Seuls les types correspondant à vos achats ou prestations dans ce salon sont sélectionnables.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            if (_isLoadingTypes && _typesDisponibles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.figmaBrown),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Vérification des éligibilités...',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else if (_typesDisponibles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aucun type disponible pour ce salon.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _typesDisponibles.map((t) {
                  final isSelected = _selectedTypeModel?.type == t.type;
                  final isEligible = t.eligible;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTypeModel = t;
                        if (!isEligible) {
                          _ineligibleNotice = t.motifIneligibilite;
                        } else {
                          _ineligibleNotice = null;
                        }
                      });
                      if (!isEligible && t.motifIneligibilite != null) {
                        AppToast.show(
                          context,
                          message: t.motifIneligibilite!,
                          type: ToastType.warning,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isEligible
                                ? AppColors.figmaBrown
                                : (isDark ? const Color(0xFF3E2C22) : const Color(0xFFF3E5D8)))
                            : (isEligible
                                ? (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFEFE7DE))
                                : (isDark ? Colors.grey[850] : const Color(0xFFF2F2F2))),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? (isEligible ? AppColors.figmaBrown : const Color(0xFFC57000))
                              : (isEligible
                                  ? Colors.transparent
                                  : (isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0))),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isEligible) ...[
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 13,
                              color: isSelected
                                  ? const Color(0xFFC57000)
                                  : (isDark ? Colors.grey[500] : const Color(0xFF9E9E9E)),
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            t.libelle,
                            style: TextStyle(
                              color: isSelected
                                  ? (isEligible
                                      ? Colors.white
                                      : (isDark ? const Color(0xFFFFB74D) : const Color(0xFFC57000)))
                                  : (isEligible
                                      ? (isDark ? AppColors.darkTextSecondary : AppColors.figmaBrown)
                                      : (isDark ? Colors.grey[500] : const Color(0xFF9E9E9E))),
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            // Notice explicative si un type non éligible est sélectionné
            if (_ineligibleNotice != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2216) : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFFD54F),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFC57000),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _ineligibleNotice!,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFFFE082) : const Color(0xFF8D5300),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Alerte si l'utilisateur n'a aucune interaction avec le salon
            if (_typesDisponibles.isNotEmpty && !_typesDisponibles.any((t) => t.eligible)) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF331B1B) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEF9A9A), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.block_rounded, color: Color(0xFFD32F2F), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Vous n\'avez encore aucune interaction enregistrée avec ce salon (commande validée ou rendez-vous terminé). Vous ne pouvez pas soumettre de réclamation pour le moment.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFFFCDD2) : const Color(0xFFC62828),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 22),

            // 3. Objet résumé
            Text(
              '3. Objet résumé',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _objetController,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Ex: Problème sur la prestation réalisée',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : Colors.grey[500],
                  fontSize: 13,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkInputBg : const Color(0xFFFAF7F2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // 4. Décrivez votre réclamation en détail *
            Text(
              '4. Décrivez votre réclamation en détail *',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Expliquez ce qui s\'est passé, date de rendez-vous ou commande...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : Colors.grey[500],
                  fontSize: 13,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkInputBg : const Color(0xFFFAF7F2),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Bouton "Envoyer la réclamation"
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: canSubmit
                    ? () => _soumettre(currentSalon)
                    : () {
                        if (_selectedTypeModel != null && !_selectedTypeModel!.eligible) {
                          AppToast.show(
                            context,
                            message: _selectedTypeModel!.motifIneligibilite ?? 'Type non éligible pour ce salon.',
                            type: ToastType.warning,
                          );
                        } else if (_descriptionController.text.trim().isEmpty) {
                          AppToast.show(
                            context,
                            message: 'Veuillez décrire votre réclamation en détail.',
                            type: ToastType.warning,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSubmit
                      ? AppColors.figmaBrown
                      : (isDark ? Colors.grey[800] : const Color(0xFFCCCCCC)),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text(
                        'Envoyer la réclamation',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
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
