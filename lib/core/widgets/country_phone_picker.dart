import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

class CountryPhone {
  final String name;
  final String dialCode;
  final String isoCode;
  final String flag;

  const CountryPhone({
    required this.name,
    required this.dialCode,
    required this.isoCode,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryPhone &&
          runtimeType == other.runtimeType &&
          dialCode == other.dialCode &&
          isoCode == other.isoCode;

  @override
  int get hashCode => dialCode.hashCode ^ isoCode.hashCode;

  /// Retrouve automatiquement le pays correspondant à partir d'un numéro international complet
  static CountryPhone fromTelephone(String phone, {CountryPhone? fallback}) {
    final clean = phone.trim();
    if (!clean.startsWith('+')) {
      return fallback ?? allCountries.first;
    }
    // Chercher la correspondance la plus longue (ex: +243 avant +24)
    CountryPhone? bestMatch;
    int maxLen = 0;
    for (final c in allCountries) {
      if (clean.startsWith(c.dialCode) && c.dialCode.length > maxLen) {
        bestMatch = c;
        maxLen = c.dialCode.length;
      }
    }
    return bestMatch ?? fallback ?? allCountries.first;
  }

  /// Liste exhaustive complète (Ordre prioritaire sous-région Afrique de l'Ouest/Centrale, puis international)
  static const List<CountryPhone> allCountries = [
    // Priorité sous-régionale principale (comme dans le projet Angular hair-style)
    CountryPhone(name: 'Mali', dialCode: '+223', isoCode: 'ML', flag: '🇲🇱'),
    CountryPhone(name: 'Sénégal', dialCode: '+221', isoCode: 'SN', flag: '🇸🇳'),
    CountryPhone(name: "Côte d'Ivoire", dialCode: '+225', isoCode: 'CI', flag: '🇨🇮'),
    CountryPhone(name: 'Guinée', dialCode: '+224', isoCode: 'GN', flag: '🇬🇳'),
    CountryPhone(name: 'Burkina Faso', dialCode: '+226', isoCode: 'BF', flag: '🇧🇫'),
    CountryPhone(name: 'Niger', dialCode: '+227', isoCode: 'NE', flag: '🇳🇪'),
    CountryPhone(name: 'Togo', dialCode: '+228', isoCode: 'TG', flag: '🇹🇬'),
    CountryPhone(name: 'Bénin', dialCode: '+229', isoCode: 'BJ', flag: '🇧🇯'),
    CountryPhone(name: 'Cameroun', dialCode: '+237', isoCode: 'CM', flag: '🇨🇲'),
    CountryPhone(name: 'Gabon', dialCode: '+241', isoCode: 'GA', flag: '🇬🇦'),
    CountryPhone(name: 'Congo-Brazzaville', dialCode: '+242', isoCode: 'CG', flag: '🇨🇬'),
    CountryPhone(name: 'RD Congo', dialCode: '+243', isoCode: 'CD', flag: '🇨🇩'),
    CountryPhone(name: 'France', dialCode: '+33', isoCode: 'FR', flag: '🇫🇷'),

    // Afrique élargie
    CountryPhone(name: 'Mauritanie', dialCode: '+222', isoCode: 'MR', flag: '🇲🇷'),
    CountryPhone(name: 'Maroc', dialCode: '+212', isoCode: 'MA', flag: '🇲🇦'),
    CountryPhone(name: 'Algérie', dialCode: '+213', isoCode: 'DZ', flag: '🇩🇿'),
    CountryPhone(name: 'Tunisie', dialCode: '+216', isoCode: 'TN', flag: '🇹🇳'),
    CountryPhone(name: 'Tchad', dialCode: '+235', isoCode: 'TD', flag: '🇹🇩'),
    CountryPhone(name: 'Centrafrique', dialCode: '+236', isoCode: 'CF', flag: '🇨🇫'),
    CountryPhone(name: 'Guinée-Bissau', dialCode: '+245', isoCode: 'GW', flag: '🇬🇼'),
    CountryPhone(name: 'Guinée équatoriale', dialCode: '+240', isoCode: 'GQ', flag: '🇬🇶'),
    CountryPhone(name: 'Gambie', dialCode: '+220', isoCode: 'GM', flag: '🇬🇲'),
    CountryPhone(name: 'Ghana', dialCode: '+233', isoCode: 'GH', flag: '🇬🇭'),
    CountryPhone(name: 'Nigéria', dialCode: '+234', isoCode: 'NG', flag: '🇳🇬'),
    CountryPhone(name: 'Sierra Leone', dialCode: '+232', isoCode: 'SL', flag: '🇸🇱'),
    CountryPhone(name: 'Libéria', dialCode: '+231', isoCode: 'LR', flag: '🇱🇷'),
    CountryPhone(name: 'Rwanda', dialCode: '+250', isoCode: 'RW', flag: '🇷🇼'),
    CountryPhone(name: 'Burundi', dialCode: '+257', isoCode: 'BI', flag: '🇧🇮'),
    CountryPhone(name: 'Madagascar', dialCode: '+261', isoCode: 'MG', flag: '🇲🇬'),
    CountryPhone(name: 'Comores', dialCode: '+269', isoCode: 'KM', flag: '🇰🇲'),
    CountryPhone(name: 'Cap-Vert', dialCode: '+238', isoCode: 'CV', flag: '🇨🇻'),

    // Europe, Amériques, Moyen-Orient & International
    CountryPhone(name: 'Belgique', dialCode: '+32', isoCode: 'BE', flag: '🇧🇪'),
    CountryPhone(name: 'Suisse', dialCode: '+41', isoCode: 'CH', flag: '🇨🇭'),
    CountryPhone(name: 'Canada', dialCode: '+1', isoCode: 'CA', flag: '🇨🇦'),
    CountryPhone(name: 'États-Unis', dialCode: '+1', isoCode: 'US', flag: '🇺🇸'),
    CountryPhone(name: 'Royaume-Uni', dialCode: '+44', isoCode: 'GB', flag: '🇬🇧'),
    CountryPhone(name: 'Espagne', dialCode: '+34', isoCode: 'ES', flag: '🇪🇸'),
    CountryPhone(name: 'Italie', dialCode: '+39', isoCode: 'IT', flag: '🇮🇹'),
    CountryPhone(name: 'Allemagne', dialCode: '+49', isoCode: 'DE', flag: '🇩🇪'),
    CountryPhone(name: 'Portugal', dialCode: '+351', isoCode: 'PT', flag: '🇵🇹'),
    CountryPhone(name: 'Turquie', dialCode: '+90', isoCode: 'TR', flag: '🇹🇷'),
    CountryPhone(name: 'Émirats Arabes Unis', dialCode: '+971', isoCode: 'AE', flag: '🇦🇪'),
    CountryPhone(name: 'Arabie Saoudite', dialCode: '+966', isoCode: 'SA', flag: '🇸🇦'),
    CountryPhone(name: 'Chine', dialCode: '+86', isoCode: 'CN', flag: '🇨🇳'),
  ];
}

/// Affiche une feuille modale de recherche d'indicatifs téléphoniques
Future<CountryPhone?> showCountryPhonePicker(
  BuildContext context, {
  CountryPhone? current,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet<CountryPhone>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return _CountryPickerModal(current: current);
    },
  );
}

class _CountryPickerModal extends StatefulWidget {
  final CountryPhone? current;

