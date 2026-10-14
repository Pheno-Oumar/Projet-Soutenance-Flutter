class ProfilCapillaireModel {
  final int? id;
  final int? compteId;
  final String? nomClient;
  final String? prenomClient;
  final String? typeCheveux;
  final String? texture;
  final String? porosite;
  final String? longueur;
  final String? densite;
  final String? cuirChevelu;
  final String? etatCheveux;
  final bool hasCodeProfil;
  final DateTime? dateCreation;
  final DateTime? dateMiseAJour;

  const ProfilCapillaireModel({
    this.id,
    this.compteId,
    this.nomClient,
    this.prenomClient,
    this.typeCheveux,
    this.texture,
    this.porosite,
    this.longueur,
    this.densite,
    this.cuirChevelu,
    this.etatCheveux,
    this.hasCodeProfil = false,
    this.dateCreation,
    this.dateMiseAJour,
  });

  bool get isComplet =>
      typeCheveux != null &&
      texture != null &&
      porosite != null &&
      cuirChevelu != null &&
      etatCheveux != null;

  factory ProfilCapillaireModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val is String) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return ProfilCapillaireModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      compteId: json['compteId'] is int ? json['compteId'] : int.tryParse(json['compteId']?.toString() ?? ''),
      nomClient: json['nomClient'] as String?,
      prenomClient: json['prenomClient'] as String?,
      typeCheveux: json['typeCheveux']?.toString(),
      texture: json['texture']?.toString(),
      porosite: json['porosite']?.toString(),
      longueur: json['longueur']?.toString(),
      densite: json['densite']?.toString(),
      cuirChevelu: json['cuirChevelu']?.toString(),
      etatCheveux: json['etatCheveux']?.toString(),
      hasCodeProfil: json['hasCodeProfil'] as bool? ?? false,
      dateCreation: parseDate(json['dateCreation']),
      dateMiseAJour: parseDate(json['dateMiseAJour']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeCheveux': typeCheveux,
      'texture': texture,
      'porosite': porosite,
      'longueur': longueur,
      'densite': densite,
      'cuirChevelu': cuirChevelu,
      'etatCheveux': etatCheveux,
    };
  }

  ProfilCapillaireModel copyWith({
    int? id,
    int? compteId,
    String? nomClient,
    String? prenomClient,
    String? typeCheveux,
    String? texture,
    String? porosite,
    String? longueur,
    String? densite,
    String? cuirChevelu,
    String? etatCheveux,
    bool? hasCodeProfil,
    DateTime? dateCreation,
    DateTime? dateMiseAJour,
  }) {
    return ProfilCapillaireModel(
      id: id ?? this.id,
      compteId: compteId ?? this.compteId,
      nomClient: nomClient ?? this.nomClient,
      prenomClient: prenomClient ?? this.prenomClient,
      typeCheveux: typeCheveux ?? this.typeCheveux,
      texture: texture ?? this.texture,
      porosite: porosite ?? this.porosite,
      longueur: longueur ?? this.longueur,
      densite: densite ?? this.densite,
      cuirChevelu: cuirChevelu ?? this.cuirChevelu,
      etatCheveux: etatCheveux ?? this.etatCheveux,
      hasCodeProfil: hasCodeProfil ?? this.hasCodeProfil,
      dateCreation: dateCreation ?? this.dateCreation,
      dateMiseAJour: dateMiseAJour ?? this.dateMiseAJour,
    );
  }
}
