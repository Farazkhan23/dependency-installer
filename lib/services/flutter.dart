import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart' as path;

class FlutterFileCreator {
  // Create a new Dart/Flutter file
  static Future<File> createFile({
    required String folderPath,
    required String fileName,
    required String content,
  }) async {
    try {
      Directory folder = Directory(folderPath);
      if (!folder.existsSync()) {
        folder.createSync(recursive: true);
      }

      // Create file path
      File file = File(path.join(folder.path, fileName));
      await file.writeAsString(content);

      return file;
    } catch (e) {
      log('Error creating file: $e');
      rethrow;
    }
  }
}
