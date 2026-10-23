import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/country_phone_picker.dart';
import '../../../routing/route_names.dart';
import 'providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPhoneMode = true; // Par défaut connexion par téléphone
  CountryPhone _selectedCountry = CountryPhone.allCountries.first; // Mali par défaut
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final identifiant = _isPhoneMode
        ? '${_selectedCountry.dialCode}${_phoneController.text.trim()}'
        : _emailController.text.trim();

    final success = await ref.read(authStateProvider.notifier).login(
          identifiant,
          _passwordController.text,
        );

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
          'Connexion Client',
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
                SizedBox(height: context.responsiveValue(compact: 10.0, standard: 16.0)),

                // Logo salon
                Center(
                  child: Container(
                    width: context.responsiveValue(compact: 56.0, standard: 68.0),
                    height: context.responsiveValue(compact: 56.0, standard: 68.0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF6EFE7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.content_cut_rounded,
                      size: context.responsiveValue(compact: 30.0, standard: 36.0),
                      color: AppColors.figmaActiveGold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'Bienvenue sur Mon Salon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.fontSize(21),
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Connectez-vous pour retrouver vos favoris, rendez-vous et commandes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.fontSize(13.5),
                    color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),

                // Onglets Switch Téléphone / Email
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1EBE4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPhoneMode = true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _isPhoneMode
                                  ? (isDark ? AppColors.darkSurface : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: _isPhoneMode
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_iphone_rounded,
                                  size: 17,
                                  color: _isPhoneMode
                                      ? AppColors.figmaActiveGold
                                      : (isDark ? AppColors.darkTextMuted : Colors.grey[600]),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Téléphone',
                                  style: TextStyle(
                                    fontSize: context.fontSize(13.5),
                                    fontWeight: _isPhoneMode ? FontWeight.w700 : FontWeight.w500,
                                    color: _isPhoneMode
                                        ? (isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E))
                                        : (isDark ? AppColors.darkTextSecondary : Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPhoneMode = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !_isPhoneMode
                                  ? (isDark ? AppColors.darkSurface : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: !_isPhoneMode
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mail_outline_rounded,
                                  size: 17,
                                  color: !_isPhoneMode
                                      ? AppColors.figmaActiveGold
                                      : (isDark ? AppColors.darkTextMuted : Colors.grey[600]),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: context.fontSize(13.5),
                                    fontWeight: !_isPhoneMode ? FontWeight.w700 : FontWeight.w500,
                                    color: !_isPhoneMode
                                        ? (isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E))
                                        : (isDark ? AppColors.darkTextSecondary : Colors.grey[700]),
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

                // Champ Téléphone avec indicatif
                if (_isPhoneMode) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bouton Sélecteur Indicatif Pays
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

                      // Saisie du numéro
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontSize: context.fontSize(14.5),
                            color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Numéro de téléphone',
                            labelStyle: TextStyle(
                              fontSize: context.fontSize(14),
                              color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                            ),
                            hintText: 'ex: 70 12 34 56',
                            hintStyle: TextStyle(
                              fontSize: context.fontSize(13),
                              color: isDark ? AppColors.darkTextSecondary : Colors.black38,
                            ),
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
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Veuillez saisir votre numéro';
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
                ] else ...[
                  // Champ Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: context.fontSize(14.5),
                      color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Adresse e-mail',
                      labelStyle: TextStyle(
                        fontSize: context.fontSize(14),
                        color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                      ),
                      hintText: 'exemple@domaine.com',
                      hintStyle: TextStyle(
                        fontSize: context.fontSize(13),
                        color: isDark ? AppColors.darkTextSecondary : Colors.black38,
                      ),
                      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.figmaBrown),
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
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Veuillez saisir votre adresse e-mail';
                      }
                      if (!val.contains('@') || !val.contains('.')) {
                        return 'Adresse e-mail invalide';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 14),

                // Champ Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(
                    fontSize: context.fontSize(14.5),
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: TextStyle(
                      fontSize: context.fontSize(14),
                      color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                    ),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.figmaBrown),
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Veuillez saisir votre mot de passe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Bouton Se connecter
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: context.fontSize(15.5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 14),

                // Lien Inscription
                TextButton(
                  onPressed: () => context.push(RouteNames.register),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: context.fontSize(14),
                          color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                        ),
                        children: const [
                          TextSpan(text: 'Pas encore de compte ? '),
                          TextSpan(
                            text: 'S\'inscrire',
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
