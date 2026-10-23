class ServiceSalonModel {
  final int id;
  final String nom;
  final String? description;
  final String? imageUrl;
  final bool statut;
  final List<VarianteServiceModel> variantes;
  final DateTime? dateCreation;
  final String? slugSalon;
  final String? salonNom;

  const ServiceSalonModel({
    required this.id,
    required this.nom,
    this.description,
    this.imageUrl,
    this.statut = true,
    this.variantes = const [],
    this.dateCreation,
    this.slugSalon,
    this.salonNom,
  });

  /// Prix minimum parmi toutes les variantes actives de ce service
  double get minPrix {
    if (variantes.isEmpty) return 0.0;
    return variantes
        .where((v) => v.statut)
        .map((v) => v.prix)
        .fold<double>(double.infinity, (min, p) => p < min ? p : min);
  }

  factory ServiceSalonModel.fromJson(Map<String, dynamic> json) {
    return ServiceSalonModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      statut: json['statut'] as bool? ?? true,
      variantes: (json['variantes'] as List<dynamic>?)
              ?.map((v) =>
                  VarianteServiceModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          const [],
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
      slugSalon: json['slugSalon'] as String?,
      salonNom: json['salonNom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'imageUrl': imageUrl,
      'statut': statut,
      'variantes': variantes.map((v) => v.toJson()).toList(),
      'dateCreation': dateCreation?.toIso8601String(),
      'slugSalon': slugSalon,
      'salonNom': salonNom,
    };
  }
}

class VarianteServiceModel {
  final int id;
  final String nom;
  final String? description;
  final int dureeMinutes;
  final double prix;
  final String? imageUrl;
  final List<String> imagesUrls;
  final bool statut;

  const VarianteServiceModel({
    required this.id,
    required this.nom,
    this.description,
    this.dureeMinutes = 30,
    this.prix = 0.0,
    this.imageUrl,
    this.imagesUrls = const [],
    this.statut = true,
  });

  /// Image principale (première de la liste ou champ imageUrl)
  String? get mainImage {
    if (imagesUrls.isNotEmpty) return imagesUrls.first;
    return imageUrl;
  }

  factory VarianteServiceModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imagesUrls'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages.map((e) => e.toString()).toList();
    } else if (json['imageUrl'] != null) {
      parsedImages = [json['imageUrl'].toString()];
    }

    return VarianteServiceModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      dureeMinutes: json['dureeMinutes'] as int? ?? 30,
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      imagesUrls: parsedImages,
      statut: json['statut'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'dureeMinutes': dureeMinutes,
      'prix': prix,
      'imageUrl': imageUrl,
      'imagesUrls': imagesUrls,
      'statut': statut,
    };
  }
}
