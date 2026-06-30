import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  Future<String> persistImage(XFile file) async {
    final baseDirectory = await getApplicationDocumentsDirectory();
    final photoDirectory = Directory(
      p.join(baseDirectory.path, 'lawatan_tapak_photos'),
    );

    if (!await photoDirectory.exists()) {
      await photoDirectory.create(recursive: true);
    }

    final extension = p.extension(file.path).isEmpty
        ? '.jpg'
        : p.extension(file.path);
    final targetPath = p.join(
      photoDirectory.path,
      'photo-${DateTime.now().microsecondsSinceEpoch}$extension',
    );

    return File(file.path).copy(targetPath).then((file) => file.path);
  }
}
