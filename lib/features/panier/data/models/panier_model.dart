class LignePanierModel {
  final int id;
  final int produitId;
  final String produitNom;
  final String? imageUrl;
  final double prixUnitaire;
  final int quantite;
  final double sousTotal;
  final int stockDisponible;
  final bool enAlerte;

  const LignePanierModel({
    required this.id,
    required this.produitId,
    required this.produitNom,
    this.imageUrl,
    required this.prixUnitaire,
    required this.quantite,
    required this.sousTotal,
    this.stockDisponible = 0,
    this.enAlerte = false,
  });

  factory LignePanierModel.fromJson(Map<String, dynamic> json) {
    return LignePanierModel(
      id: json['id'] as int? ?? 0,
      produitId: json['produitId'] as int? ?? 0,
      produitNom: json['produitNom'] as String? ?? 'Produit',
      imageUrl: json['imageUrl'] as String?,
      prixUnitaire: (json['prixUnitaire'] as num?)?.toDouble() ?? 0.0,
      quantite: json['quantite'] as int? ?? 1,
      sousTotal: (json['sousTotal'] as num?)?.toDouble() ?? 0.0,
      stockDisponible: json['stockDisponible'] as int? ?? 0,
      enAlerte: json['enAlerte'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produitId': produitId,
      'produitNom': produitNom,
      'imageUrl': imageUrl,
      'prixUnitaire': prixUnitaire,
      'quantite': quantite,
      'sousTotal': sousTotal,
      'stockDisponible': stockDisponible,
      'enAlerte': enAlerte,
    };
  }

  LignePanierModel copyWith({
    int? quantite,
    double? sousTotal,
  }) {
    return LignePanierModel(
      id: id,
      produitId: produitId,
      produitNom: produitNom,
      imageUrl: imageUrl,
      prixUnitaire: prixUnitaire,
      quantite: quantite ?? this.quantite,
      sousTotal: sousTotal ?? (prixUnitaire * (quantite ?? this.quantite)),
      stockDisponible: stockDisponible,
      enAlerte: enAlerte,
    );
  }
}

class PanierModel {
  final int id;
  final String? slugSalon;
  final String? salonNom;
  final String? clientEmail;
  final List<LignePanierModel> lignes;
  final double montantTotal;
  final int nombreArticles;

  const PanierModel({
    required this.id,
    this.slugSalon,
    this.salonNom,
    this.clientEmail,
    this.lignes = const [],
    this.montantTotal = 0.0,
    this.nombreArticles = 0,
  });

  factory PanierModel.fromJson(Map<String, dynamic> json) {
    final rawLignes = json['lignes'] as List<dynamic>? ?? [];
    final lignesList = rawLignes
        .map((item) => LignePanierModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final slug = json['slugSalon'] as String?;
    final nom = json['nomSalon'] as String? ?? json['salonNom'] as String? ?? slug;

    final total = (json['montantTotal'] as num?)?.toDouble() ??
        lignesList.fold<double>(0.0, (sum, l) => sum + l.sousTotal);
    final count = json['nombreArticles'] as int? ??
        lignesList.fold<int>(0, (sum, l) => sum + l.quantite);

    return PanierModel(
      id: json['id'] as int? ?? 0,
      slugSalon: slug,
      salonNom: nom,
      clientEmail: json['clientEmail'] as String?,
      lignes: lignesList,
      montantTotal: total,
      nombreArticles: count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slugSalon': slugSalon,
      'salonNom': salonNom,
      'clientEmail': clientEmail,
      'lignes': lignes.map((l) => l.toJson()).toList(),
      'montantTotal': montantTotal,
      'nombreArticles': nombreArticles,
    };
  }

  PanierModel copyWith({
    List<LignePanierModel>? lignes,
    double? montantTotal,
    int? nombreArticles,
  }) {
    return PanierModel(
      id: id,
      slugSalon: slugSalon,
      salonNom: salonNom,
      clientEmail: clientEmail,
      lignes: lignes ?? this.lignes,
      montantTotal: montantTotal ?? this.montantTotal,
      nombreArticles: nombreArticles ?? this.nombreArticles,
    );
  }
}
