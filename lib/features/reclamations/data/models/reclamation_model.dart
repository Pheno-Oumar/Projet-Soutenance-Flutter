class ReclamationModel {
  final int id;
  final String codeReference;
  final String salonNom;
  final String salonSlug;
  final String salonAdresse;
  final String salonLogo;
  final String type; // 'PRODUIT', 'SERVICE', 'SALON', 'PAIEMENT'
  final String objet;
  final String description;
  final String statut; // 'EN_ATTENTE', 'EN_COURS', 'RESOLUE', 'REJETEE'
  final String? reponseTraitement;
  final String? reponseAuteur;
  final String? reponseAuteurInitiales;
  final String dateCreation;
  final String? dateTraitement;

  const ReclamationModel({
    required this.id,
    this.codeReference = '',
    required this.salonNom,
    required this.salonSlug,
    this.salonAdresse = 'Dakar, Almadies',
    this.salonLogo = 'assets/images/rdv_tous_0.png',
    this.type = 'SERVICE',
    required this.objet,
    required this.description,
    this.statut = 'EN_ATTENTE',
    this.reponseTraitement,
    this.reponseAuteur,
    this.reponseAuteurInitiales,
    required this.dateCreation,
    this.dateTraitement,
  });

  String get referenceCode {
    if (codeReference.isNotEmpty) return codeReference;
    return '#REC-2025-${id.toString().padLeft(4, '0')}';
  }

  bool get isEnAttente => statut == 'EN_ATTENTE';
  bool get isEnCours => statut == 'EN_COURS';
  bool get isResolue => statut == 'RESOLUE';
  bool get isRejetee => statut == 'REJETEE';

  String get statutLabel {
    switch (statut.toUpperCase()) {
      case 'EN_ATTENTE':
        return 'En attente';
      case 'EN_COURS':
        return 'En cours';
      case 'RESOLUE':
        return 'Résolue';
      case 'REJETEE':
      case 'REJETE':
        return 'Rejetée';
      default:
        return statut;
    }
  }

  String get typeLabel {
    switch (type.toUpperCase()) {
      case 'PRODUIT':
      case 'PRODUITS':
        return 'Produits';
      case 'SERVICE':
      case 'PRESTATION':
        return 'Service';
      case 'SALON':
        return 'Salon';
      case 'PAIEMENT':
        return 'Paiement';
      default:
        return type;
    }
  }

  ReclamationModel copyWith({
    int? id,
    String? codeReference,
    String? salonNom,
    String? salonSlug,
    String? salonAdresse,
    String? salonLogo,
    String? type,
    String? objet,
    String? description,
    String? statut,
    String? reponseTraitement,
    String? reponseAuteur,
    String? reponseAuteurInitiales,
    String? dateCreation,
    String? dateTraitement,
  }) {
    return ReclamationModel(
      id: id ?? this.id,
      codeReference: codeReference ?? this.codeReference,
      salonNom: salonNom ?? this.salonNom,
      salonSlug: salonSlug ?? this.salonSlug,
      salonAdresse: salonAdresse ?? this.salonAdresse,
      salonLogo: salonLogo ?? this.salonLogo,
      type: type ?? this.type,
      objet: objet ?? this.objet,
      description: description ?? this.description,
      statut: statut ?? this.statut,
      reponseTraitement: reponseTraitement ?? this.reponseTraitement,
      reponseAuteur: reponseAuteur ?? this.reponseAuteur,
      reponseAuteurInitiales: reponseAuteurInitiales ?? this.reponseAuteurInitiales,
      dateCreation: dateCreation ?? this.dateCreation,
      dateTraitement: dateTraitement ?? this.dateTraitement,
    );
  }

  String get dateCreationFormatee {
    if (dateCreation.isEmpty) return '';
    if (dateCreation.contains('T')) {
      try {
        final dt = DateTime.parse(dateCreation);
        return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      } catch (_) {}
    }
    return dateCreation;
  }

  factory ReclamationModel.fromJson(Map<String, dynamic> json) {
    return ReclamationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      codeReference: json['codeReference'] as String? ??
          (json['id'] != null ? '#REC-2026-${json['id'].toString().padLeft(4, '0')}' : ''),
      salonNom: json['salonNom'] as String? ?? 'Salon',
      salonSlug: json['salonSlug'] as String? ?? '',
      salonAdresse: json['salonAdresse'] as String? ?? 'Dakar',
      salonLogo: json['salonLogo'] as String? ?? 'assets/images/rdv_tous_0.png',
      type: json['type'] as String? ?? 'SERVICE',
      objet: json['objet'] as String? ?? '',
      description: json['description'] as String? ?? '',
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      reponseTraitement: json['reponseTraitement'] as String?,
      reponseAuteur: json['traiteParNomComplet'] as String? ?? json['reponseAuteur'] as String?,
      reponseAuteurInitiales: json['reponseAuteurInitiales'] as String?,
      dateCreation: json['dateCreation'] as String? ?? '',
      dateTraitement: json['dateTraitement'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'codeReference': codeReference,
    'salonNom': salonNom,
    'salonSlug': salonSlug,
    'salonAdresse': salonAdresse,
    'salonLogo': salonLogo,
    'type': type,
    'objet': objet,
    'description': description,
    'statut': statut,
    'reponseTraitement': reponseTraitement,
    'reponseAuteur': reponseAuteur,
    'reponseAuteurInitiales': reponseAuteurInitiales,
    'dateCreation': dateCreation,
    'dateTraitement': dateTraitement,
  };
}
