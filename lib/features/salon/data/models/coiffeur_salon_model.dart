class CoiffeurSalonModel {
  final int id;
  final int? affectationId;
  final String? coiffeurNom;
  final String? coiffeurPrenom;
  final String nomAffichage;
  final String? biographie;
  final int anneeExperience;
  final String? photoProfilUrl;
  final String? description;
  final bool available;

  const CoiffeurSalonModel({
    required this.id,
    this.affectationId,
    this.coiffeurNom,
    this.coiffeurPrenom,
    required this.nomAffichage,
    this.biographie,
    this.anneeExperience = 3,
    this.photoProfilUrl,
    this.description,
    this.available = true,
  });

  String get displayName {
    if (nomAffichage.isNotEmpty) return nomAffichage;
    final parts = [coiffeurPrenom, coiffeurNom].where((s) => s != null && s.isNotEmpty);
    if (parts.isNotEmpty) return parts.join(' ');
    return 'Coiffeur Professionnel';
  }

  factory CoiffeurSalonModel.fromJson(Map<String, dynamic> json) {
    return CoiffeurSalonModel(
      id: json['id'] as int? ?? 0,
      affectationId: json['affectationId'] as int?,
      coiffeurNom: json['coiffeurNom'] as String?,
      coiffeurPrenom: json['coiffeurPrenom'] as String?,
      nomAffichage: json['nomAffichage'] as String? ?? '',
      biographie: json['biographie'] as String?,
      anneeExperience: json['anneeExperience'] as int? ?? 3,
      photoProfilUrl: json['photoProfilUrl'] as String?,
      description: json['description'] as String?,
      available: json['available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'affectationId': affectationId,
      'coiffeurNom': coiffeurNom,
      'coiffeurPrenom': coiffeurPrenom,
      'nomAffichage': nomAffichage,
      'biographie': biographie,
      'anneeExperience': anneeExperience,
      'photoProfilUrl': photoProfilUrl,
      'description': description,
      'available': available,
    };
  }
}
