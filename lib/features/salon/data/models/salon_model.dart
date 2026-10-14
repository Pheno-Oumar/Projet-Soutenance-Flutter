class SalonModel {
  final int id;
  final String nom;
  final String slug;
  final String? logoUrl;
  final String? coverUrl;
  final String? description;
  final String? adresse;
  final String? telephone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final bool statut;
  final double noteMoyenne;
  final int nombreAvis;

  const SalonModel({
    required this.id,
    required this.nom,
    required this.slug,
    this.logoUrl,
    this.coverUrl,
    this.description,
    this.adresse,
    this.telephone,
    this.email,
    this.latitude,
    this.longitude,
    this.statut = true,
    this.noteMoyenne = 4.8,
    this.nombreAvis = 12,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    return SalonModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      description: json['description'] as String?,
      adresse: json['adresse'] as String?,
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      statut: json['statut'] as bool? ?? true,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble() ?? 4.8,
      nombreAvis: json['nombreAvis'] as int? ?? 12,
    );
  }
}
