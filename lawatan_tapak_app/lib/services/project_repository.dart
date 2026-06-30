import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/site_project.dart';

class ProjectRepository {
  Future<SiteProject?> loadProject() async {
    try {
      final file = await _projectFile();
      if (!await file.exists()) {
        return null;
      }

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) {
        return null;
      }

      return SiteProject.fromJson(Map<String, Object?>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProject(SiteProject project) async {
    final file = await _projectFile();
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(project.toJson()),
    );
  }

  Future<File> _projectFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, 'lawatan_tapak_project.json'));
  }
}
