import 'package:geolocator/geolocator.dart';

class SitePosition {
  const SitePosition({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.horizontalAccuracy,
    this.verticalAccuracy,
  });

  final double latitude;
  final double longitude;
  final double? altitude;
  final double? horizontalAccuracy;
  final double? verticalAccuracy;
}

class LocationService {
  Future<SitePosition?> currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 12),
      ),
    );

    return SitePosition(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      horizontalAccuracy: position.accuracy,
      verticalAccuracy: position.altitudeAccuracy,
    );
  }
}
