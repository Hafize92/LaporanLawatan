import '../models/site_photo.dart';

class MapLinkService {
  Uri searchUrl(SitePhoto photo) {
    return Uri.https('www.google.com', '/maps/search/', <String, String>{
      'api': '1',
      'query': '${photo.latitude},${photo.longitude}',
    });
  }

  Uri routeUrl(List<SitePhoto> photos) {
    final locatedPhotos = photos.where((photo) => photo.hasCoordinate).toList();
    if (locatedPhotos.isEmpty) {
      return Uri.https('www.google.com', '/maps');
    }

    final origin = locatedPhotos.first;
    final destination = locatedPhotos.length == 1 ? origin : locatedPhotos.last;
    final waypoints = locatedPhotos.length <= 2
        ? ''
        : locatedPhotos
            .sublist(1, locatedPhotos.length - 1)
            .map((photo) => '${photo.latitude},${photo.longitude}')
            .join('|');

    return Uri.https('www.google.com', '/maps/dir/', <String, String>{
      'api': '1',
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      if (waypoints.isNotEmpty) 'waypoints': waypoints,
    });
  }
}
