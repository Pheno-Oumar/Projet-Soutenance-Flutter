import 'produit_conseil_model.dart';

class RecommandationCapillaireModel {
  final int id;
  final String reference;
  final DateTime dateRecommandation;
  final String? typeCheveux;
  final String? texture;
  final String? porosite;
  final String? longueur;
  final String? densite;
  final String? cuirChevelu;
  final String? etatCheveux;
  final ProduitConseilModel? produitLavage;
  final ProduitConseilModel? produitSoinProfond;
  final ProduitConseilModel? produitHydratation;
  final ProduitConseilModel? produitFinition;
  final int scoreLavage;
  final int scoreSoinProfond;
  final int scoreHydratation;
  final int scoreFinition;
  final int scoreGlobal;
  final String? conseilsPersonnalises;
  final int? joursRestantsAvantProchainDiagnostic;

  const RecommandationCapillaireModel({
    required this.id,
    required this.reference,
    required this.dateRecommandation,
    this.typeCheveux,
    this.texture,
    this.porosite,
    this.longueur,
    this.densite,
    this.cuirChevelu,
    this.etatCheveux,
    this.produitLavage,
    this.produitSoinProfond,
    this.produitHydratation,
    this.produitFinition,
    this.scoreLavage = 90,
    this.scoreSoinProfond = 90,
    this.scoreHydratation = 90,
    this.scoreFinition = 90,
    this.scoreGlobal = 90,
    this.conseilsPersonnalises,
    this.joursRestantsAvantProchainDiagnostic,
  });

  bool get isCooldownActive =>
      joursRestantsAvantProchainDiagnostic != null &&
      joursRestantsAvantProchainDiagnostic! > 0;

  List<ProduitConseilModel> get tousLesProduits {
    final list = <ProduitConseilModel>[];
    if (produitLavage != null) list.add(produitLavage!);
    if (produitSoinProfond != null) list.add(produitSoinProfond!);
    if (produitHydratation != null) list.add(produitHydratation!);
    if (produitFinition != null) list.add(produitFinition!);
    return list;
  }

  factory RecommandationCapillaireModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final scoreL = json['scoreLavage'] as int? ?? 90;
    final scoreS = json['scoreSoinProfond'] as int? ?? 90;
    final scoreH = json['scoreHydratation'] as int? ?? 90;
    final scoreF = json['scoreFinition'] as int? ?? 90;

    return RecommandationCapillaireModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      reference: json['reference'] as String? ?? 'REC-2026-DIAG',
      dateRecommandation: parseDate(json['dateRecommandation']),
      typeCheveux: json['typeCheveux']?.toString(),
      texture: json['texture']?.toString(),
      porosite: json['porosite']?.toString(),
      longueur: json['longueur']?.toString(),
      densite: json['densite']?.toString(),
      cuirChevelu: json['cuirChevelu']?.toString(),
      etatCheveux: json['etatCheveux']?.toString(),
      produitLavage: json['produitLavage'] != null
          ? ProduitConseilModel.fromJson(json['produitLavage'] as Map<String, dynamic>, score: scoreL)
          : null,
      produitSoinProfond: json['produitSoinProfond'] != null
          ? ProduitConseilModel.fromJson(json['produitSoinProfond'] as Map<String, dynamic>, score: scoreS)
          : null,
      produitHydratation: json['produitHydratation'] != null
          ? ProduitConseilModel.fromJson(json['produitHydratation'] as Map<String, dynamic>, score: scoreH)
          : null,
      produitFinition: json['produitFinition'] != null
          ? ProduitConseilModel.fromJson(json['produitFinition'] as Map<String, dynamic>, score: scoreF)
          : null,
      scoreLavage: scoreL,
      scoreSoinProfond: scoreS,
      scoreHydratation: scoreH,
      scoreFinition: scoreF,
      scoreGlobal: json['scoreGlobal'] as int? ?? ((scoreL + scoreS + scoreH + scoreF) ~/ 4),
      conseilsPersonnalises: json['conseilsPersonnalises'] as String?,
      joursRestantsAvantProchainDiagnostic:
          json['joursRestantsAvantProchainDiagnostic'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'dateRecommandation': dateRecommandation.toIso8601String(),
      'typeCheveux': typeCheveux,
      'texture': texture,
      'porosite': porosite,
      'longueur': longueur,
      'densite': densite,
      'cuirChevelu': cuirChevelu,
      'etatCheveux': etatCheveux,
      'produitLavage': produitLavage?.toJson(),
      'produitSoinProfond': produitSoinProfond?.toJson(),
      'produitHydratation': produitHydratation?.toJson(),
      'produitFinition': produitFinition?.toJson(),
      'scoreLavage': scoreLavage,
      'scoreSoinProfond': scoreSoinProfond,
      'scoreHydratation': scoreHydratation,
      'scoreFinition': scoreFinition,
      'scoreGlobal': scoreGlobal,
      'conseilsPersonnalises': conseilsPersonnalises,
      'joursRestantsAvantProchainDiagnostic':
          joursRestantsAvantProchainDiagnostic,
    };
  }
}
