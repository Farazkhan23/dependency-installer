import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Picker {
  static Future<String?> pickFolder({required BuildContext context}) async {
    if (kIsWeb) {
      return null;
    }
    try {
      return await Picker.pickFile();
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  static Future<String> pickFile() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath == null) {
      throw Exception("Folder not selected");
    }

    if (!await File("$folderPath/pubspec.yaml").exists()) {
      // Please mind my message just for testing
      throw Exception(
          "Pubspec.yaml file not found. Please select the main folder of your flutter project");
    }

    return folderPath;
  }
}
