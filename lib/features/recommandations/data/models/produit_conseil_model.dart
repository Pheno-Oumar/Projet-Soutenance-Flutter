class ProduitConseilModel {
  final int id;
  final String nom;
  final String marque;
  final String description;
  final String modeUtilisation;
  final String? imageUrl;
  final String etapeRoutine; // LAVAGE, SOIN_PROFOND, HYDRATATION, FINITION
  final List<String> cuirsChevelusCibles;
  final List<String> etatsCheveuxCibles;
  final List<String> porositesCibles;
  final List<String> typesCheveuxCibles;
  final List<String> texturesCibles;
  final bool actif;
  final int? scoreAffinite; // Calculé par le moteur Spring Boot (0 à 100)

  const ProduitConseilModel({
    required this.id,
    required this.nom,
    required this.marque,
    required this.description,
    required this.modeUtilisation,
    this.imageUrl,
    required this.etapeRoutine,
    this.cuirsChevelusCibles = const [],
    this.etatsCheveuxCibles = const [],
    this.porositesCibles = const [],
    this.typesCheveuxCibles = const [],
    this.texturesCibles = const [],
    this.actif = true,
    this.scoreAffinite,
  });

  String get etapeLabel {
    switch (etapeRoutine.toUpperCase()) {
      case 'LAVAGE':
        return 'Étape 1 : Lavage';
      case 'SOIN_PROFOND':
        return 'Étape 2 : Soin Profond';
      case 'HYDRATATION':
        return 'Étape 3 : Hydratation';
      case 'FINITION':
        return 'Étape 4 : Finition';
      default:
        return 'Soin Spécifique';
    }
  }

  String get etapeShortLabel {
    switch (etapeRoutine.toUpperCase()) {
      case 'LAVAGE':
        return 'Lavage';
      case 'SOIN_PROFOND':
        return 'Soin Profond';
      case 'HYDRATATION':
        return 'Hydratation';
      case 'FINITION':
        return 'Finition';
      default:
        return etapeRoutine;
    }
  }

  factory ProduitConseilModel.fromJson(Map<String, dynamic> json, {int? score}) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ProduitConseilModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nom: json['nom'] as String? ?? 'Produit Soin',
      marque: json['marque'] as String? ?? 'Mon Salon',
      description: json['description'] as String? ?? '',
      modeUtilisation: json['modeUtilisation'] as String? ??
          'Appliquer délicatement sur cheveux mouillés ou essorés, masser doucement et rincer selon besoin.',
      imageUrl: json['imageUrl'] as String?,
      etapeRoutine: json['etapeRoutine'] as String? ?? 'LAVAGE',
      cuirsChevelusCibles: parseList(json['cuirsChevelusCibles']),
      etatsCheveuxCibles: parseList(json['etatsCheveuxCibles']),
      porositesCibles: parseList(json['porositesCibles']),
      typesCheveuxCibles: parseList(json['typesCheveuxCibles']),
      texturesCibles: parseList(json['texturesCibles']),
      actif: json['actif'] as bool? ?? true,
      scoreAffinite: score ?? (json['scoreAffinite'] is int ? json['scoreAffinite'] as int : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'marque': marque,
      'description': description,
      'modeUtilisation': modeUtilisation,
      'imageUrl': imageUrl,
      'etapeRoutine': etapeRoutine,
      'cuirsChevelusCibles': cuirsChevelusCibles,
      'etatsCheveuxCibles': etatsCheveuxCibles,
      'porositesCibles': porositesCibles,
      'typesCheveuxCibles': typesCheveuxCibles,
      'texturesCibles': texturesCibles,
      'actif': actif,
      'scoreAffinite': scoreAffinite,
    };
  }

  ProduitConseilModel copyWith({
    int? id,
    String? nom,
    String? marque,
    String? description,
    String? modeUtilisation,
    String? imageUrl,
    String? etapeRoutine,
    List<String>? cuirsChevelusCibles,
    List<String>? etatsCheveuxCibles,
    List<String>? porositesCibles,
    List<String>? typesCheveuxCibles,
    List<String>? texturesCibles,
    bool? actif,
    int? scoreAffinite,
  }) {
    return ProduitConseilModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      marque: marque ?? this.marque,
      description: description ?? this.description,
      modeUtilisation: modeUtilisation ?? this.modeUtilisation,
      imageUrl: imageUrl ?? this.imageUrl,
      etapeRoutine: etapeRoutine ?? this.etapeRoutine,
      cuirsChevelusCibles: cuirsChevelusCibles ?? this.cuirsChevelusCibles,
      etatsCheveuxCibles: etatsCheveuxCibles ?? this.etatsCheveuxCibles,
      porositesCibles: porositesCibles ?? this.porositesCibles,
      typesCheveuxCibles: typesCheveuxCibles ?? this.typesCheveuxCibles,
      texturesCibles: texturesCibles ?? this.texturesCibles,
      actif: actif ?? this.actif,
      scoreAffinite: scoreAffinite ?? this.scoreAffinite,
    );
  }
}
