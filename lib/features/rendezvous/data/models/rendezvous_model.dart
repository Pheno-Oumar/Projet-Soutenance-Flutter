class LigneRendezVousModel {
  final int id;
  final int? varianteServiceId;
  final String? nomService;
  final String? nomVariante;
  final double prix;
  final int dureeMinutes;
  final String? imageUrl;

  const LigneRendezVousModel({
    required this.id,
    this.varianteServiceId,
    this.nomService,
    this.nomVariante,
    this.prix = 0.0,
    this.dureeMinutes = 0,
    this.imageUrl,
  });

  factory LigneRendezVousModel.fromJson(Map<String, dynamic> json) {
    return LigneRendezVousModel(
      id: json['id'] as int? ?? 0,
      varianteServiceId: json['varianteServiceId'] as int?,
      nomService: json['nomService'] as String?,
      nomVariante: json['nomVariante'] as String?,
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      dureeMinutes: json['dureeMinutes'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'varianteServiceId': varianteServiceId,
    'nomService': nomService,
    'nomVariante': nomVariante,
    'prix': prix,
    'dureeMinutes': dureeMinutes,
    'imageUrl': imageUrl,
  };
}

class RendezVousModel {
  final int id;
  final String codeReference;
  final String? salonSlug;
  final String? salonNom;
  final String? salonAdresse;
  final String? salonLogo;
  final String? salonCover;
  final String? coiffeurNom;
  final String? coiffeurPrenom;
  final String? nomClient;
  final String? prenomClient;
  final String? dateHeurePrevue;
  final String? dateHeureFin;
  final String statut;
  final double montantEstime;
  final int dureeMinutes;
  final String? motif;
  final List<LigneRendezVousModel> lignes;

  const RendezVousModel({
    required this.id,
    this.codeReference = '',
    this.salonSlug,
    this.salonNom,
    this.salonAdresse,
    this.salonLogo,
    this.salonCover,
    this.coiffeurNom,
    this.coiffeurPrenom,
    this.nomClient,
    this.prenomClient,
    this.dateHeurePrevue,
    this.dateHeureFin,
    this.statut = 'CONFIRME',
    this.montantEstime = 0.0,
    this.dureeMinutes = 60,
    this.motif,
    this.lignes = const [],
  });

  String get referenceCode {
    if (codeReference.isNotEmpty) return codeReference;
    return '#RDV-2025-${id.toString().padLeft(4, '0')}';
  }

  bool get isAVenir =>
      statut == 'A_VENIR' ||
      statut == 'CONFIRME' ||
      statut == 'EN_ATTENTE' ||
      statut == 'EN_COURS';

  bool get isPasse =>
      statut == 'PASSE' ||
      statut == 'TERMINE' ||
      statut == 'EFFECTUE' ||
      statut == 'NO_SHOW';

  bool get isAnnule =>
      statut == 'ANNULE' ||
      statut == 'REJETE';

  String get statutLabel {
    switch (statut.toUpperCase()) {
      case 'A_VENIR':
      case 'CONFIRME':
      case 'EN_ATTENTE':
      case 'EN_COURS':
        return 'À venir';
      case 'PASSE':
      case 'TERMINE':
      case 'EFFECTUE':
      case 'NO_SHOW':
        return 'Passé';
      case 'ANNULE':
      case 'REJETE':
        return 'Annulé';
      default:
        return statut;
    }
  }

  String get formattedDuree {
    if (dureeMinutes <= 0) return '45 min';
    final hours = dureeMinutes ~/ 60;
    final mins = dureeMinutes % 60;
    if (hours > 0 && mins > 0) return '$hours h $mins min';
    if (hours > 0) return '$hours h';
    return '$mins min';
  }

  String get coiffeurNomComplet {
    if (coiffeurPrenom != null && coiffeurNom != null) {
      return '$coiffeurPrenom $coiffeurNom';
    }
    return coiffeurNom ?? coiffeurPrenom ?? 'Non assigné';
  }

  RendezVousModel copyWith({
    int? id,
    String? codeReference,
    String? salonSlug,
    String? salonNom,
    String? salonAdresse,
    String? salonLogo,
    String? salonCover,
    String? coiffeurNom,
    String? coiffeurPrenom,
    String? nomClient,
    String? prenomClient,
    String? dateHeurePrevue,
    String? dateHeureFin,
    String? statut,
    double? montantEstime,
    int? dureeMinutes,
    String? motif,
    List<LigneRendezVousModel>? lignes,
  }) {
    return RendezVousModel(
      id: id ?? this.id,
      codeReference: codeReference ?? this.codeReference,
      salonSlug: salonSlug ?? this.salonSlug,
      salonNom: salonNom ?? this.salonNom,
      salonAdresse: salonAdresse ?? this.salonAdresse,
      salonLogo: salonLogo ?? this.salonLogo,
      salonCover: salonCover ?? this.salonCover,
      coiffeurNom: coiffeurNom ?? this.coiffeurNom,
      coiffeurPrenom: coiffeurPrenom ?? this.coiffeurPrenom,
      nomClient: nomClient ?? this.nomClient,
      prenomClient: prenomClient ?? this.prenomClient,
      dateHeurePrevue: dateHeurePrevue ?? this.dateHeurePrevue,
      dateHeureFin: dateHeureFin ?? this.dateHeureFin,
      statut: statut ?? this.statut,
      montantEstime: montantEstime ?? this.montantEstime,
      dureeMinutes: dureeMinutes ?? this.dureeMinutes,
      motif: motif ?? this.motif,
      lignes: lignes ?? this.lignes,
    );
  }

  factory RendezVousModel.fromJson(Map<String, dynamic> json) {
    final rawLignes = json['lignes'] as List<dynamic>? ?? [];
    return RendezVousModel(
      id: json['id'] as int? ?? 0,
      codeReference: json['codeReference'] as String? ?? '',
      salonSlug: json['salonSlug'] as String?,
      salonNom: json['salonNom'] as String?,
      salonAdresse: json['salonAdresse'] as String?,
      salonLogo: json['salonLogo'] as String?,
      salonCover: json['salonCover'] as String?,
      coiffeurNom: json['coiffeurNom'] as String?,
      coiffeurPrenom: json['coiffeurPrenom'] as String?,
      nomClient: json['nomClient'] as String?,
      prenomClient: json['prenomClient'] as String?,
      dateHeurePrevue: json['dateHeurePrevue'] as String?,
      dateHeureFin: json['dateHeureFin'] as String?,
      statut: json['statut'] as String? ?? 'CONFIRME',
      montantEstime: (json['montantEstime'] as num?)?.toDouble() ?? 0.0,
      dureeMinutes: json['dureeMinutes'] as int? ?? 60,
      motif: json['motif'] as String?,
      lignes: rawLignes
          .map((item) => LigneRendezVousModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'codeReference': codeReference,
    'salonSlug': salonSlug,
    'salonNom': salonNom,
    'salonAdresse': salonAdresse,
    'salonLogo': salonLogo,
    'salonCover': salonCover,
    'coiffeurNom': coiffeurNom,
    'coiffeurPrenom': coiffeurPrenom,
    'nomClient': nomClient,
    'prenomClient': prenomClient,
    'dateHeurePrevue': dateHeurePrevue,
    'dateHeureFin': dateHeureFin,
    'statut': statut,
    'montantEstime': montantEstime,
    'dureeMinutes': dureeMinutes,
    'motif': motif,
    'lignes': lignes.map((l) => l.toJson()).toList(),
  };
}
