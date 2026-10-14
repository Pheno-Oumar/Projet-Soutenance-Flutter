import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/models/profil_capillaire_model.dart';
import 'providers/recommandation_provider.dart';

class ProfilCapillaireScreen extends ConsumerStatefulWidget {
  const ProfilCapillaireScreen({super.key});

  @override
  ConsumerState<ProfilCapillaireScreen> createState() =>
      _ProfilCapillaireScreenState();
}

class _ProfilCapillaireScreenState extends ConsumerState<ProfilCapillaireScreen> {
  String selectedType = 'CREPUS';
  String selectedTexture = 'EPAIS';
  String selectedPorosite = 'FORTE';
  String selectedLongueur = 'MI_LONGS';
  String selectedDensite = 'FORTE';
  String selectedCuir = 'SEC';
  String selectedEtat = 'SEC';

  final pinController = TextEditingController();
  bool isSaving = false;
  bool isInitialized = false;

  final Map<String, String> typeOptions = {
    'CREPUS': 'Crépus (4A - 4C)',
    'FRISES': 'Frisés (3C)',
    'BOUCLES': 'Bouclés (3A - 3B)',
    'ONDULES': 'Ondulés (2A - 2C)',
    'LISSES': 'Lisses (1A - 1C)',
  };

  final Map<String, String> textureOptions = {
    'FINS': 'Fins',
    'MOYENS': 'Moyens',
    'EPAIS': 'Épais',
  };

  final Map<String, String> porositeOptions = {
    'FAIBLE': 'Faible (Écailles serrées)',
    'MOYENNE': 'Moyenne (Équilibrée)',
    'FORTE': 'Forte (Écailles ouvertes)',
  };

  final Map<String, String> longueurOptions = {
    'COURTS': 'Courts',
    'MI_LONGS': 'Mi-longs',
    'LONGS': 'Longs',
    'TRES_LONGS': 'Très longs',
  };

  final Map<String, String> densiteOptions = {
    'FAIBLE': 'Faible (Clairsemés)',
    'MOYENNE': 'Moyenne',
    'FORTE': 'Forte (Dense)',
  };

  final Map<String, String> cuirOptions = {
    'NORMAL': 'Normal',
    'SEC': 'Sec',
    'GRAS': 'Gras',
    'SENSIBLE': 'Sensible / Irrité',
    'PELLICULES': 'Sujet aux pellicules',
  };

  final Map<String, String> etatOptions = {
    'SAIN': 'Sain & Naturel',
    'SEC': 'Sec / Déshydraté',
    'ABIME': 'Abîmé / Fourchu',
    'CASSE': 'Cassant',
    'COLORE': 'Coloré / Décoloré',
    'DEFRISE': 'Défrisé',
    'TRANSITION': 'En transition',
  };

  @override
  void initState() {
    super.initState();
  }

