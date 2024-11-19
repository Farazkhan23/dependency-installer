import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:yaml/yaml.dart';

class PubspecModifier {
  late File pubspec;
  late String projectPath;
  PubspecModifier(this.projectPath) {
    pubspec = File("$projectPath/pubspec.yaml");
  }

  // Check if a specific package exists
  Future<bool> hasPackage(
      {required String packageName, bool isDevDependency = false}) async {
    try {
      String content = await pubspec.readAsString();

      //Package to load yaml content
      final yamlDoc = loadYaml(content);

      if (isDevDependency) {
        // Check in dev_dependencies
        final devDependencies = yamlDoc['dev_dependencies'] as Map?;
        if (devDependencies != null &&
            devDependencies.containsKey(packageName)) {
          return true;
        }
      } else {
        final dependencies = yamlDoc['dependencies'] as Map?;
        if (dependencies != null && dependencies.containsKey(packageName)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error checking pubspec.yaml: $e');
      return false;
    }
  }

  Future<bool> addPackage({required String packageNameWithVersion}) async {
    try {
      var process = await Process.run(
          'flutter', ['pub', 'add', packageNameWithVersion],
          runInShell: true, workingDirectory: projectPath);

      if (process.exitCode == 0) {
        return true;
      }
    } catch (e) {
      log("Error addPackage: $e");
    }
    return false;
  }

  Future<bool> runPubGet() async {
    try {
      var process = await Process.run('flutter', ['pub', 'get'],
          runInShell: true, workingDirectory: projectPath);

      return process.exitCode == 0;
    } catch (e) {
      log("Error addPackage: $e");
    }
    return false;
  }
}
