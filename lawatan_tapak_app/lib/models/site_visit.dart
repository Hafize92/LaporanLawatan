import 'site_photo.dart';

class SiteVisit {
  const SiteVisit({
    required this.id,
    required this.visitDate,
    required this.officerName,
    this.weather = '',
    this.generalNotes = '',
    this.conclusion = '',
    this.photos = const <SitePhoto>[],
  });

  final String id;
  final DateTime visitDate;
  final String officerName;
  final String weather;
  final String generalNotes;
  final String conclusion;
  final List<SitePhoto> photos;

  SiteVisit copyWith({
    String? id,
    DateTime? visitDate,
    String? officerName,
    String? weather,
    String? generalNotes,
    String? conclusion,
    List<SitePhoto>? photos,
  }) {
    return SiteVisit(
      id: id ?? this.id,
      visitDate: visitDate ?? this.visitDate,
      officerName: officerName ?? this.officerName,
      weather: weather ?? this.weather,
      generalNotes: generalNotes ?? this.generalNotes,
      conclusion: conclusion ?? this.conclusion,
      photos: photos ?? this.photos,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'visitDate': visitDate.toIso8601String(),
      'officerName': officerName,
      'weather': weather,
      'generalNotes': generalNotes,
      'conclusion': conclusion,
      'photos': photos.map((photo) => photo.toJson()).toList(),
    };
  }

  factory SiteVisit.fromJson(Map<String, Object?> json) {
    final rawPhotos = json['photos'];
    return SiteVisit(
      id: json['id'] as String? ?? '',
      visitDate: DateTime.tryParse(json['visitDate'] as String? ?? '') ??
          DateTime.now(),
      officerName: json['officerName'] as String? ?? '',
      weather: json['weather'] as String? ?? '',
      generalNotes: json['generalNotes'] as String? ?? '',
      conclusion: json['conclusion'] as String? ?? '',
      photos: rawPhotos is List
          ? rawPhotos
              .whereType<Map>()
              .map(
                (photo) => SitePhoto.fromJson(
                  Map<String, Object?>.from(photo),
                ),
              )
              .toList()
          : const <SitePhoto>[],
    );
  }
}
