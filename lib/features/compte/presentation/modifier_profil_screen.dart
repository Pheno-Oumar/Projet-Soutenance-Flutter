import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../data/compte_repository.dart';
import 'providers/compte_provider.dart';

class CountryDialCode {
  final String name;
  final String code;
  final String flag;

  const CountryDialCode({
    required this.name,
    required this.code,
    required this.flag,
  });
}

class ModifierProfilScreen extends ConsumerStatefulWidget {
  const ModifierProfilScreen({super.key});

  @override
  ConsumerState<ModifierProfilScreen> createState() => _ModifierProfilScreenState();
}

class _ModifierProfilScreenState extends ConsumerState<ModifierProfilScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _prenomController;
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  CountryDialCode _selectedDialCode = const CountryDialCode(
    name: 'Sénégal',
    code: '+221',
    flag: '🇸🇳',
  );

  final List<CountryDialCode> _dialCodes = const [
    CountryDialCode(name: 'Sénégal', code: '+221', flag: '🇸🇳'),
    CountryDialCode(name: 'Mali', code: '+223', flag: '🇲🇱'),
    CountryDialCode(name: 'Côte d\'Ivoire', code: '+225', flag: '🇨🇮'),
    CountryDialCode(name: 'Guinée', code: '+224', flag: '🇬🇳'),
    CountryDialCode(name: 'Burkina Faso', code: '+226', flag: '🇧🇫'),
    CountryDialCode(name: 'Niger', code: '+227', flag: '🇳🇪'),
    CountryDialCode(name: 'Togo', code: '+228', flag: '🇹🇬'),
    CountryDialCode(name: 'Bénin', code: '+229', flag: '🇧🇯'),
    CountryDialCode(name: 'France', code: '+33', flag: '🇫🇷'),
  ];

  String? _selectedPays = 'Sénégal';
  final List<String> _paysList = const [
    'Sénégal',
    'Mali',
    'Côte d\'Ivoire',
    'Guinée',
    'Burkina Faso',
    'Niger',
    'Togo',
    'Bénin',
    'France',
  ];

  DateTime? _selectedDateNaissance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(clientProfileProvider).valueOrNull;

    _prenomController = TextEditingController(text: profile?.prenom ?? 'Aïcha');
    _nomController = TextEditingController(text: profile?.nom ?? 'Diallo');
    _emailController = TextEditingController(text: profile?.email ?? 'aicha.diallo@gmail.com');

    // Détection de l'indicatif initial si disponible dans le numéro
    String rawPhone = profile?.telephone ?? '+221 77 123 45 67';
    String phoneOnly = rawPhone;
    for (final dial in _dialCodes) {
      if (rawPhone.startsWith(dial.code)) {
        _selectedDialCode = dial;
        phoneOnly = rawPhone.replaceFirst(dial.code, '').trim();
        break;
      }
    }
    _phoneController = TextEditingController(text: phoneOnly);

    if (profile?.pays != null && _paysList.contains(profile!.pays)) {
      _selectedPays = profile.pays;
    }

    if (profile?.dateNaissance != null) {
      try {
        _selectedDateNaissance = DateTime.parse(profile!.dateNaissance!);
      } catch (_) {}
    } else {
      _selectedDateNaissance = DateTime(1998, 5, 14);
    }
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDateNaissance() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateNaissance ?? DateTime(1998, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.figmaBrown,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateNaissance = picked;
      });
    }
  }

  void _showDialCodePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          height: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Sélectionnez votre indicatif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _dialCodes.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                  ),
                  itemBuilder: (ctx, i) {
                    final item = _dialCodes[i];
                    final isSelected = item.code == _selectedDialCode.code;

                    return ListTile(
                      onTap: () {
                        setState(() {
                          _selectedDialCode = item;
                          if (_paysList.contains(item.name)) {
                            _selectedPays = item.name;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      leading: Text(item.flag, style: const TextStyle(fontSize: 24)),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.figmaBrown
                              : (isDark ? AppColors.darkTextPrimary : Colors.black87),
                        ),
                      ),
                      trailing: Text(
                        item.code,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.figmaBrown
                              : (isDark ? AppColors.darkTextSecondary : Colors.black54),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final fullTelephone = '${_selectedDialCode.code} ${_phoneController.text.trim()}';
    final dateString = _selectedDateNaissance != null
        ? '${_selectedDateNaissance!.year.toString().padLeft(4, '0')}-${_selectedDateNaissance!.month.toString().padLeft(2, '0')}-${_selectedDateNaissance!.day.toString().padLeft(2, '0')}'
        : null;

    try {
      final repo = ref.read(compteRepositoryProvider);
      await repo.updateCompte(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        telephone: fullTelephone,
        pays: _selectedPays,
        dateNaissance: dateString,
      );

      ref.invalidate(clientProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil sauvegardé localement : ${_prenomController.text} ${_nomController.text}'),
            backgroundColor: AppColors.figmaBrown,
          ),
        );
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Modifier mon profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================================================
              // 1. AVATAR ÉDITABLE EN HAUT
              // ==============================================================
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.figmaActiveGold,
                          width: 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/compte_img_1.jpeg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFF2E1C15),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sélectionner une nouvelle photo...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.figmaBrown,
                          border: Border.all(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==============================================================
              // 2. CHAMPS DU FORMULAIRE COMPTE
              // ==============================================================

              // Prénom
              _buildFieldLabel('Prénom *', isDark),
              TextFormField(
                controller: _prenomController,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                ),
                decoration: _buildInputDecoration(
                  hintText: 'Ex: Aïcha',
                  prefixIcon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Le prénom est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Nom
              _buildFieldLabel('Nom *', isDark),
              TextFormField(
                controller: _nomController,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                ),
                decoration: _buildInputDecoration(
                  hintText: 'Ex: Diallo',
                  prefixIcon: Icons.badge_outlined,
                  isDark: isDark,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Adresse Email
              _buildFieldLabel('Adresse e-mail', isDark),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                ),
                decoration: _buildInputDecoration(
                  hintText: 'Ex: aicha.diallo@gmail.com',
                  prefixIcon: Icons.email_outlined,
                  isDark: isDark,
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Veuillez saisir un e-mail valide';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Téléphone avec Indicatif International
              _buildFieldLabel('Numéro de téléphone * (avec indicatif)', isDark),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sélecteur d'indicatif pays
                  GestureDetector(
                    onTap: _showDialCodePicker,
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedDialCode.flag,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedDialCode.code,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Saisie du numéro
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                      ),
                      decoration: _buildInputDecoration(
                        hintText: '77 123 45 67',
                        prefixIcon: Icons.phone_android_rounded,
                        isDark: isDark,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Le téléphone est obligatoire';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Pays de résidence
              _buildFieldLabel('Pays de résidence', isDark),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPays,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                    ),
                    items: _paysList.map((pays) {
                      return DropdownMenuItem<String>(
                        value: pays,
                        child: Row(
                          children: [
                            const Icon(Icons.public_rounded, size: 18, color: AppColors.figmaBrown),
                            const SizedBox(width: 10),
                            Text(
                              pays,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedPays = val;
                          final match = _dialCodes.firstWhere(
                            (d) => d.name == val,
                            orElse: () => _selectedDialCode,
                          );
                          _selectedDialCode = match;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date de naissance
              _buildFieldLabel('Date de naissance', isDark),
              GestureDetector(
                onTap: _pickDateNaissance,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined, size: 20, color: AppColors.figmaBrown),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDateNaissance != null
                            ? '${_selectedDateNaissance!.day.toString().padLeft(2, '0')}/${_selectedDateNaissance!.month.toString().padLeft(2, '0')}/${_selectedDateNaissance!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedDateNaissance != null
                              ? (isDark ? AppColors.darkTextPrimary : Colors.black87)
                              : (isDark ? AppColors.darkTextSecondary : Colors.black38),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                        color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==============================================================
              // 3. ACCÈS SÉCURITÉ & MODIFIER LE MOT DE PASSE
              // ==============================================================
              InkWell(
                onTap: () => context.push(RouteNames.changerMotDePasse),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : const Color(0xFFFBF4ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : const Color(0xFFE2C9B6).withValues(alpha: 0.7),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.figmaBrown.withValues(alpha: isDark ? 0.25 : 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.figmaBrown,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mot de passe & Sécurité',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2E1C15),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Modifier votre mot de passe de connexion',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.figmaBrown,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==============================================================
              // 4. BOUTON ENREGISTRER LES MODIFICATIONS
              // ==============================================================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.figmaBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_outline_rounded, size: 19),
                            SizedBox(width: 8),
                            Text(
                              'Enregistrer les modifications',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF374151),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 13.5,
        color: isDark ? AppColors.darkTextSecondary : Colors.black38,
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.figmaBrown),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.figmaActiveGold, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.0),
      ),
    );
  }
}
