class AssistantCarte {
  final String type;
  final String titre;
  final List<Map<String, dynamic>> donnees;

  const AssistantCarte({
    required this.type,
    required this.titre,
    this.donnees = const [],
  });

  factory AssistantCarte.fromJson(Map<String, dynamic> json) {
    final rawDonnees = json['donnees'];
    List<Map<String, dynamic>> parsedDonnees = [];
    if (rawDonnees is List) {
      for (final item in rawDonnees) {
        if (item is Map<String, dynamic>) {
          parsedDonnees.add(item);
        } else if (item is Map) {
          parsedDonnees.add(Map<String, dynamic>.from(item));
        }
      }
    }
    return AssistantCarte(
      type: json['type'] as String? ?? 'GENERAL',
      titre: json['titre'] as String? ?? '',
      donnees: parsedDonnees,
    );
  }
}

class AssistantActionUi {
  final String type;
  final Map<String, dynamic> payload;

  const AssistantActionUi({
    required this.type,
    this.payload = const {},
  });

  factory AssistantActionUi.fromJson(Map<String, dynamic> json) {
    return AssistantActionUi(
      type: json['type'] as String? ?? json['nom'] as String? ?? '',
      payload: (json['payload'] as Map<String, dynamic>?) ??
          (json['parametres'] as Map<String, dynamic>?) ??
          const {},
    );
  }
}

class AssistantChatResponse {
  final String texte;
  final List<AssistantCarte> cartes;
  final List<String> suggestions;
  final List<AssistantActionUi> actionsUi;
  final String? contexte;

  const AssistantChatResponse({
    required this.texte,
    this.cartes = const [],
    this.suggestions = const [],
    this.actionsUi = const [],
    this.contexte,
  });

  factory AssistantChatResponse.fromJson(Map<String, dynamic> json) {
    final cartesRaw = json['cartes'] as List<dynamic>? ?? [];
    final suggestionsRaw = json['suggestions'] as List<dynamic>? ?? [];
    final actionsUiRaw = json['actionsUi'] as List<dynamic>? ?? [];

    return AssistantChatResponse(
      texte: json['texte'] as String? ??
          json['reponse'] as String? ??
          'Je suis à votre écoute pour vos besoins capillaires !',
      cartes: cartesRaw
          .whereType<Map<String, dynamic>>()
          .map((c) => AssistantCarte.fromJson(c))
          .toList(),
      suggestions: suggestionsRaw.map((s) => s.toString()).toList(),
      actionsUi: actionsUiRaw
          .whereType<Map<String, dynamic>>()
          .map((a) => AssistantActionUi.fromJson(a))
          .toList(),
      contexte: json['contexte'] as String?,
    );
  }
}

class MessageChat {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<AssistantCarte> cartes;
  final List<String> suggestions;
  final List<AssistantActionUi> actionsUi;

  MessageChat({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.cartes = const [],
    this.suggestions = const [],
    this.actionsUi = const [],
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();
}
