class HoraireSalonModel {
  final int id;
  final String jourSemaine;
  final String? heureOuverture;
  final String? heureFermeture;
  final String? pauseDebut;
  final String? pauseFin;
  final bool actif;

  const HoraireSalonModel({
    required this.id,
    required this.jourSemaine,
    this.heureOuverture,
    this.heureFermeture,
    this.pauseDebut,
    this.pauseFin,
    this.actif = true,
  });

  String get jourFrancais {
    switch (jourSemaine.toUpperCase()) {
      case 'LUNDI':
        return 'Lundi';
      case 'MARDI':
        return 'Mardi';
      case 'MERCREDI':
        return 'Mercredi';
      case 'JEUDI':
        return 'Jeudi';
      case 'VENDREDI':
        return 'Vendredi';
      case 'SAMEDI':
        return 'Samedi';
      case 'DIMANCHE':
        return 'Dimanche';
      default:
        return jourSemaine;
    }
  }

  String get plageHoraire {
    if (!actif || heureOuverture == null || heureFermeture == null) {
      return 'Fermé';
    }
    final open = heureOuverture!.length >= 5 ? heureOuverture!.substring(0, 5) : heureOuverture!;
    final close = heureFermeture!.length >= 5 ? heureFermeture!.substring(0, 5) : heureFermeture!;
    return '$open - $close';
  }

  factory HoraireSalonModel.fromJson(Map<String, dynamic> json) {
    return HoraireSalonModel(
      id: json['id'] as int? ?? 0,
      jourSemaine: json['jourSemaine'] as String? ?? 'LUNDI',
      heureOuverture: json['heureOuverture'] as String?,
      heureFermeture: json['heureFermeture'] as String?,
      pauseDebut: json['pauseDebut'] as String?,
      pauseFin: json['pauseFin'] as String?,
      actif: json['actif'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jourSemaine': jourSemaine,
      'heureOuverture': heureOuverture,
      'heureFermeture': heureFermeture,
      'pauseDebut': pauseDebut,
      'pauseFin': pauseFin,
      'actif': actif,
    };
  }
}
