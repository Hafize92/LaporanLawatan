import 'package:image_picker/image_picker.dart';

import '../models/site_photo.dart';
import 'exif_service.dart';
import 'file_storage_service.dart';
import 'id_generator.dart';
import 'location_service.dart';

enum PhotoSourceMode { camera, gallery }

class PhotoIntakeFailure implements Exception {
  const PhotoIntakeFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class PhotoIntakeService {
  PhotoIntakeService({
    ImagePicker? picker,
    LocationService? locationService,
    ExifService? exifService,
    FileStorageService? storageService,
  })  : _picker = picker ?? ImagePicker(),
        _locationService = locationService ?? LocationService(),
        _exifService = exifService ?? ExifService(),
        _storageService = storageService ?? FileStorageService();

  final ImagePicker _picker;
  final LocationService _locationService;
  final ExifService _exifService;
  final FileStorageService _storageService;

  Future<SitePhoto?> pickPhoto({
    required PhotoSourceMode mode,
    required double levelOffsetMeters,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(
        source:
            mode == PhotoSourceMode.camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 92,
        requestFullMetadata: true,
      );

      if (pickedFile == null) {
        return null;
      }

      final position = await _locationService.currentPosition();
      final exif = await _exifService.readGeoMetadata(pickedFile);
      final storedPath = await _storageService.persistImage(pickedFile);

      final latitude = position?.latitude ?? exif?.latitude;
      final longitude = position?.longitude ?? exif?.longitude;
      final altitude = position?.altitude ?? exif?.altitude;

      return SitePhoto(
        id: newId('photo'),
        filePath: storedPath,
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        adjustedLevel:
            altitude == null ? null : altitude + levelOffsetMeters,
        horizontalAccuracy: position?.horizontalAccuracy,
        verticalAccuracy: position?.verticalAccuracy,
        capturedAt: DateTime.now(),
      );
    } catch (error) {
      throw PhotoIntakeFailure(
        'Gambar tidak dapat diproses. Semak permission kamera, galeri, dan lokasi. $error',
      );
    }
  }
}