  void _syncFromProfil(ProfilCapillaireModel? p) {
    if (p == null || isInitialized) return;
    if (p.typeCheveux != null) selectedType = p.typeCheveux!;
    if (p.texture != null) selectedTexture = p.texture!;
    if (p.porosite != null) selectedPorosite = p.porosite!;
    if (p.longueur != null) selectedLongueur = p.longueur!;
    if (p.densite != null) selectedDensite = p.densite!;
    if (p.cuirChevelu != null) selectedCuir = p.cuirChevelu!;
    if (p.etatCheveux != null) selectedEtat = p.etatCheveux!;
    isInitialized = true;
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E140C),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioChips({
    required Map<String, String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
    required bool isDark,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((entry) {
        final isSelected = entry.key == selectedValue;
        return InkWell(
          onTap: () => onSelected(entry.key),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                  : (isDark ? AppColors.darkSurface : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                    : (isDark ? AppColors.darkBorder : const Color(0xFFE5DDD3)),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown)
                            .withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              entry.value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? const Color(0xFF1E140C) : Colors.white)
                    : (isDark ? AppColors.darkTextSecondary : const Color(0xFF4A3E36)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profilAsync = ref.watch(profilCapillaireProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final profil = profilAsync.valueOrNull;
    _syncFromProfil(profil);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mon Profil Capillaire',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro
            Text(
              'Diagnostic personnalisé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E140C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Renseignez la nature de votre chevelure pour que notre algorithme vous recommande les soins les plus adaptés.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B5C51),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // 1. Type de cheveux
            _buildSectionTitle('Type de cheveux', Icons.waves_rounded, isDark),
            const SizedBox(height: 10),
            _buildRadioChips(
              options: typeOptions,
              selectedValue: selectedType,
              onSelected: (val) => setState(() => selectedType = val),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // 2. Porosité
            _buildSectionTitle('Porosité du cheveu', Icons.opacity_rounded, isDark),
            const SizedBox(height: 10),
            _buildRadioChips(
              options: porositeOptions,
              selectedValue: selectedPorosite,
              onSelected: (val) => setState(() => selectedPorosite = val),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // 3. Cuir chevelu
            _buildSectionTitle('Nature du cuir chevelu', Icons.bubble_chart_outlined, isDark),
            const SizedBox(height: 10),
            _buildRadioChips(
              options: cuirOptions,
              selectedValue: selectedCuir,
              onSelected: (val) => setState(() => selectedCuir = val),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // 4. Texture
            _buildSectionTitle('Texture de la fibre', Icons.line_weight_rounded, isDark),
            const SizedBox(height: 10),
            _buildRadioChips(
              options: textureOptions,
              selectedValue: selectedTexture,
              onSelected: (val) => setState(() => selectedTexture = val),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // 5. Longueur
            _buildSectionTitle('Longueur actuelle', Icons.straighten_rounded, isDark),
            const SizedBox(height: 10),
            _buildRadioChips(
              options: longueurOptions,
              selectedValue: selectedLongueur,
              onSelected: (val) => setState(() => selectedLongueur = val),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // 6. Densité
            _buildSectionTitle('Densité capillaire', Icons.grain_rounded, isDark),
            const SizedBox(height: 10),
            _buildRadioChips(
              options: densiteOptions,
              selectedValue: selectedDensite,
              onSelected: (val) => setState(() => selectedDensite = val),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // 7. État des cheveux
            _buildSectionTitle('État actuel des cheveux', Icons.favorite_outline_rounded, isDark),
            const SizedBox(height: 10),
            _buildRadioChips(
              options: etatOptions,
              selectedValue: selectedEtat,
              onSelected: (val) => setState(() => selectedEtat = val),
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // 8. Code PIN de sécurité
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE5DDD3),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: AppColors.figmaActiveGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Code PIN de consultation salon',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E140C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Permet à votre coiffeur partenaire de consulter votre historique et vos contre-indications en salon.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF7E7369),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: profil?.hasCodeProfil == true ? '•••• (PIN déjà configuré)' : 'Définir un PIN (4 chiffres)',
                      counterText: '',
                      filled: true,
                      fillColor: isDark ? AppColors.darkCardBg : const Color(0xFFFAF7F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE0D8CE),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Bouton Enregistrer
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        setState(() => isSaving = true);
                        try {
                          final payload = {
                            'typeCheveux': selectedType,
                            'texture': selectedTexture,
                            'porosite': selectedPorosite,
                            'longueur': selectedLongueur,
                            'densite': selectedDensite,
                            'cuirChevelu': selectedCuir,
                            'etatCheveux': selectedEtat,
                          };

                          await ref
                              .read(profilCapillaireProvider.notifier)
                              .enregistrerProfil(payload);

                          if (pinController.text.trim().length == 4) {
                            await ref
                                .read(profilCapillaireProvider.notifier)
                                .changerPin(pinController.text.trim());
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profil capillaire enregistré avec succès !'),
                                backgroundColor: AppColors.figmaBrown,
                              ),
                            );
                            context.pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $e'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => isSaving = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.figmaBrown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Enregistrer mon profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
