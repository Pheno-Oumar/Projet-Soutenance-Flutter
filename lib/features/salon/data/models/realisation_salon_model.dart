class RealisationSalonModel {
  final int id;
  final String titre;
  final String? description;
  final String? urlVideo;
  final DateTime? dateRealisation;
  final DateTime? datePublication;
  final bool statutPublication;
  final String? salonSlug;
  final String? salonNom;
  final int? coiffeurId;
  final String? coiffeurNomComplet;
  final int totalLikes;
  final int totalCommentaires;
  final int totalVues;

  const RealisationSalonModel({
    required this.id,
    required this.titre,
    this.description,
    this.urlVideo,
    this.dateRealisation,
    this.datePublication,
    this.statutPublication = true,
    this.salonSlug,
    this.salonNom,
    this.coiffeurId,
    this.coiffeurNomComplet,
    this.totalLikes = 0,
    this.totalCommentaires = 0,
    this.totalVues = 0,
  });

  factory RealisationSalonModel.fromJson(Map<String, dynamic> json) {
    return RealisationSalonModel(
      id: json['id'] as int? ?? 0,
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String?,
      urlVideo: json['urlVideo'] as String?,
      dateRealisation: json['dateRealisation'] != null
          ? DateTime.tryParse(json['dateRealisation'].toString())
          : null,
      datePublication: json['datePublication'] != null
          ? DateTime.tryParse(json['datePublication'].toString())
          : null,
      statutPublication: json['statutPublication'] as bool? ?? true,
      salonSlug: json['salonSlug'] as String?,
      salonNom: json['salonNom'] as String?,
      coiffeurId: json['coiffeurId'] as int?,
      coiffeurNomComplet: json['coiffeurNomComplet'] as String?,
      totalLikes: json['totalLikes'] as int? ?? 0,
      totalCommentaires: json['totalCommentaires'] as int? ?? 0,
      totalVues: json['totalVues'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'urlVideo': urlVideo,
      'dateRealisation': dateRealisation?.toIso8601String(),
      'datePublication': datePublication?.toIso8601String(),
      'statutPublication': statutPublication,
      'salonSlug': salonSlug,
      'salonNom': salonNom,
      'coiffeurId': coiffeurId,
      'coiffeurNomComplet': coiffeurNomComplet,
      'totalLikes': totalLikes,
      'totalCommentaires': totalCommentaires,
      'totalVues': totalVues,
    };
  }
}
