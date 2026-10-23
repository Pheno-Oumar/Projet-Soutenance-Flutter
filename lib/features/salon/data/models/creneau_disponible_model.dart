class LigneCreneauModel {
  final int varianteId;
  final String varianteNom;
  final int? coiffeurAffectationId;
  final String? coiffeurNom;
  final String? coiffeurPrenom;
  final String heureDebut;
  final String heureFin;
  final int dureeMinutes;
  final double prix;

  const LigneCreneauModel({
    required this.varianteId,
    required this.varianteNom,
    this.coiffeurAffectationId,
    this.coiffeurNom,
    this.coiffeurPrenom,
    required this.heureDebut,
    required this.heureFin,
    required this.dureeMinutes,
    required this.prix,
  });

  String get coiffeurNomComplet {
    final parts = [coiffeurPrenom, coiffeurNom].where((s) => s != null && s.isNotEmpty);
    if (parts.isNotEmpty) return parts.join(' ');
    return 'Coiffeur du salon';
  }

  factory LigneCreneauModel.fromJson(Map<String, dynamic> json) {
    return LigneCreneauModel(
      varianteId: json['varianteId'] as int? ?? 0,
      varianteNom: json['varianteNom'] as String? ?? '',
      coiffeurAffectationId: json['coiffeurAffectationId'] as int?,
      coiffeurNom: json['coiffeurNom'] as String?,
      coiffeurPrenom: json['coiffeurPrenom'] as String?,
      heureDebut: json['heureDebut'] as String? ?? '',
      heureFin: json['heureFin'] as String? ?? '',
      dureeMinutes: json['dureeMinutes'] as int? ?? 0,
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'varianteId': varianteId,
      'varianteNom': varianteNom,
      'coiffeurAffectationId': coiffeurAffectationId,
      'coiffeurNom': coiffeurNom,
      'coiffeurPrenom': coiffeurPrenom,
      'heureDebut': heureDebut,
      'heureFin': heureFin,
      'dureeMinutes': dureeMinutes,
      'prix': prix,
    };
  }
}

class CreneauDisponibleModel {
  final String heureDebut;
  final String heureFin;
  final int dureeTotale;
  final double montantTotal;
  final List<LigneCreneauModel> lignesProposees;

  final int? topLevelCoiffeurId;
  final String? topLevelCoiffeurNom;

  const CreneauDisponibleModel({
    required this.heureDebut,
    required this.heureFin,
    required this.dureeTotale,
    required this.montantTotal,
    this.lignesProposees = const [],
    this.topLevelCoiffeurId,
    this.topLevelCoiffeurNom,
  });

  /// Ex: "10:00"
  String get heureDebutFormatee {
    if (heureDebut.length >= 5) {
      return heureDebut.substring(0, 5);
    }
    return heureDebut;
  }

  /// Ex: "11:30"
  String get heureFinFormatee {
    if (heureFin.length >= 5) {
      return heureFin.substring(0, 5);
    }
    return heureFin;
  }

  /// Ex: "10:00 - 11:30"
  String get plageFormatee => '$heureDebutFormatee - $heureFinFormatee';

  /// Heure de début
  int get heure {
    final parts = heureDebut.split(':');
    return parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
  }

  /// Minute de début
  int get minute {
    final parts = heureDebut.split(':');
    return parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  }

  /// Nom du coiffeur assigné ou suggéré
  String? get coiffeurNom {
    if (topLevelCoiffeurNom != null && topLevelCoiffeurNom!.isNotEmpty) {
      return topLevelCoiffeurNom;
    }
    if (lignesProposees.isNotEmpty) {
      return lignesProposees.first.coiffeurNomComplet;
    }
    return null;
  }

  int? get coiffeurAffectationId {
    if (topLevelCoiffeurId != null) {
      return topLevelCoiffeurId;
    }
    if (lignesProposees.isNotEmpty) {
      return lignesProposees.first.coiffeurAffectationId;
    }
    return null;
  }

  factory CreneauDisponibleModel.fromJson(Map<String, dynamic> json) {
    final rawLignes = json['lignesProposees'] as List<dynamic>? ?? [];
    return CreneauDisponibleModel(
      heureDebut: json['heureDebut'] as String? ?? '',
      heureFin: json['heureFin'] as String? ?? '',
      dureeTotale: json['dureeTotale'] as int? ?? 0,
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      topLevelCoiffeurId: json['coiffeurId'] as int?,
      topLevelCoiffeurNom: json['coiffeurNom'] as String?,
      lignesProposees: rawLignes
          .map((item) => LigneCreneauModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heureDebut': heureDebut,
      'heureFin': heureFin,
      'dureeTotale': dureeTotale,
      'montantTotal': montantTotal,
      'lignesProposees': lignesProposees.map((l) => l.toJson()).toList(),
    };
  }
}
