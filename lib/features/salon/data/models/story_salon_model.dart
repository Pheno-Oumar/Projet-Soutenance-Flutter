class StorySalonModel {
  final int id;
  final String mediaUrl;
  final String typeMedia;
  final DateTime? dateCreation;
  final DateTime? dateExpiration;
  final String? salonSlug;
  final String? salonNom;
  final String? salonLogoUrl;

  const StorySalonModel({
    required this.id,
    required this.mediaUrl,
    required this.typeMedia,
    this.dateCreation,
    this.dateExpiration,
    this.salonSlug,
    this.salonNom,
    this.salonLogoUrl,
  });

  factory StorySalonModel.fromJson(Map<String, dynamic> json) {
    return StorySalonModel(
      id: json['id'] as int? ?? 0,
      mediaUrl: json['mediaUrl'] as String? ?? '',
      typeMedia: json['typeMedia'] as String? ?? 'IMAGE',
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
      dateExpiration: json['dateExpiration'] != null
          ? DateTime.tryParse(json['dateExpiration'].toString())
          : null,
      salonSlug: json['salonSlug'] as String?,
      salonNom: json['salonNom'] as String?,
      salonLogoUrl: json['salonLogoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaUrl': mediaUrl,
      'typeMedia': typeMedia,
      'dateCreation': dateCreation?.toIso8601String(),
      'dateExpiration': dateExpiration?.toIso8601String(),
      'salonSlug': salonSlug,
      'salonNom': salonNom,
      'salonLogoUrl': salonLogoUrl,
    };
  }

  bool get isVideo => typeMedia.toUpperCase() == 'VIDEO';
}

class SalonStoriesGroupModel {
  final int salonId;
  final String salonNom;
  final String salonSlug;
  final String? salonLogoUrl;
  final int nombreStories;
  final List<StorySalonModel> stories;

  const SalonStoriesGroupModel({
    required this.salonId,
    required this.salonNom,
    required this.salonSlug,
    this.salonLogoUrl,
    required this.nombreStories,
    required this.stories,
  });

  factory SalonStoriesGroupModel.fromJson(Map<String, dynamic> json) {
    final rawStories = json['stories'] as List<dynamic>? ?? [];
    return SalonStoriesGroupModel(
      salonId: json['salonId'] as int? ?? 0,
      salonNom: json['salonNom'] as String? ?? '',
      salonSlug: json['salonSlug'] as String? ?? '',
      salonLogoUrl: json['salonLogoUrl'] as String?,
      nombreStories: json['nombreStories'] as int? ?? rawStories.length,
      stories: rawStories
          .map((s) => StorySalonModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
