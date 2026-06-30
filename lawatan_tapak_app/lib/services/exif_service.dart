import 'package:exif/exif.dart';
import 'package:image_picker/image_picker.dart';

class PhotoGeoMetadata {
  const PhotoGeoMetadata({
    this.latitude,
    this.longitude,
    this.altitude,
  });

  final double? latitude;
  final double? longitude;
  final double? altitude;
}

class ExifService {
  Future<PhotoGeoMetadata?> readGeoMetadata(XFile file) async {
    try {
      final data = await readExifFromBytes(await file.readAsBytes());
      final latitude = _readCoordinate(
        data,
        coordinateKey: 'GPS GPSLatitude',
        referenceKey: 'GPS GPSLatitudeRef',
      );
      final longitude = _readCoordinate(
        data,
        coordinateKey: 'GPS GPSLongitude',
        referenceKey: 'GPS GPSLongitudeRef',
      );
      final altitude = _readAltitude(data);

      if (latitude == null && longitude == null && altitude == null) {
        return null;
      }

      return PhotoGeoMetadata(
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
      );
    } catch (_) {
      return null;
    }
  }

  double? _readCoordinate(
    Map<String, IfdTag> data, {
    required String coordinateKey,
    required String referenceKey,
  }) {
    final coordinateTag = data[coordinateKey];
    if (coordinateTag == null) {
      return null;
    }

    final values = _tagValues(coordinateTag);
    if (values.length < 3) {
      return null;
    }

    final degrees = _asDouble(values[0]);
    final minutes = _asDouble(values[1]);
    final seconds = _asDouble(values[2]);
    if (degrees == null || minutes == null || seconds == null) {
      return null;
    }

    var decimal = degrees + (minutes / 60) + (seconds / 3600);
    final reference = data[referenceKey]?.printable.toUpperCase() ?? '';
    if (reference.contains('S') || reference.contains('W')) {
      decimal *= -1;
    }
    return decimal;
  }

  double? _readAltitude(Map<String, IfdTag> data) {
    final altitudeTag = data['GPS GPSAltitude'];
    if (altitudeTag == null) {
      return null;
    }

    final values = _tagValues(altitudeTag);
    if (values.isEmpty) {
      return null;
    }

    var altitude = _asDouble(values.first);
    if (altitude == null) {
      return null;
    }

    final reference = data['GPS GPSAltitudeRef']?.printable ?? '';
    if (reference.contains('1')) {
      altitude *= -1;
    }
    return altitude;
  }

  List<Object?> _tagValues(IfdTag tag) {
    final dynamic rawValues = tag.values;
    if (rawValues is Iterable) {
      return rawValues.cast<Object?>().toList();
    }
    try {
      final dynamic listedValues = rawValues.toList();
      if (listedValues is Iterable) {
        return listedValues.cast<Object?>().toList();
      }
    } catch (_) {
      // Fall back to parsing a printable representation below.
    }
    final text = rawValues.toString().replaceAll('[', '').replaceAll(']', '');
    if (text.contains(',')) {
      return text.split(',').map((part) => part.trim()).toList();
    }
    return <Object?>[rawValues];
  }

  double? _asDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }

    final dynamic dynamicValue = value;
    try {
      final numerator = dynamicValue.numerator;
      final denominator = dynamicValue.denominator;
      if (numerator is num && denominator is num && denominator != 0) {
        return numerator / denominator;
      }
    } catch (_) {
      // Fall back to parsing below.
    }

    final text = value.toString().replaceAll('[', '').replaceAll(']', '');
    if (text.contains('/')) {
      final parts = text.split('/');
      if (parts.length == 2) {
        final numerator = double.tryParse(parts[0].trim());
        final denominator = double.tryParse(parts[1].trim());
        if (numerator != null && denominator != null && denominator != 0) {
          return numerator / denominator;
        }
      }
    }

    return double.tryParse(text.trim());
  }
}
