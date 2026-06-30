import 'site_visit.dart';

class SiteProject {
  const SiteProject({
    required this.id,
    required this.projectName,
    required this.clientName,
    required this.locationName,
    required this.createdAt,
    this.levelOffsetMeters = 0,
    this.reportTemplateId = 'standard-photo-map',
    this.visits = const <SiteVisit>[],
  });

  final String id;
  final String projectName;
  final String clientName;
  final String locationName;
  final DateTime createdAt;
  final double levelOffsetMeters;
  final String reportTemplateId;
  final List<SiteVisit> visits;

  int get totalPhotos {
    return visits.fold<int>(0, (total, visit) => total + visit.photos.length);
  }

  int get totalPhotosWithCoordinate {
    return visits.fold<int>(
      0,
      (total, visit) =>
          total + visit.photos.where((photo) => photo.hasCoordinate).length,
    );
  }

  SiteProject copyWith({
    String? id,
    String? projectName,
    String? clientName,
    String? locationName,
    DateTime? createdAt,
    double? levelOffsetMeters,
    String? reportTemplateId,
    List<SiteVisit>? visits,
  }) {
    return SiteProject(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      clientName: clientName ?? this.clientName,
      locationName: locationName ?? this.locationName,
      createdAt: createdAt ?? this.createdAt,
      levelOffsetMeters: levelOffsetMeters ?? this.levelOffsetMeters,
      reportTemplateId: reportTemplateId ?? this.reportTemplateId,
      visits: visits ?? this.visits,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'projectName': projectName,
      'clientName': clientName,
      'locationName': locationName,
      'createdAt': createdAt.toIso8601String(),
      'levelOffsetMeters': levelOffsetMeters,
      'reportTemplateId': reportTemplateId,
      'visits': visits.map((visit) => visit.toJson()).toList(),
    };
  }

  factory SiteProject.fromJson(Map<String, Object?> json) {
    final rawVisits = json['visits'];
    return SiteProject(
      id: json['id'] as String? ?? '',
      projectName: json['projectName'] as String? ?? 'Projek Lawatan Tapak',
      clientName: json['clientName'] as String? ?? '',
      locationName: json['locationName'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      levelOffsetMeters: _doubleValue(json['levelOffsetMeters']) ?? 0,
      reportTemplateId:
          json['reportTemplateId'] as String? ?? 'standard-photo-map',
      visits: rawVisits is List
          ? rawVisits
              .whereType<Map>()
              .map(
                (visit) => SiteVisit.fromJson(
                  Map<String, Object?>.from(visit),
                ),
              )
              .toList()
          : const <SiteVisit>[],
    );
  }

  static double? _doubleValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
