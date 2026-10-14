class NotificationModel {
  final int id;
  final String titre;
  final String contenu;
  final String? type;
  final String? referenceMetier;
  final bool lu;
  final String? dateCreation;
  final String? dateLecture;

  const NotificationModel({
    required this.id,
    required this.titre,
    required this.contenu,
    this.type,
    this.referenceMetier,
    this.lu = false,
    this.dateCreation,
    this.dateLecture,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      titre: json['titre'] as String? ?? '',
      contenu: json['contenu'] as String? ?? '',
      type: json['type'] as String?,
      referenceMetier: json['referenceMetier'] as String?,
      lu: json['lu'] as bool? ?? false,
      dateCreation: json['dateCreation'] as String?,
      dateLecture: json['dateLecture'] as String?,
    );
  }

  NotificationModel copyWith({
    int? id,
    String? titre,
    String? contenu,
    String? type,
    String? referenceMetier,
    bool? lu,
    String? dateCreation,
    String? dateLecture,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      type: type ?? this.type,
      referenceMetier: referenceMetier ?? this.referenceMetier,
      lu: lu ?? this.lu,
      dateCreation: dateCreation ?? this.dateCreation,
      dateLecture: dateLecture ?? this.dateLecture,
    );
  }
}

class NotificationCountModel {
  final int total;
  final int nonLues;

  const NotificationCountModel({
    required this.total,
    required this.nonLues,
  });

  factory NotificationCountModel.fromJson(Map<String, dynamic> json) {
    return NotificationCountModel(
      total: json['total'] as int? ?? 0,
      nonLues: json['nonLues'] as int? ?? 0,
    );
  }
}