  const _CountryPickerModal({this.current});

  @override
  State<_CountryPickerModal> createState() => _CountryPickerModalState();
}

class _CountryPickerModalState extends State<_CountryPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryPhone> _filtered = CountryPhone.allCountries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = CountryPhone.allCountries;
      } else {
        _filtered = CountryPhone.allCountries.where((c) {
          final nameMatch = c.name.toLowerCase().contains(query);
          final codeMatch = c.dialCode.contains(query);
          final isoMatch = c.isoCode.toLowerCase().contains(query);
          return nameMatch || codeMatch || isoMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.75,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Barre de tirage
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

            // Titre
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Choisir un indicatif',
                    style: TextStyle(
                      fontSize: context.fontSize(16.5),
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: isDark ? AppColors.darkTextMuted : Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Barre de recherche
            TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: context.fontSize(14),
                color: isDark ? AppColors.darkTextPrimary : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un pays ou indicatif (ex: 223, Mali)...',
                hintStyle: TextStyle(
                  fontSize: context.fontSize(13),
                  color: isDark ? AppColors.darkTextSecondary : Colors.black38,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.figmaBrown),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.figmaBrown,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Liste filtrée
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun pays trouvé',
                        style: TextStyle(
                          fontSize: context.fontSize(13.5),
                          color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        final isSelected = widget.current != null &&
                            widget.current!.dialCode == item.dialCode &&
                            widget.current!.isoCode == item.isoCode;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F4EE))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(color: AppColors.figmaActiveGold, width: 1.0)
                                : Border.all(color: Colors.transparent, width: 1.0),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            leading: Text(
                              item.flag,
                              style: const TextStyle(fontSize: 22),
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: context.fontSize(14),
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                              ),
                            ),
                            trailing: Text(
                              item.dialCode,
                              style: TextStyle(
                                fontSize: context.fontSize(13.5),
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.figmaActiveGold
                                    : (isDark ? AppColors.darkTextSecondary : Colors.grey[700]),
                              ),
                            ),
                            onTap: () => Navigator.pop(context, item),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
