import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:mobile_hair_style/features/salon/presentation/providers/salon_provider.dart';
import 'package:mobile_hair_style/features/rendezvous/data/rendezvous_mock_data.dart' show SalonItem;
import 'providers/reclamation_provider.dart';

class NouvelleReclamationScreen extends ConsumerStatefulWidget {
  const NouvelleReclamationScreen({super.key});

  @override
  ConsumerState<NouvelleReclamationScreen> createState() => _NouvelleReclamationScreenState();
}

class _NouvelleReclamationScreenState extends ConsumerState<NouvelleReclamationScreen> {
  final _objetController = TextEditingController();
  final _descriptionController = TextEditingController();

  SalonItem? _selectedSalon;
  String _selectedType = 'Service';
  bool _hasAttachment = false;

  final List<String> _types = const ['Produit', 'Service', 'Salon', 'Paiement'];

  @override
  void dispose() {
    _objetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _soumettre(SalonItem? salon) async {
    if (salon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un salon.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    final objet = _objetController.text.trim();
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez décrire votre réclamation en détail.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    await ref.read(mesReclamationsProvider.notifier).ajouterReclamation(
          salonSlug: salon.slug,
          salonNom: salon.nom,
          salonAdresse: salon.adresse,
          salonLogo: salon.logo,
          type: _selectedType.toUpperCase(),
          objet: objet.isNotEmpty ? objet : 'Réclamation sur ${_selectedType.toLowerCase()}',
          description: description,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre réclamation a été envoyée avec succès.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final salonsState = ref.watch(salonsListProvider);
    final salons = salonsState.salons.map((s) => SalonItem(
      slug: s.slug,
      nom: s.nom,
      adresse: s.adresse ?? 'Dakar, Sénégal',
      logo: s.logoUrl ?? s.coverUrl ?? 'assets/images/rdv_tous_0.png',
    )).toList();

    final currentSalon = (_selectedSalon != null && salons.any((s) => s.slug == _selectedSalon!.slug))
        ? salons.firstWhere((s) => s.slug == _selectedSalon!.slug)
        : (salons.isNotEmpty ? salons.first : null);

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
            Text(
              '1. Sélectionnez le salon *',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFD8A868),
                  width: 1.0,
                ),
              ),
              child: salons.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        salonsState.isLoading ? 'Chargement des salons...' : 'Aucun salon disponible',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<SalonItem>(
                        value: currentSalon,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF5B3926),
                        ),
                        items: salons.map((s) {
                          return DropdownMenuItem<SalonItem>(
                            value: s,
                            child: Text(
                              '${s.nom} (${s.adresse})',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSalon = val);
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 22),

            // 2. Type de réclamation (Titre) *
            Text(
              '2. Type de réclamation (Titre) *',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: _types.map((t) {
                final isSelected = _selectedType == t;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.figmaBrown
                            : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFEFE7DE)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.darkTextSecondary : AppColors.figmaBrown),
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
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
                hintText: 'Problème sur la prestation réalisée',
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
                hintText: 'Expliquez ce qui s\'est passé, date de rendez-vous...',
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
            const SizedBox(height: 18),

            // Joindre une photo ou preuve (optionnel)
            GestureDetector(
              onTap: () {
                setState(() => _hasAttachment = !_hasAttachment);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _hasAttachment
                          ? 'Preuve / photo sélectionnée'
                          : 'Preuve retirée',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasAttachment
                        ? AppColors.figmaActiveGold
                        : (isDark ? AppColors.darkBorder : const Color(0xFFEFE9E0)),
                    width: 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _hasAttachment ? Icons.check_circle_rounded : Icons.attach_file_rounded,
                      size: 18,
                      color: _hasAttachment
                          ? AppColors.figmaActiveGold
                          : (isDark ? AppColors.darkTextSecondary : Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _hasAttachment
                          ? 'Photo jointe (1 pièce jointe)'
                          : 'Joindre une photo ou preuve (optionnel)',
                      style: TextStyle(
                        fontSize: 13,
                        color: _hasAttachment
                            ? AppColors.figmaBrown
                            : (isDark ? AppColors.darkTextSecondary : Colors.grey[600]),
                        fontWeight: _hasAttachment ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Bouton "Envoyer la réclamation"
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _soumettre(currentSalon),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.figmaBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
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
