class LignePanierModel {
  final int id;
  final int produitId;
  final String produitNom;
  final double prixUnitaire;
  final int quantite;
  final double sousTotal;
  final int stockDisponible;
  final bool enAlerte;

  const LignePanierModel({
    required this.id,
    required this.produitId,
    required this.produitNom,
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
      produitNom: json['produitNom'] as String? ?? '',
      prixUnitaire: (json['prixUnitaire'] as num?)?.toDouble() ?? 0.0,
      quantite: json['quantite'] as int? ?? 1,
      sousTotal: (json['sousTotal'] as num?)?.toDouble() ?? 0.0,
      stockDisponible: json['stockDisponible'] as int? ?? 0,
      enAlerte: json['enAlerte'] as bool? ?? false,
    );
  }
}

class PanierModel {
  final int id;
  final String? slugSalon;
  final String? clientEmail;
  final List<LignePanierModel> lignes;
  final double montantTotal;
  final int nombreArticles;

  const PanierModel({
    required this.id,
    this.slugSalon,
    this.clientEmail,
    this.lignes = const [],
    this.montantTotal = 0.0,
    this.nombreArticles = 0,
  });

  factory PanierModel.fromJson(Map<String, dynamic> json) {
    final rawLignes = json['lignes'] as List<dynamic>? ?? [];
    return PanierModel(
      id: json['id'] as int? ?? 0,
      slugSalon: json['slugSalon'] as String?,
      clientEmail: json['clientEmail'] as String?,
      lignes: rawLignes
          .map((item) => LignePanierModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      nombreArticles: json['nombreArticles'] as int? ?? 0,
    );
  }
}
