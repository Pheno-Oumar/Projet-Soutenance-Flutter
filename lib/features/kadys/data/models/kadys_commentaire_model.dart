class KadysCommentaireModel {
  final int id;
  final int realisationId;
  final String auteurNomComplet;
  final String? auteurPhotoUrl;
  final String contenu;
  final DateTime? dateCreation;
  final bool isMine;

  const KadysCommentaireModel({
    required this.id,
    required this.realisationId,
    required this.auteurNomComplet,
    this.auteurPhotoUrl,
    required this.contenu,
    this.dateCreation,
    this.isMine = false,
  });

  factory KadysCommentaireModel.fromJson(Map<String, dynamic> json) {
    return KadysCommentaireModel(
      id: json['id'] as int? ?? 0,
      realisationId: json['realisationId'] as int? ?? 0,
      auteurNomComplet: json['auteurNomComplet'] as String? ?? 'Client',
      auteurPhotoUrl: json['auteurPhotoUrl'] as String?,
      contenu: json['contenu'] as String? ?? '',
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
      isMine: json['isMine'] as bool? ?? false,
    );
  }

  String get initials {
    final parts = auteurNomComplet.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'CL';
  }
}
