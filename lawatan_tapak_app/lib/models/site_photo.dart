class SitePhoto {
  const SitePhoto({
    required this.id,
    required this.filePath,
    required this.capturedAt,
    this.latitude,
    this.longitude,
    this.altitude,
    this.adjustedLevel,
    this.horizontalAccuracy,
    this.verticalAccuracy,
    this.category = 'Umum',
    this.caption = '',
    this.observation = '',
    this.recommendation = '',
  });

  final String id;
  final String filePath;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? adjustedLevel;
  final double? horizontalAccuracy;
  final double? verticalAccuracy;
  final DateTime capturedAt;
  final String category;
  final String caption;
  final String observation;
  final String recommendation;

  bool get hasCoordinate => latitude != null && longitude != null;

  String get coordinateText {
    if (!hasCoordinate) {
      return 'Koordinat tidak tersedia';
    }
    return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
  }

  String get altitudeText {
    if (altitude == null) {
      return 'Altitude tidak tersedia';
    }
    return '${altitude!.toStringAsFixed(2)} m';
  }

  String get adjustedLevelText {
    if (adjustedLevel == null) {
      return 'Level tidak tersedia';
    }
    return '${adjustedLevel!.toStringAsFixed(2)} m';
  }

  SitePhoto copyWith({
    String? id,
    String? filePath,
    double? latitude,
    double? longitude,
    double? altitude,
    double? adjustedLevel,
    double? horizontalAccuracy,
    double? verticalAccuracy,
    DateTime? capturedAt,
    String? category,
    String? caption,
    String? observation,
    String? recommendation,
  }) {
    return SitePhoto(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      adjustedLevel: adjustedLevel ?? this.adjustedLevel,
      horizontalAccuracy: horizontalAccuracy ?? this.horizontalAccuracy,
      verticalAccuracy: verticalAccuracy ?? this.verticalAccuracy,
      capturedAt: capturedAt ?? this.capturedAt,
      category: category ?? this.category,
      caption: caption ?? this.caption,
      observation: observation ?? this.observation,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'filePath': filePath,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'adjustedLevel': adjustedLevel,
      'horizontalAccuracy': horizontalAccuracy,
      'verticalAccuracy': verticalAccuracy,
      'capturedAt': capturedAt.toIso8601String(),
      'category': category,
      'caption': caption,
      'observation': observation,
      'recommendation': recommendation,
    };
  }

  factory SitePhoto.fromJson(Map<String, Object?> json) {
    return SitePhoto(
      id: json['id'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      latitude: _doubleValue(json['latitude']),
      longitude: _doubleValue(json['longitude']),
      altitude: _doubleValue(json['altitude']),
      adjustedLevel: _doubleValue(json['adjustedLevel']),
      horizontalAccuracy: _doubleValue(json['horizontalAccuracy']),
      verticalAccuracy: _doubleValue(json['verticalAccuracy']),
      capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? '') ??
          DateTime.now(),
      category: json['category'] as String? ?? 'Umum',
      caption: json['caption'] as String? ?? '',
      observation: json['observation'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
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
