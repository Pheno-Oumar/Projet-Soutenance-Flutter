class KadysModel {
  final int id;
  final String titre;
  final String? description;
  final String? urlVideo;
  final String? salonSlug;
  final String? salonNom;
  final String? salonLogoUrl;
  final int? coiffeurId;
  final String? coiffeurNomComplet;
  final int totalLikes;
  final int totalCommentaires;
  final int totalVues;
  final bool isLikedByCurrentUser;

  const KadysModel({
    required this.id,
    required this.titre,
    this.description,
    this.urlVideo,
    this.salonSlug,
    this.salonNom,
    this.salonLogoUrl,
    this.coiffeurId,
    this.coiffeurNomComplet,
    this.totalLikes = 0,
    this.totalCommentaires = 0,
    this.totalVues = 0,
    this.isLikedByCurrentUser = false,
  });

  factory KadysModel.fromJson(Map<String, dynamic> json) {
    return KadysModel(
      id: json['id'] as int? ?? 0,
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String?,
      urlVideo: json['urlVideo'] as String?,
      salonSlug: json['salonSlug'] as String?,
      salonNom: json['salonNom'] as String?,
      salonLogoUrl: json['salonLogoUrl'] as String?,
      coiffeurId: json['coiffeurId'] as int?,
      coiffeurNomComplet: json['coiffeurNomComplet'] as String?,
      totalLikes: json['totalLikes'] as int? ?? 0,
      totalCommentaires: json['totalCommentaires'] as int? ?? 0,
      totalVues: json['totalVues'] as int? ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool? ?? false,
    );
  }

  KadysModel copyWith({
    int? id,
    String? titre,
    String? description,
    String? urlVideo,
    String? salonSlug,
    String? salonNom,
    String? salonLogoUrl,
    int? coiffeurId,
    String? coiffeurNomComplet,
    int? totalLikes,
    int? totalCommentaires,
    int? totalVues,
    bool? isLikedByCurrentUser,
  }) {
    return KadysModel(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      urlVideo: urlVideo ?? this.urlVideo,
      salonSlug: salonSlug ?? this.salonSlug,
      salonNom: salonNom ?? this.salonNom,
      salonLogoUrl: salonLogoUrl ?? this.salonLogoUrl,
      coiffeurId: coiffeurId ?? this.coiffeurId,
      coiffeurNomComplet: coiffeurNomComplet ?? this.coiffeurNomComplet,
      totalLikes: totalLikes ?? this.totalLikes,
      totalCommentaires: totalCommentaires ?? this.totalCommentaires,
      totalVues: totalVues ?? this.totalVues,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }
}
