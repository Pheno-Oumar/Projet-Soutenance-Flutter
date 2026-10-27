import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../rendezvous/data/rendezvous_mock_data.dart' show SalonItem;

class SalonSearchSheet extends StatefulWidget {
  final List<SalonItem> salons;
  final SalonItem? selectedSalon;
  final Set<String> frequentSalonSlugs;
  final ValueChanged<SalonItem> onSalonSelected;

  const SalonSearchSheet({
    super.key,
    required this.salons,
    required this.selectedSalon,
    this.frequentSalonSlugs = const {},
    required this.onSalonSelected,
  });

  @override
  State<SalonSearchSheet> createState() => _SalonSearchSheetState();
}

class _SalonSearchSheetState extends State<SalonSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SalonItem> get _filteredSalons {
    if (_query.trim().isEmpty) return widget.salons;
    final q = _query.toLowerCase().trim();
    return widget.salons.where((s) {
      return s.nom.toLowerCase().contains(q) || s.adresse.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildSalonAvatar(String logo, String nom, bool isDark) {
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
      width: 44,
      height: 44,
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

  Widget _buildSalonItem(SalonItem salon, bool isDark) {
    final isSelected = widget.selectedSalon?.slug == salon.slug;
    final isFrequent = widget.frequentSalonSlugs.contains(salon.slug);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F4EE))
            : (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.figmaActiveGold
              : (isDark ? AppColors.darkBorder : Colors.grey.shade200),
          width: isSelected ? 1.6 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          widget.onSalonSelected(salon);
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _buildSalonAvatar(salon.logo, salon.nom, isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            salon.nom,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isFrequent) ...[
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
                            salon.adresse,
                            style: TextStyle(
                              fontSize: 12,
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
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.figmaActiveGold,
                  size: 22,
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? AppColors.darkBorder : Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredSalons;
    final totalCount = widget.salons.length;

    // Regrouper par fréquentés vs autres uniquement si recherche vide
    final frequentList = _query.isEmpty
        ? filtered.where((s) => widget.frequentSalonSlugs.contains(s.slug)).toList()
        : <SalonItem>[];
    final otherList = _query.isEmpty && frequentList.isNotEmpty
        ? filtered.where((s) => !widget.frequentSalonSlugs.contains(s.slug)).toList()
        : filtered;

    return Container(
      height: MediaQuery.of(context).size.height * 0.84,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Poignée drag
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // En-tête avec titre et bouton fermer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sélectionner un salon',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$totalCount salon${totalCount > 1 ? 's' : ''} disponible${totalCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputBg : const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0),
                  width: 1.0,
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom, quartier ou ville...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey[500],
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    size: 22,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) {
                  setState(() => _query = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Liste des résultats
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 52,
                            color: isDark ? AppColors.darkTextSecondary : Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun salon trouvé pour « $_query »',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Vérifiez l\'orthographe du nom ou du quartier recherché.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Réinitialiser la recherche'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.figmaBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    children: [
                      // Section Salons fréquentés
                      if (frequentList.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.history_rounded,
                                size: 16,
                                color: AppColors.figmaActiveGold,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Salons fréquentés (${frequentList.length})',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...frequentList.map((s) => _buildSalonItem(s, isDark)),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Tous les autres salons (${otherList.length})',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],

                      // Liste principale
                      ...otherList.map((s) => _buildSalonItem(s, isDark)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
