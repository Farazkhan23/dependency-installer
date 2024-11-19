import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';

enum InsertionType { before, after }

enum ValueType { boolean, list, dict, string }

class IOSFilesModifier {
  File? swiftFile, plistFile;

  IOSFilesModifier(
      {required String projectPath,
      bool modifySwiftFile = false,
      bool modifyInfoPlistFile = false}) {
    if (modifySwiftFile) {
      swiftFile = File('$projectPath/ios/Runner/AppDelegate.swift');
    }

    if (modifyInfoPlistFile) {
      plistFile = File('$projectPath/ios/Runner/Info.plist');
    }
  }

  // Modify AppDelegate.swift
  Future<bool> updateAppDelegateSwift(
      {required String codeToAdd,
      required String referenceCode,
      String beforeDelegator = "\n\t",
      String afterDelegator = "\n\t",
      InsertionType insertionType = InsertionType.after}) async {
    try {
      if (swiftFile == null || !await swiftFile!.exists()) {
        return false;
      }

      String content = await swiftFile!.readAsString();
      // Check if code already exists
      if (content.contains(codeToAdd)) {
        log("Code already exists");
        return false;
      }

      // Find insertion point
      int insertIndex = content.indexOf(referenceCode);
      if (insertionType == InsertionType.after) {
        insertIndex += referenceCode.length;
      }

      //Add new code
      codeToAdd =
          '${insertionType == InsertionType.after ? afterDelegator : ''}$codeToAdd${insertionType == InsertionType.before ? beforeDelegator : ''}';
      String updatedContent =
          '${content.substring(0, insertIndex)}$codeToAdd${content.substring(insertIndex)}';

      await swiftFile!.writeAsString(updatedContent);
      log("Swift file updated");
      return true;
    } catch (e) {
      debugPrint('Error updating AppDelegate.swift: $e');
      return false;
    }
  }

  // Modify Info.plist
  Future<bool> updateInfoPlist(
      {required Map<String, dynamic> keysToAdd}) async {
    try {
      if (plistFile == null || !await plistFile!.exists()) {
        return false;
      }

      String content = await plistFile!.readAsString();

      // Find </dict> closing tag
      int insertIndex = content.lastIndexOf('</dict>');

      StringBuffer newEntries = StringBuffer();
      // Create new plist entries
      newEntries = getValues(keysToAdd: keysToAdd, content: content);
      // Insert new entries before closing dict tag
      String updatedContent = content.substring(0, insertIndex) +
          newEntries.toString() +
          content.substring(insertIndex);

      await plistFile!.writeAsString(updatedContent);
      return true;
    } catch (e) {
      print('Error updating Info.plist: $e');
      return false;
    }
  }

  // This is just to simplify the insertion process
  // current state is very raw need to optimize
  getValues(
      {required Map keysToAdd,
      required String content,
      bool insideDict = false}) {
    StringBuffer newEntries = StringBuffer();
    for (var entry in keysToAdd.entries) {
      var keyName = entry.key;
      var value = entry.value;
      var indent = insideDict ? "\t\t" : "\t";
      if (!content.contains('<key>$keyName</key>')) {
        newEntries.writeln('$indent<key>$keyName</key>');
        // Handle different value types
        if (value is bool) {
          newEntries.writeln('$indent<${value.toString().toLowerCase()}/>');
        } else if (value is List) {
          newEntries.writeln('$indent<array>');
          for (var item in entry.value) {
            if (item is Map) {
              newEntries.writeln('$indent<dict>');
              newEntries.write(
                  '$indent${getValues(keysToAdd: item, content: content, insideDict: true).toString()}');
              newEntries.writeln('$indent</dict>');
            } else if (item is bool) {
              newEntries.writeln('$indent<${value.toString().toLowerCase()}/>');
            } else {
              newEntries.writeln('\t$indent<string>$item</string>');
            }
          }
          newEntries.writeln('$indent</array>');
        } else if (value is Map) {
          newEntries.writeln('$indent<dict>');
          newEntries.write(
              '$indent${getValues(keysToAdd: value, content: content, insideDict: true).toString()}');
          newEntries.writeln('$indent</dict>');
        } else {
          newEntries.writeln('$indent<string>$value</string>');
        }
      }
    }
    return newEntries;
  }
}
