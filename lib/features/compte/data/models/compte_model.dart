class CompteModel {
  final int id;
  final String nom;
  final String prenom;
  final String? dateNaissance;
  final String? email;
  final String? telephone;
  final String? pays;
  final bool statut;
  final String rolePlateforme;

  const CompteModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.dateNaissance,
    this.email,
    this.telephone,
    this.pays,
    this.statut = true,
    this.rolePlateforme = 'CLIENT',
  });

  String get nomComplet => '$prenom $nom'.trim();

  factory CompteModel.fromJson(Map<String, dynamic> json) {
    return CompteModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      dateNaissance: json['dateNaissance'] as String?,
      email: json['email'] as String?,
      telephone: json['telephone'] as String?,
      pays: json['pays'] as String?,
      statut: json['statut'] as bool? ?? true,
      rolePlateforme: json['rolePlateforme'] as String? ?? 'CLIENT',
    );
  }
}
