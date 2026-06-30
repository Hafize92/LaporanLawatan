import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/site_photo.dart';
import '../models/site_project.dart';
import '../models/site_visit.dart';
import '../services/id_generator.dart';
import '../services/project_repository.dart';

class LawatanAppState extends ChangeNotifier {
  LawatanAppState(this._project, {ProjectRepository? repository})
      : _repository = repository ?? ProjectRepository() {
    if (_project.visits.isEmpty) {
      _project = _project.copyWith(visits: <SiteVisit>[_defaultVisit()]);
    }
  }

  static Future<LawatanAppState> load() async {
    final repository = ProjectRepository();
    final project = await repository.loadProject() ?? _defaultProject();
    return LawatanAppState(project, repository: repository);
  }

  static SiteProject _defaultProject() {
    return SiteProject(
      id: newId('project'),
      projectName: 'Projek Lawatan Tapak',
      clientName: 'Nama Klien',
      locationName: 'Lokasi Tapak',
      createdAt: DateTime.now(),
      visits: <SiteVisit>[_defaultVisit()],
    );
  }

  static SiteVisit _defaultVisit() {
    return SiteVisit(
      id: newId('visit'),
      visitDate: DateTime.now(),
      officerName: 'Pegawai Tapak',
      weather: 'Cerah',
      generalNotes: 'Lawatan tapak dijalankan bagi merekod keadaan semasa.',
    );
  }

  SiteProject _project;
  final ProjectRepository _repository;
  int _selectedIndex = 0;

  SiteProject get project => _project;
  int get selectedIndex => _selectedIndex;
  SiteVisit get activeVisit => _project.visits.first;
  List<SitePhoto> get photos => activeVisit.photos;

  void selectTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void updateProject({
    String? projectName,
    String? clientName,
    String? locationName,
  }) {
    _commitProject(
      _project.copyWith(
        projectName: projectName,
        clientName: clientName,
        locationName: locationName,
      ),
    );
  }

  void updateLevelOffset(double offset) {
    final updatedVisits = _project.visits.map((visit) {
      final updatedPhotos = visit.photos.map((photo) {
        if (photo.altitude == null) {
          return photo;
        }
        return photo.copyWith(adjustedLevel: photo.altitude! + offset);
      }).toList();
      return visit.copyWith(photos: updatedPhotos);
    }).toList();

    _commitProject(
      _project.copyWith(
        levelOffsetMeters: offset,
        visits: updatedVisits,
      ),
    );
  }

  void updateVisit({
    String? officerName,
    String? weather,
    String? generalNotes,
    String? conclusion,
  }) {
    _replaceVisit(
      activeVisit.copyWith(
        officerName: officerName,
        weather: weather,
        generalNotes: generalNotes,
        conclusion: conclusion,
      ),
    );
  }

  void addPhoto(SitePhoto photo) {
    _replaceVisit(activeVisit.copyWith(photos: <SitePhoto>[...photos, photo]));
  }

  void addDemoPhoto() {
    final base = 3.139003 + (photos.length * 0.00018);
    final altitude = 42.5 + photos.length;
    addPhoto(
      SitePhoto(
        id: newId('photo'),
        filePath: '',
        latitude: base,
        longitude: 101.686855 + (photos.length * 0.00022),
        altitude: altitude,
        adjustedLevel: altitude + _project.levelOffsetMeters,
        horizontalAccuracy: 8,
        verticalAccuracy: 12,
        capturedAt: DateTime.now(),
        caption: 'Contoh gambar ${photos.length + 1}',
        observation: 'Keadaan tapak direkodkan semasa lawatan.',
        recommendation: 'Semakan lanjut boleh dibuat jika perlu.',
      ),
    );
  }

  void updatePhoto(SitePhoto updatedPhoto) {
    final updatedPhotos = photos.map((photo) {
      return photo.id == updatedPhoto.id ? updatedPhoto : photo;
    }).toList();
    _replaceVisit(activeVisit.copyWith(photos: updatedPhotos));
  }

  void _replaceVisit(SiteVisit visit) {
    _commitProject(
      _project.copyWith(
        visits: _project.visits.map((existing) {
          return existing.id == visit.id ? visit : existing;
        }).toList(),
      ),
    );
  }

  void _commitProject(SiteProject project) {
    _project = project;
    notifyListeners();
    unawaited(_saveSilently(project));
  }

  Future<void> _saveSilently(SiteProject project) async {
    try {
      await _repository.saveProject(project);
    } catch (_) {
      // The UI remains usable even if local persistence fails.
    }
  }
}
