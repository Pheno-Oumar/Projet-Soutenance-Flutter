class AvisSalonModel {
  final int id;
  final String salonSlug;
  final String? salonNom;
  final int? clientId;
  final String clientNomComplet;
  final int note;
  final String? commentaire;
  final bool statut;
  final DateTime? dateCreation;

  const AvisSalonModel({
    required this.id,
    required this.salonSlug,
    this.salonNom,
    this.clientId,
    required this.clientNomComplet,
    required this.note,
    this.commentaire,
    this.statut = true,
    this.dateCreation,
  });

  String get initials {
    if (clientNomComplet.isEmpty) return 'CL';
    final parts = clientNomComplet.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clientNomComplet.substring(0, clientNomComplet.length >= 2 ? 2 : 1).toUpperCase();
  }

  factory AvisSalonModel.fromJson(Map<String, dynamic> json) {
    return AvisSalonModel(
      id: json['id'] as int? ?? 0,
      salonSlug: json['salonSlug'] as String? ?? '',
      salonNom: json['salonNom'] as String?,
      clientId: json['clientId'] as int?,
      clientNomComplet: json['clientNomComplet'] as String? ?? 'Client vérifié',
      note: json['note'] as int? ?? 5,
      commentaire: json['commentaire'] as String?,
      statut: json['statut'] as bool? ?? true,
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salonSlug': salonSlug,
      'salonNom': salonNom,
      'clientId': clientId,
      'clientNomComplet': clientNomComplet,
      'note': note,
      'commentaire': commentaire,
      'statut': statut,
      'dateCreation': dateCreation?.toIso8601String(),
    };
  }
}
