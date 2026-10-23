import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/country_phone_picker.dart';
import '../../../routing/route_names.dart';
import '../data/models/auth_models.dart';
import 'providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  CountryPhone _selectedCountry = CountryPhone.allCountries.first; // Mali par défaut
  bool _obscurePassword = true;

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final fullPhone = '${_selectedCountry.dialCode}${_phoneController.text.trim()}';

    final request = RegisterRequest(
      prenom: _prenomController.text.trim(),
      nom: _nomController.text.trim(),
      telephone: fullPhone,
      codePays: _selectedCountry.name,
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      motDePasse: _passwordController.text,
    );

    final success = await ref.read(authStateProvider.notifier).register(request);

    if (success && mounted) {
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(RouteNames.home);
      }
    }
  }

  Future<void> _pickCountry() async {
    final picked = await showCountryPhonePicker(
      context,
      current: _selectedCountry,
    );
    if (picked != null && mounted) {
      setState(() => _selectedCountry = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    InputDecoration buildInputDecoration({
      required String label,
      String? hint,
      Widget? prefixIcon,
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: context.fontSize(14),
          color: isDark ? AppColors.darkTextSecondary : Colors.black54,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: context.fontSize(13),
          color: isDark ? AppColors.darkTextSecondary : Colors.black38,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            color: AppColors.figmaActiveGold,
            width: 1.5,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.home);
            }
          },
        ),
        title: const Text(
          'Créer un compte',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveValue(compact: 16.0, standard: 24.0),
            vertical: 20.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Rejoignez Mon Salon',
                  style: TextStyle(
                    fontSize: context.fontSize(21),
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Inscrivez-vous en quelques secondes pour réserver vos soins et passer vos commandes.',
                  style: TextStyle(
                    fontSize: context.fontSize(13.5),
                    color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),

                // Affichage Erreur
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 19),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 1. Prénom & Nom (côte à côte)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prenomController,
                        style: TextStyle(
                          fontSize: context.fontSize(14),
                          color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                        ),
                        decoration: buildInputDecoration(
                          label: 'Prénom *',
                          hint: 'Votre prénom',
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _nomController,
                        style: TextStyle(
                          fontSize: context.fontSize(14),
                          color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                        ),
                        decoration: buildInputDecoration(
                          label: 'Nom *',
                          hint: 'Votre nom',
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Téléphone avec sélecteur d'indicatif complet
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _pickCountry,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCountry.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _selectedCountry.dialCode,
                              style: TextStyle(
                                fontSize: context.fontSize(14),
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: isDark ? AppColors.darkTextMuted : Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontSize: context.fontSize(14.5),
                          color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                        ),
                        decoration: buildInputDecoration(
                          label: 'Téléphone *',
                          hint: 'ex: 70 12 34 56',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Numéro requis';
                          }
                          if (val.trim().length < 6) {
                            return 'Numéro trop court';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. Email (Facultatif)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: context.fontSize(14.5),
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  ),
                  decoration: buildInputDecoration(
                    label: 'Email (optionnel)',
                    hint: 'Pour recevoir vos confirmations',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.figmaBrown),
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(
                    fontSize: context.fontSize(14.5),
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  ),
                  decoration: buildInputDecoration(
                    label: 'Mot de passe *',
                    hint: 'Au moins 6 caractères',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.figmaBrown),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Au moins 6 caractères' : null,
                ),
                const SizedBox(height: 24),

                // Bouton Créer mon compte
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.figmaBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Créer mon compte',
                            style: TextStyle(
                              fontSize: context.fontSize(15.5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 14),

                // Lien Se connecter
                TextButton(
                  onPressed: () => context.pop(),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: context.fontSize(14),
                          color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                        ),
                        children: const [
                          TextSpan(text: 'Déjà un compte ? '),
                          TextSpan(
                            text: 'Se connecter',
                            style: TextStyle(
                              color: AppColors.figmaBrown,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
