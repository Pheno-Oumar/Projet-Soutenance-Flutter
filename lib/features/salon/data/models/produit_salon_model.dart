class StockProduitModel {
  final int id;
  final int quantiteDisponible;
  final int seuilMinimum;
  final int? seuilMaximum;
  final bool alerteStockBas;
  final DateTime? dateDerniereMiseAJour;

  const StockProduitModel({
    required this.id,
    this.quantiteDisponible = 0,
    this.seuilMinimum = 0,
    this.seuilMaximum,
    this.alerteStockBas = false,
    this.dateDerniereMiseAJour,
  });

  factory StockProduitModel.fromJson(Map<String, dynamic> json) {
    return StockProduitModel(
      id: json['id'] as int? ?? 0,
      quantiteDisponible: json['quantiteDisponible'] as int? ?? 0,
      seuilMinimum: json['seuilMinimum'] as int? ?? 0,
      seuilMaximum: json['seuilMaximum'] as int?,
      alerteStockBas: json['alerteStockBas'] as bool? ?? false,
      dateDerniereMiseAJour: json['dateDerniereMiseAJour'] != null
          ? DateTime.tryParse(json['dateDerniereMiseAJour'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantiteDisponible': quantiteDisponible,
      'seuilMinimum': seuilMinimum,
      'seuilMaximum': seuilMaximum,
      'alerteStockBas': alerteStockBas,
      'dateDerniereMiseAJour': dateDerniereMiseAJour?.toIso8601String(),
    };
  }
}

class ProduitSalonModel {
  final int id;
  final String nom;
  final String? description;
  final double prixVente;
  final String? imageUrl;
  final List<String> imagesUrls;
  final bool statut;
  final int? categorieId;
  final String? categorieNom;
  final StockProduitModel? stock;
  final DateTime? dateCreation;
  final DateTime? dateModification;
  final String? slugSalon;
  final String? salonNom;

  const ProduitSalonModel({
    required this.id,
    required this.nom,
    this.description,
    this.prixVente = 0.0,
    this.imageUrl,
    this.imagesUrls = const [],
    this.statut = true,
    this.categorieId,
    this.categorieNom,
    this.stock,
    this.dateCreation,
    this.dateModification,
    this.slugSalon,
    this.salonNom,
  });

  String? get mainImage {
    if (imagesUrls.isNotEmpty) return imagesUrls.first;
    return imageUrl;
  }

  int get quantiteEnStock => stock?.quantiteDisponible ?? 0;
  bool get isEnRupture => quantiteEnStock <= 0;

  factory ProduitSalonModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imagesUrls'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages.map((e) => e.toString()).toList();
    } else if (json['imageUrl'] != null) {
      parsedImages = [json['imageUrl'].toString()];
    }

    return ProduitSalonModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      prixVente: (json['prixVente'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      imagesUrls: parsedImages,
      statut: json['statut'] as bool? ?? true,
      categorieId: json['categorieId'] as int?,
      categorieNom: json['categorieNom'] as String?,
      stock: json['stock'] != null && json['stock'] is Map<String, dynamic>
          ? StockProduitModel.fromJson(json['stock'] as Map<String, dynamic>)
          : null,
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
      dateModification: json['dateModification'] != null
          ? DateTime.tryParse(json['dateModification'].toString())
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
      'prixVente': prixVente,
      'imageUrl': imageUrl,
      'imagesUrls': imagesUrls,
      'statut': statut,
      'categorieId': categorieId,
      'categorieNom': categorieNom,
      'stock': stock?.toJson(),
      'dateCreation': dateCreation?.toIso8601String(),
      'dateModification': dateModification?.toIso8601String(),
      'slugSalon': slugSalon,
      'salonNom': salonNom,
    };
  }
}

class CategorieProduitModel {
  final int id;
  final String nom;
  final String? description;
  final String? imageUrl;
  final bool statut;
  final String? salonSlug;
  final int nombreProduits;
  final List<ProduitSalonModel> produits;

  const CategorieProduitModel({
    required this.id,
    required this.nom,
    this.description,
    this.imageUrl,
    this.statut = true,
    this.salonSlug,
    this.nombreProduits = 0,
    this.produits = const [],
  });

  factory CategorieProduitModel.fromJson(Map<String, dynamic> json) {
    return CategorieProduitModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      statut: json['statut'] as bool? ?? true,
      salonSlug: json['salonSlug'] as String?,
      nombreProduits: json['nombreProduits'] as int? ??
          (json['produits'] is List ? (json['produits'] as List).length : 0),
      produits: (json['produits'] as List<dynamic>?)
              ?.map(
                  (p) => ProduitSalonModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'imageUrl': imageUrl,
      'statut': statut,
      'salonSlug': salonSlug,
      'nombreProduits': nombreProduits,
      'produits': produits.map((p) => p.toJson()).toList(),
    };
  }
}
