class EligibiliteSuppressionModel {
  final bool eligible;
  final List<String> motifsIneligibilite;
  final bool demandeEnCours;

  const EligibiliteSuppressionModel({
    required this.eligible,
    required this.motifsIneligibilite,
    required this.demandeEnCours,
  });

  factory EligibiliteSuppressionModel.fromJson(Map<String, dynamic> json) {
    return EligibiliteSuppressionModel(
      eligible: json['eligible'] as bool? ?? false,
      motifsIneligibilite: (json['motifsIneligibilite'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      demandeEnCours: json['demandeEnCours'] as bool? ?? false,
    );
  }
}

class DemandeSuppressionModel {
  final int id;
  final int? compteId;
  final String? email;
  final String? motif;
  final String statut; // EN_ATTENTE, APPROUVEE, REJETEE
  final DateTime? dateDemande;
  final DateTime? dateDecision;
  final String? motifDecision;
  final String? traitePar;

  const DemandeSuppressionModel({
    required this.id,
    this.compteId,
    this.email,
    this.motif,
    required this.statut,
    this.dateDemande,
    this.dateDecision,
    this.motifDecision,
    this.traitePar,
  });

  factory DemandeSuppressionModel.fromJson(Map<String, dynamic> json) {
    return DemandeSuppressionModel(
      id: json['id'] as int? ?? 0,
      compteId: json['compteId'] as int?,
      email: json['email'] as String?,
      motif: json['motif'] as String?,
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      dateDemande: json['dateDemande'] != null
          ? DateTime.tryParse(json['dateDemande'].toString())
          : null,
      dateDecision: json['dateDecision'] != null
          ? DateTime.tryParse(json['dateDecision'].toString())
          : null,
      motifDecision: json['motifDecision'] as String?,
      traitePar: json['traitePar'] as String?,
    );
  }
}

class DemandeExportModel {
  final int id;
  final String? email;
  final String format; // JSON, CSV
  final String statut; // EN_ATTENTE, DISPONIBLE, EXPIRE
  final String? urlTelechargement;
  final DateTime? dateDemande;
  final DateTime? dateExpiration;
  final bool expire;

  const DemandeExportModel({
    required this.id,
    this.email,
    required this.format,
    required this.statut,
    this.urlTelechargement,
    this.dateDemande,
    this.dateExpiration,
    required this.expire,
  });

  factory DemandeExportModel.fromJson(Map<String, dynamic> json) {
    return DemandeExportModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String?,
      format: json['format'] as String? ?? 'JSON',
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      urlTelechargement: json['urlTelechargement'] as String?,
      dateDemande: json['dateDemande'] != null
          ? DateTime.tryParse(json['dateDemande'].toString())
          : null,
      dateExpiration: json['dateExpiration'] != null
          ? DateTime.tryParse(json['dateExpiration'].toString())
          : null,
      expire: json['expire'] as bool? ?? false,
    );
  }
}
