import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/theme/app_colors.dart';

class MessageChat {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  MessageChat({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _controller = TextEditingController();
  final List<MessageChat> _messages = [
    MessageChat(
      text: 'Bonjour ! Je suis votre assistant virtuel Mon Salon propulsé par Gemini. Comment puis-je vous aider aujourd\'hui ? (Conseil coiffure, routine, recherche de salon...)',
      isUser: false,
    ),
  ];
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(MessageChat(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.assistantChat,
        data: {'prompt': text},
      );

      final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      final reply = apiResp.data?['reponse'] as String? ??
          apiResp.message ??
          'Je suis à votre écoute pour vos besoins capillaires !';

      if (mounted) {
        setState(() {
          _messages.add(MessageChat(text: reply, isUser: false));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(MessageChat(
            text: 'Désolé, une erreur est survenue lors de la communication avec l\'assistant.',
            isUser: false,
          ));
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
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.figmaActiveGold, size: 20),
            SizedBox(width: 8),
            Text('Assistant IA Gemini'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? AppColors.figmaBrown
                          : (isDark ? AppColors.darkSurface : const Color(0xFFF4EFEA)),
                      borderRadius: BorderRadius.circular(16),
                      border: !msg.isUser && isDark
                          ? Border.all(color: AppColors.darkBorder, width: 1.0)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser
                            ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary : Colors.black87),
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.figmaBrown),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
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
                    ),
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : Colors.black45,
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.darkInputBg : AppColors.figmaInputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.figmaBrown,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
