class LignePrestationPanierModel {
  final int varianteId;
  final int? serviceId;
  final String serviceNom;
  final String varianteNom;
  final double prix;
  final int dureeMinutes;
  final String? imageUrl;

  const LignePrestationPanierModel({
    required this.varianteId,
    this.serviceId,
    required this.serviceNom,
    required this.varianteNom,
    required this.prix,
    this.dureeMinutes = 45,
    this.imageUrl,
  });

  factory LignePrestationPanierModel.fromJson(Map<String, dynamic> json) {
    return LignePrestationPanierModel(
      varianteId: json['varianteId'] as int? ?? 0,
      serviceId: json['serviceId'] as int?,
      serviceNom: json['serviceNom'] as String? ?? 'Prestation',
      varianteNom: json['varianteNom'] as String? ?? 'Variante',
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      dureeMinutes: json['dureeMinutes'] as int? ?? 45,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'varianteId': varianteId,
      'serviceId': serviceId,
      'serviceNom': serviceNom,
      'varianteNom': varianteNom,
      'prix': prix,
      'dureeMinutes': dureeMinutes,
      'imageUrl': imageUrl,
    };
  }

  String get dureeFormatee {
    if (dureeMinutes <= 0) return '0 min';
    final h = dureeMinutes ~/ 60;
    final m = dureeMinutes % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '${h}h';
    return '${h}h ${m < 10 ? '0' : ''}${m}m';
  }
}

class SalonRendezVousPanierModel {
  final String slugSalon;
  final String salonNom;
  final String? salonLogo;
  final List<LignePrestationPanierModel> prestations;
  final DateTime? dateHeurePrevue;
  final int? coiffeurId;
  final String? coiffeurNom;
  final String? notes;

  const SalonRendezVousPanierModel({
    required this.slugSalon,
    required this.salonNom,
    this.salonLogo,
    this.prestations = const [],
    this.dateHeurePrevue,
    this.coiffeurId,
    this.coiffeurNom,
    this.notes,
  });

  double get montantTotal =>
      prestations.fold<double>(0.0, (sum, p) => sum + p.prix);

  int get dureeTotaleMinutes =>
      prestations.fold<int>(0, (sum, p) => sum + p.dureeMinutes);

  String get dureeTotaleFormatee {
    if (dureeTotaleMinutes <= 0) return '0 min';
    final h = dureeTotaleMinutes ~/ 60;
    final m = dureeTotaleMinutes % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '${h}h';
    return '${h}h ${m < 10 ? '0' : ''}${m}m';
  }

  factory SalonRendezVousPanierModel.fromJson(Map<String, dynamic> json) {
    final rawPrestas = json['prestations'] as List<dynamic>? ?? [];
    return SalonRendezVousPanierModel(
      slugSalon: json['slugSalon'] as String? ?? '',
      salonNom: json['salonNom'] as String? ?? 'Salon de beauté',
      salonLogo: json['salonLogo'] as String?,
      prestations: rawPrestas
          .map((item) => LignePrestationPanierModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      dateHeurePrevue: json['dateHeurePrevue'] != null
          ? DateTime.tryParse(json['dateHeurePrevue'] as String)
          : null,
      coiffeurId: json['coiffeurId'] as int?,
      coiffeurNom: json['coiffeurNom'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slugSalon': slugSalon,
      'salonNom': salonNom,
      'salonLogo': salonLogo,
      'prestations': prestations.map((p) => p.toJson()).toList(),
      'dateHeurePrevue': dateHeurePrevue?.toIso8601String(),
      'coiffeurId': coiffeurId,
      'coiffeurNom': coiffeurNom,
      'notes': notes,
    };
  }

  SalonRendezVousPanierModel copyWith({
    String? slugSalon,
    String? salonNom,
    String? salonLogo,
    List<LignePrestationPanierModel>? prestations,
    DateTime? dateHeurePrevue,
    int? coiffeurId,
    String? coiffeurNom,
    String? notes,
    bool clearCoiffeur = false,
  }) {
    return SalonRendezVousPanierModel(
      slugSalon: slugSalon ?? this.slugSalon,
      salonNom: salonNom ?? this.salonNom,
      salonLogo: salonLogo ?? this.salonLogo,
      prestations: prestations ?? this.prestations,
      dateHeurePrevue: dateHeurePrevue ?? this.dateHeurePrevue,
      coiffeurId: clearCoiffeur ? null : (coiffeurId ?? this.coiffeurId),
      coiffeurNom: clearCoiffeur ? null : (coiffeurNom ?? this.coiffeurNom),
      notes: notes ?? this.notes,
    );
  }
}
