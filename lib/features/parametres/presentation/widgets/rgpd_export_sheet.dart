import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/models/rgpd_models.dart';
import '../../data/repositories/rgpd_repository.dart';

class RgpdExportSheet extends ConsumerStatefulWidget {
  const RgpdExportSheet({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const RgpdExportSheet(),
    );
  }

  @override
  ConsumerState<RgpdExportSheet> createState() => _RgpdExportSheetState();
}

class _RgpdExportSheetState extends ConsumerState<RgpdExportSheet> {
  String _selectedFormat = 'JSON';
  bool _isGenerating = false;
  bool _isLoadingArchives = true;
  List<DemandeExportModel> _archives = [];

  @override
  void initState() {
    super.initState();
    _loadArchives();
  }

  Future<void> _loadArchives() async {
    setState(() => _isLoadingArchives = true);
    try {
      final repo = ref.read(rgpdRepositoryProvider);
      final list = await repo.consulterMesArchives();
      if (mounted) {
        setState(() {
          _archives = list;
          _isLoadingArchives = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingArchives = false);
      }
    }
  }

  Future<void> _genererExport() async {
    setState(() => _isGenerating = true);
    try {
      final repo = ref.read(rgpdRepositoryProvider);
      final nouvelExport = await repo.demanderExport(_selectedFormat);
      if (mounted) {
        setState(() {
          _archives = [nouvelExport, ..._archives];
          _isGenerating = false;
        });
        AppToast.show(
          context,
          message: 'Votre archive $_selectedFormat a été générée avec succès (valable 48h).',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        AppToast.show(
          context,
          message: 'Erreur lors de la génération de l\'export : ${e.toString().replaceAll('Exception: ', '')}',
          type: ToastType.error,
        );
      }
    }
  }

  void _copierLien(String? url) {
    if (url == null || url.isEmpty) return;
    Clipboard.setData(ClipboardData(text: url));
    AppToast.show(
      context,
      message: 'Lien de téléchargement sécurisé copié dans le presse-papier !',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final df = DateFormat('dd/MM/yyyy à HH:mm');

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée de glissement
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
              const SizedBox(height: 16),

              // En-tête
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF3ECE4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.file_download_outlined,
                      size: 24,
                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exporter mes données',
                          style: TextStyle(
                            fontSize: context.fontSize(17),
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                          ),
                        ),
                        Text(
                          'Droit à la portabilité (Art. 20 RGPD)',
                          style: TextStyle(
                            fontSize: context.fontSize(12),
                            color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Explication
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFFAF6F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFE8DFD5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Vous pouvez récupérer une copie de votre profil, historique de commandes, rendez-vous et réclamations dans un format lisible et structuré.',
                        style: TextStyle(
                          fontSize: context.fontSize(12.5),
                          height: 1.35,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2C241E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Choix du format
              Text(
                'Choisir le format d\'archive',
                style: TextStyle(
                  fontSize: context.fontSize(14),
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildFormatCard(
                      format: 'JSON',
                      titre: 'Format JSON',
                      description: 'Structuré & machine-readable',
                      icon: Icons.code_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFormatCard(
                      format: 'CSV',
                      titre: 'Format CSV',
                      description: 'Tableur Excel / Feuilles',
                      icon: Icons.table_chart_outlined,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bouton générer
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _genererExport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                    foregroundColor: isDark ? const Color(0xFF1E1610) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: _isGenerating
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? const Color(0xFF1E1610) : Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    _isGenerating ? 'Génération en cours...' : 'Générer mon archive $_selectedFormat',
                    style: TextStyle(
                      fontSize: context.fontSize(14),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section archives existantes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mes archives (valides 48h)',
                    style: TextStyle(
                      fontSize: context.fontSize(14),
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
                    ),
                  ),
                  if (_isLoadingArchives)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (_archives.isEmpty && !_isLoadingArchives)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F7F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : const Color(0xFFEBE3D9),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_download_outlined,
                        size: 32,
                        color: isDark ? AppColors.darkTextMuted : Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucune archive générée pour le moment',
                        style: TextStyle(
                          fontSize: context.fontSize(13),
                          color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._archives.map((a) {
                  final isExpired = a.expire || a.statut == 'EXPIRE';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isExpired
                            ? (isDark ? AppColors.darkBorder : Colors.grey[300]!)
                            : AppColors.figmaActiveGold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? Colors.grey.withValues(alpha: 0.2)
                                    : AppColors.figmaActiveGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                a.format,
                                style: TextStyle(
                                  fontSize: context.fontSize(11.5),
                                  fontWeight: FontWeight.w800,
                                  color: isExpired ? Colors.grey : AppColors.figmaBrown,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? Colors.red.withValues(alpha: 0.12)
                                    : Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isExpired ? 'Expiré' : 'Disponible',
                                style: TextStyle(
                                  fontSize: context.fontSize(11),
                                  fontWeight: FontWeight.w700,
                                  color: isExpired ? Colors.red[700] : Colors.green[700],
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (a.dateDemande != null)
                              Text(
                                df.format(a.dateDemande!),
                                style: TextStyle(
                                  fontSize: context.fontSize(11),
                                  color: isDark ? AppColors.darkTextMuted : Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        if (a.dateExpiration != null && !isExpired) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Valable jusqu\'au ${df.format(a.dateExpiration!)}',
                            style: TextStyle(
                              fontSize: context.fontSize(11.5),
                              color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
                            ),
                          ),
                        ],
                        if (!isExpired && a.urlTelechargement != null) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _copierLien(a.urlTelechargement),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                                side: BorderSide(
                                  color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              label: const Text(
                                'Copier le lien sécurisé',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatCard({
    required String format,
    required String titre,
    required String description,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F4EE))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.figmaActiveGold
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.figmaActiveGold
                      : (isDark ? AppColors.darkTextMuted : Colors.grey[700]),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.figmaActiveGold,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              titre,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
