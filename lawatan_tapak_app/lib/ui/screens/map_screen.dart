import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/site_photo.dart';
import '../../services/map_link_service.dart';
import '../../state/lawatan_app_state.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key, required this.state});

  final LawatanAppState state;

  @override
  Widget build(BuildContext context) {
    final photos = state.photos.where((photo) => photo.hasCoordinate).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Peta gambar', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Expanded(
            child: photos.isEmpty
                ? const _NoCoordinates()
                : _supportsNativeGoogleMap
                    ? _NativeGoogleMap(photos: photos)
                    : _DesktopMapFallback(photos: photos),
          ),
        ],
      ),
    );
  }

  bool get _supportsNativeGoogleMap {
    return Platform.isAndroid || Platform.isIOS;
  }
}

class _NativeGoogleMap extends StatelessWidget {
  const _NativeGoogleMap({required this.photos});

  final List<SitePhoto> photos;

  @override
  Widget build(BuildContext context) {
    final first = photos.first;
    final initialPosition = LatLng(first.latitude!, first.longitude!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 17,
        ),
        myLocationButtonEnabled: true,
        markers: photos
            .map(
              (photo) => Marker(
                markerId: MarkerId(photo.id),
                position: LatLng(photo.latitude!, photo.longitude!),
                infoWindow: InfoWindow(
                  title: photo.caption.trim().isEmpty
                      ? 'Gambar tapak'
                      : photo.caption,
                  snippet: photo.adjustedLevelText,
                ),
              ),
            )
            .toSet(),
      ),
    );
  }
}

class _DesktopMapFallback extends StatelessWidget {
  const _DesktopMapFallback({required this.photos});

  final List<SitePhoto> photos;

  @override
  Widget build(BuildContext context) {
    final linkService = MapLinkService();
    final routeUrl = linkService.routeUrl(photos).toString();

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.map_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Fallback Windows',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Untuk Windows MVP, koordinat dipaparkan bersama Google Maps URL. Fasa seterusnya boleh tambah WebView2 bagi peta interaktif penuh.',
          ),
          const SizedBox(height: 12),
          SelectableText(routeUrl),
          const SizedBox(height: 16),
          ...photos.asMap().entries.map((entry) {
            final number = entry.key + 1;
            final photo = entry.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text('$number')),
              title: Text(
                photo.caption.trim().isEmpty ? 'Gambar $number' : photo.caption,
              ),
              subtitle: SelectableText(
                '${photo.coordinateText}\n${photo.adjustedLevelText}',
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NoCoordinates extends StatelessWidget {
  const _NoCoordinates();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Belum ada gambar dengan koordinat untuk dipaparkan.'),
        ),
      ),
    );
  }
}
