import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../data/compte_repository.dart';

class ChangerMotDePasseScreen extends ConsumerStatefulWidget {
  const ChangerMotDePasseScreen({super.key});

  @override
  ConsumerState<ChangerMotDePasseScreen> createState() => _ChangerMotDePasseScreenState();
}

class _ChangerMotDePasseScreenState extends ConsumerState<ChangerMotDePasseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ancienPasswordController = TextEditingController();
  final _nouveauPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureAncien = true;
  bool _obscureNouveau = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _ancienPasswordController.dispose();
    _nouveauPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitChangement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_nouveauPasswordController.text == _ancienPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nouveau mot de passe doit être différent de l\'ancien.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = ref.read(compteRepositoryProvider);
      await repo.changerMotDePasse(
        ancienMotDePasse: _ancienPasswordController.text.trim(),
        nouveauMotDePasse: _nouveauPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text('Mot de passe modifié avec succès !'),
              ),
            ],
          ),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 3),
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      String message = 'Impossible de modifier le mot de passe. Vérifiez l\'ancien mot de passe.';
      final errStr = e.toString();
      if (errStr.contains('Exception:')) {
        message = errStr.replaceAll('Exception:', '').trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: const Color(0xFFD32F2F),
          duration: const Duration(seconds: 4),
        ),
      );
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
        title: Text(
          'Sécurité & Mot de passe',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.fontSize(18),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: context.responsiveValue(compact: 70.0, standard: 80.0),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CARTE INFORMATIVE
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFFBF4ED),
                  borderRadius: BorderRadius.circular(16),
                  border: context.symmetricBorder(
                    borderColor: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFE2C9B6).withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.figmaBrown.withValues(alpha: isDark ? 0.25 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.figmaBrown,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Protégez votre compte',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2E1C15),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Saisissez votre mot de passe actuel puis choisissez un nouveau mot de passe fort d\'au moins 6 caractères.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 2. ANCIEN MOT DE PASSE
              _buildFieldLabel('Ancien mot de passe *', isDark),
              TextFormField(
                controller: _ancienPasswordController,
                obscureText: _obscureAncien,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  fontSize: 14,
                ),
                decoration: _buildInputDecoration(
                  hintText: 'Entrez votre mot de passe actuel',
                  prefixIcon: Icons.lock_open_rounded,
                  isDark: isDark,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureAncien ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureAncien = !_obscureAncien;
                      });
                    },
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez saisir votre ancien mot de passe';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // 3. NOUVEAU MOT DE PASSE
              _buildFieldLabel('Nouveau mot de passe *', isDark),
              TextFormField(
                controller: _nouveauPasswordController,
                obscureText: _obscureNouveau,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  fontSize: 14,
                ),
                decoration: _buildInputDecoration(
                  hintText: 'Minimum 6 caractères',
                  prefixIcon: Icons.lock_outline_rounded,
                  isDark: isDark,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNouveau ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNouveau = !_obscureNouveau;
                      });
                    },
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez saisir un nouveau mot de passe';
                  }
                  if (val.trim().length < 6) {
                    return 'Le mot de passe doit comporter au moins 6 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // 4. CONFIRMER NOUVEAU MOT DE PASSE
              _buildFieldLabel('Confirmer le nouveau mot de passe *', isDark),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  fontSize: 14,
                ),
                decoration: _buildInputDecoration(
                  hintText: 'Retapez le nouveau mot de passe',
                  prefixIcon: Icons.check_circle_outline_rounded,
                  isDark: isDark,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez confirmer le mot de passe';
                  }
                  if (val.trim() != _nouveauPasswordController.text.trim()) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // CONSEILS DE SÉCURITÉ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  children: [
                    _buildRuleItem('Au moins 6 caractères', isDark),
                    const SizedBox(height: 6),
                    _buildRuleItem('Différent de votre ancien mot de passe', isDark),
                    const SizedBox(height: 6),
                    _buildRuleItem('Les deux nouveaux mots de passe doivent concorder', isDark),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // 5. BOUTON D'ACTION
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitChangement,
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
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_reset_rounded, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Mettre à jour le mot de passe',
                                style: TextStyle(
                                  fontSize: context.fontSize(15),
                                  fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildRuleItem(String text, bool isDark) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.figmaActiveGold),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: context.fontSize(12.5),
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: context.fontSize(13),
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
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: context.fontSize(13.5),
        color: isDark ? AppColors.darkTextSecondary : Colors.black38,
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
      prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.figmaBrown),
      suffixIcon: suffixIcon,
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
        borderSide: const BorderSide(color: AppColors.figmaActiveGold, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.0),
      ),
    );
  }
}
