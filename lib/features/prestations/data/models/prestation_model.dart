class LignePrestationModel {
  final int id;
  final int varianteServiceId;
  final String nomService;
  final String nomVariante;
  final double prix;
  final int dureeMinutes;
  final String? imageUrl;

  const LignePrestationModel({
    required this.id,
    required this.varianteServiceId,
    required this.nomService,
    required this.nomVariante,
    required this.prix,
    this.dureeMinutes = 30,
    this.imageUrl,
  });

  factory LignePrestationModel.fromJson(Map<String, dynamic> json) {
    return LignePrestationModel(
      id: json['id'] as int? ?? 0,
      varianteServiceId: json['varianteServiceId'] as int? ?? 0,
      nomService: json['nomService'] as String? ?? 'Service',
      nomVariante: json['nomVariante'] as String? ?? '',
      prix: (json['prixReel'] ?? json['prix'] as num?)?.toDouble() ?? 0.0,
      dureeMinutes: json['dureeMinutes'] as int? ?? 30,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'varianteServiceId': varianteServiceId,
      'nomService': nomService,
      'nomVariante': nomVariante,
      'prixReel': prix,
      'dureeMinutes': dureeMinutes,
      'imageUrl': imageUrl,
    };
  }
}

class PrestationModel {
  final int id;
  final String? codeReference;
  final String salonSlug;
  final String salonNom;
  final String salonAdresse;
  final String salonLogo;
  final String salonCover;
  final String? coiffeurNom;
  final String? coiffeurPrenom;
  final String? nomClient;
  final String? prenomClient;
  final String? telephoneClient;
  final String dateHeureDebut;
  final String? dateHeureFin;
  final String statut; // TERMINEE, ANNULEE
  final double montantTotal;
  final String? motifAnnulation;
  final String? modePaiement;
  final List<LignePrestationModel> lignes;

  const PrestationModel({
    required this.id,
    this.codeReference,
    required this.salonSlug,
    required this.salonNom,
    required this.salonAdresse,
    required this.salonLogo,
    required this.salonCover,
    this.coiffeurNom,
    this.coiffeurPrenom,
    this.nomClient,
    this.prenomClient,
    this.telephoneClient,
    required this.dateHeureDebut,
    this.dateHeureFin,
    required this.statut,
    required this.montantTotal,
    this.motifAnnulation,
    this.modePaiement = 'Paiement au salon',
    this.lignes = const [],
  });

  String get referenceCode => codeReference ?? '#PRES-2025-${id.toString().padLeft(4, '0')}';

  bool get isTerminee {
    final s = statut.toUpperCase();
    return s == 'TERMINEE' || s == 'TERMINE' || s == 'PASSE';
  }

  bool get isAnnulee {
    final s = statut.toUpperCase();
    return s == 'ANNULEE' || s == 'ANNULE';
  }

  String get statutLabel {
    if (isTerminee) return 'Terminée';
    if (isAnnulee) return 'Annulée';
    return statut;
  }

  String get dateHeureDebutFormatee {
    if (dateHeureDebut.isEmpty) return 'Date non définie';
    if (dateHeureDebut.contains('•')) return dateHeureDebut;
    try {
      final dt = DateTime.parse(dateHeureDebut);
      final j = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final a = dt.year;
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$j/$m/$a • $h:$min';
    } catch (_) {
      return dateHeureDebut;
    }
  }

  bool get hasMultipleVariants => lignes.length > 1;

  int get variantsCount => lignes.length;

  String get primaryNomService {
    if (lignes.isNotEmpty) {
      return lignes.first.nomService;
    }
    return 'Prestation';
  }

  String get primaryImageUrl {
    if (lignes.isNotEmpty && lignes.first.imageUrl != null) {
      return lignes.first.imageUrl!;
    }
    return 'assets/images/prestation_soin.jpg';
  }

  String? get coiffeurComplet {
    if (coiffeurPrenom != null && coiffeurNom != null) {
      return '$coiffeurPrenom $coiffeurNom';
    }
    return coiffeurPrenom ?? coiffeurNom;
  }

  factory PrestationModel.fromJson(Map<String, dynamic> json) {
    final lignesList = (json['lignes'] as List<dynamic>?)
            ?.map((e) => LignePrestationModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PrestationModel(
      id: json['id'] as int? ?? 0,
      codeReference: json['codeReference'] as String?,
      salonSlug: json['salonSlug'] as String? ?? '',
      salonNom: json['salonNom'] as String? ?? 'Salon',
      salonAdresse: json['salonAdresse'] as String? ?? '',
      salonLogo: json['salonLogo'] as String? ?? 'assets/images/rdv_tous_0.png',
      salonCover: json['salonCover'] as String? ?? 'assets/images/rdv_dt_passe_0.jpeg',
      coiffeurNom: json['coiffeurNom'] as String?,
      coiffeurPrenom: json['coiffeurPrenom'] as String?,
      nomClient: json['nomClient'] as String?,
      prenomClient: json['prenomClient'] as String?,
      telephoneClient: json['telephoneClient'] as String?,
      dateHeureDebut: json['dateHeureDebut'] as String? ?? '',
      dateHeureFin: json['dateHeureFin'] as String?,
      statut: json['statut'] as String? ?? 'TERMINEE',
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      motifAnnulation: json['motifAnnulation'] as String?,
      modePaiement: json['modePaiement'] as String? ?? 'Paiement au salon',
      lignes: lignesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codeReference': referenceCode,
      'salonSlug': salonSlug,
      'salonNom': salonNom,
      'salonAdresse': salonAdresse,
      'salonLogo': salonLogo,
      'salonCover': salonCover,
      'coiffeurNom': coiffeurNom,
      'coiffeurPrenom': coiffeurPrenom,
      'nomClient': nomClient,
      'prenomClient': prenomClient,
      'telephoneClient': telephoneClient,
      'dateHeureDebut': dateHeureDebut,
      'dateHeureFin': dateHeureFin,
      'statut': statut,
      'montantTotal': montantTotal,
      'motifAnnulation': motifAnnulation,
      'modePaiement': modePaiement,
      'lignes': lignes.map((e) => e.toJson()).toList(),
    };
  }
}
