import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../data/assistant_repository.dart';
import '../data/models/assistant_models.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  final String? initialSlugSalon;

  const AssistantScreen({
    super.key,
    this.initialSlugSalon,
  });

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late final String _sessionId;

  final List<MessageChat> _messages = [];
  List<String> _currentSuggestions = [
    'Salons à proximité',
    'Tresses & Coiffures tendance',
    'Comment fonctionne la réservation ?',
    'Boutique soins capillaires',
    'Mes rendez-vous',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sessionId = 'sess_mob_${DateTime.now().millisecondsSinceEpoch}';
    _messages.add(
      MessageChat(
        text: 'Bonjour ! Je suis votre concierge virtuel Mon Salon, propulsé par l\'IA Gemini. '
            'Comment puis-je vous accompagner aujourd\'hui ? (Recherche de salon, réservation, conseils soins capillaires ou tresses tendances...)',
        isUser: false,
        suggestions: List.from(_currentSuggestions),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _reinitialiserConversation() {
    setState(() {
      _messages.clear();
      _currentSuggestions = [
        'Salons à proximité',
        'Tresses & Coiffures tendance',
        'Comment fonctionne la réservation ?',
        'Boutique soins capillaires',
        'Mes rendez-vous',
      ];
      _messages.add(
        MessageChat(
          text: 'Conversation réinitialisée. Comment puis-je vous aider ?',
          isUser: false,
          suggestions: List.from(_currentSuggestions),
        ),
      );
    });
  }

  void _sendMessage([String? textToSend]) async {
    final text = (textToSend ?? _controller.text).trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(MessageChat(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final repository = ref.read(assistantRepositoryProvider);
      final response = await repository.sendMessage(
        message: text,
        sessionId: _sessionId,
        slugSalon: widget.initialSlugSalon,
        pageCourante: 'ACCUEIL',
      );

      if (mounted) {
        setState(() {
          _messages.add(
            MessageChat(
              text: response.texte,
              isUser: false,
              cartes: response.cartes,
              suggestions: response.suggestions,
              actionsUi: response.actionsUi,
            ),
          );
          if (response.suggestions.isNotEmpty) {
            _currentSuggestions = response.suggestions;
          }
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            MessageChat(
              text: 'Désolé, une erreur est survenue lors de la communication avec l\'assistant. Veuillez réessayer.',
              isUser: false,
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF9F7F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.figmaBrown,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.figmaActiveGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.figmaActiveGold,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assistant IA Gemini',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'En ligne • Concierge 24/7',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Réinitialiser la discussion',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _reinitialiserConversation,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageItem(msg, isDark);
                },
              ),
            ),

            // Typing Indicator
            if (_isLoading) _buildTypingIndicator(isDark),

            // Suggestions Chips
            if (_currentSuggestions.isNotEmpty && !_isLoading)
              _buildSuggestionsChips(isDark),

            // Bottom Input
            _buildInputBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(MessageChat msg, bool isDark) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.figmaBrown,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.figmaActiveGold,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.figmaBrown, Color(0xFF6B584C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.figmaActiveGold.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.figmaActiveGold,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFE8E2DC),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2C2420),
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Render Cards if present
            if (msg.cartes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 42, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: msg.cartes.map((c) => _buildCarte(c, isDark)).toList(),
                ),
              ),

            // Render UI Actions if present (e.g. login prompt)
            if (msg.actionsUi.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 42, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: msg.actionsUi.map((action) => _buildActionUi(action)).toList(),
                ),
              ),
          ],
        ),
      );
    }
  }

  Widget _buildCarte(AssistantCarte carte, bool isDark) {
    if (carte.donnees.isEmpty) return const SizedBox.shrink();

    final type = carte.type.toUpperCase();

    if (type == 'SALONS' || type == 'SALON') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              carte.titre.isNotEmpty ? carte.titre : 'Salons disponibles',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
              ),
            ),
          ),
          SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: carte.donnees.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final salon = carte.donnees[idx];
                final slug = salon['slug'] as String? ?? '';
                final nom = salon['nom'] as String? ?? 'Salon';
                final logo = salon['logoUrl'] as String? ?? salon['coverUrl'] as String?;
                final adresse = salon['adresse'] as String? ?? salon['localisation'] as String? ?? 'Mali';

                return Container(
                  width: 175,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInputBg : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : const Color(0xFFE5E0DB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: logo != null && logo.isNotEmpty
                            ? Image.network(
                                logo,
                                height: 60,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  height: 60,
                                  color: AppColors.figmaBrown.withValues(alpha: 0.1),
                                  child: const Icon(Icons.storefront, color: AppColors.figmaBrown),
                                ),
                              )
                            : Container(
                                height: 60,
                                color: AppColors.figmaBrown.withValues(alpha: 0.1),
                                child: const Icon(Icons.storefront, color: AppColors.figmaBrown),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.figmaBrown,
                        ),
                      ),
                      Text(
                        adresse,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.figmaActiveGold,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            if (slug.isNotEmpty) {
                              context.push('${RouteNames.salonDetail}/$slug');
                            }
                          },
                          child: const Text('Voir le salon', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    } else if (type == 'PRODUITS' || type == 'PRODUIT') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              carte.titre.isNotEmpty ? carte.titre : 'Produits recommandés',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
              ),
            ),
          ),
          SizedBox(
            height: 155,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: carte.donnees.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final p = carte.donnees[idx];
                final nom = p['nom'] as String? ?? 'Produit';
                final prix = p['prixVente'] ?? p['prix'] ?? 0;
                final img = p['imageUrl'] as String? ?? (p['imagesUrls'] is List && (p['imagesUrls'] as List).isNotEmpty ? (p['imagesUrls'] as List).first : null);

                return Container(
                  width: 145,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInputBg : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : const Color(0xFFE5E0DB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: img != null
                            ? Image.network(
                                img,
                                height: 60,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.inventory_2, color: Colors.grey),
                                ),
                              )
                            : Container(
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.inventory_2, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.figmaBrown,
                        ),
                      ),
                      Text(
                        '$prix FCFA',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 26,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.figmaActiveGold),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            context.push(RouteNames.recherche);
                          },
                          child: const Text('Boutique', style: TextStyle(fontSize: 10, color: AppColors.figmaActiveGold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    } else if (type == 'REALISATIONS' || type == 'COIFFURES' || type == 'COIFFURE') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              carte.titre.isNotEmpty ? carte.titre : 'Inspirations coiffures',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.figmaActiveGold : AppColors.figmaBrown,
              ),
            ),
          ),
          SizedBox(
            height: 145,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: carte.donnees.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final r = carte.donnees[idx];
                final titre = r['titre'] as String? ?? 'Création';
                final media = r['mediaUrl'] as String? ?? r['miniatureUrl'] as String?;

                return Container(
                  width: 130,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInputBg : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : const Color(0xFFE5E0DB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: media != null
                            ? Image.network(
                                media,
                                height: 75,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  height: 75,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.play_circle_fill, color: Colors.grey),
                                ),
                              )
                            : Container(
                                height: 75,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.play_circle_fill, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.figmaBrown,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => context.push(RouteNames.kadys),
                        child: const Row(
                          children: [
                            Text('Kady\'s', style: TextStyle(fontSize: 10, color: AppColors.figmaActiveGold, fontWeight: FontWeight.bold)),
                            Icon(Icons.arrow_forward_ios, size: 8, color: AppColors.figmaActiveGold),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    } else if (type == 'RENDEZ_VOUS' || type == 'RENDEZVOUS') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: carte.donnees.map((rdv) {
          final salon = rdv['nomSalon'] as String? ?? 'Salon';
          final date = rdv['date'] as String? ?? rdv['dateHeure'] as String? ?? '';
          final heure = rdv['heureDebut'] as String? ?? '';
          final statut = rdv['statut'] as String? ?? 'CONFIRME';

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkInputBg : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD1FAE5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: AppColors.figmaActiveGold),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(salon, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('$date à $heure', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEF7EC),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statut,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF03543F)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionUi(AssistantActionUi action) {
    if (action.type == 'ui_demander_connexion') {
      return Container(
        margin: const EdgeInsets.only(top: 4, bottom: 8),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.figmaActiveGold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          icon: const Icon(Icons.login_rounded, size: 16),
          label: const Text('Se connecter à mon compte', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          onPressed: () => context.push(RouteNames.login),
        ),
      );
    } else if (action.type == 'ui_ouvrir_salon') {
      final slug = action.payload['slugSalon'] as String? ?? '';
      return Container(
        margin: const EdgeInsets.only(top: 4, bottom: 8),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.figmaBrown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          icon: const Icon(Icons.store_rounded, size: 16),
          label: const Text('Accéder au salon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          onPressed: () {
            if (slug.isNotEmpty) context.push('${RouteNames.salonDetail}/$slug');
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.figmaActiveGold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Gemini réfléchit...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsChips(bool isDark) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _currentSuggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final s = _currentSuggestions[index];
          return ActionChip(
            label: Text(
              s,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextPrimary : AppColors.figmaBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.figmaActiveGold.withValues(alpha: 0.5),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () => _sendMessage(s),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                fontSize: 14,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Posez votre question à Gemini...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.figmaActiveGold, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.figmaBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
            ),
            icon: const Icon(Icons.send_rounded, size: 20),
            onPressed: () => _sendMessage(),
          ),
        ],
      ),
    );
  }
}
