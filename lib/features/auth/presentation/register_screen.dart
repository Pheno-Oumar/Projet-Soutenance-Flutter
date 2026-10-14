import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
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
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final request = RegisterRequest(
      prenom: _prenomController.text.trim(),
      nom: _nomController.text.trim(),
      telephone: _telephoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      motDePasse: _passwordController.text,
    );

    final success = await ref.read(authStateProvider.notifier).register(request);

    if (success && mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    InputDecoration buildRegDecoration({
      required String label,
      String? hint,
      Widget? prefixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : Colors.black54,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : Colors.black38,
        ),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        foregroundColor: Colors.white,
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Rejoignez Mon Salon',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Réservez vos coiffures, commandez vos produits et recevez vos conseils personnalisés.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _prenomController,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : Colors.black87),
                  decoration: buildRegDecoration(
                    label: 'Prénom *',
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.figmaBrown),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomController,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : Colors.black87),
                  decoration: buildRegDecoration(
                    label: 'Nom *',
                    prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.figmaBrown),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telephoneController,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : Colors.black87),
                  decoration: buildRegDecoration(
                    label: 'Téléphone *',
                    hint: '+221771234567',
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.figmaBrown),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Numéro de téléphone requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : Colors.black87),
                  decoration: buildRegDecoration(
                    label: 'Email (optionnel)',
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.figmaBrown),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : Colors.black87),
                  decoration: buildRegDecoration(
                    label: 'Mot de passe *',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.figmaBrown),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Au moins 6 caractères' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.figmaBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Créer mon compte',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Déjà un compte ? Se connecter',
                    style: TextStyle(color: AppColors.figmaBrown, fontWeight: FontWeight.w600),
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
