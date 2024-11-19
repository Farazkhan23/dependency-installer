import 'package:flutter/material.dart';
import 'package:pkg_installer/examples/google_maps_flutter.dart';
import 'package:pkg_installer/models/xml_element.dart';
import 'package:pkg_installer/services/android.dart';
import 'package:pkg_installer/services/flutter.dart';
import 'package:pkg_installer/services/ios.dart';
import 'package:pkg_installer/services/pubspec.dart';
import 'package:pkg_installer/widget/step_wise_dialog.dart';

import '../helper/ui.dart';

//Procedure are nothing but steps of executions for any package
//We will follow same procedure but the pattern and some stuff will change
//Its better to have separate procedure function
//This opens up more control over each dependency

class Procedure {
  final String projectPath;
  final BuildContext context;

  Procedure({required this.projectPath, required this.context});

  googleMapProcedure() async {
    String packageName = "google_maps_flutter", version = "2.10.0";

    PubspecModifier pubspecModifier = PubspecModifier(projectPath);
    ManifestModifier manifestModifier = ManifestModifier(projectPath);
    IOSFilesModifier iosFilesModifier =
        IOSFilesModifier(projectPath: projectPath, modifySwiftFile: true);

    //loader state and steps
    final progressNotifier = ValueNotifier<int>(0);
    final steps = [
      "Checking package existence...",
      "Adding package in pubspec..",
      "Running flutter pub get",
      "Modifying AndroidManifest.xml..",
      "Modifying AppDelegate.swift...",
      "Creating example widget"
    ];
    showDialog(
        barrierDismissible: false,
        builder: (context) {
          return StepwiseLoader(
            progressNotifier: progressNotifier,
            steps: steps,
          );
        },
        context: context);

    bool isPackageAvailable = await pubspecModifier.hasPackage(
      packageName: packageName,
    );

    // Stop execution if package already in the yaml file
    if (isPackageAvailable) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Package already available"),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    // Get the key from the user if they have else allow them to skip
    String? apiKey = await showInputModal(context);
    progressNotifier.value += 1; //Used to update loader

    bool isAdded = await pubspecModifier.addPackage(
        packageNameWithVersion: "$packageName:$version");

    // If failed stop execution and show error message
    if (!isAdded) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Unable to add package"),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    progressNotifier.value += 1;

    // Run the pub get
    //Later we can run it parallel to different methods for now let make it separate step
    await pubspecModifier.runPubGet();
    progressNotifier.value += 1;

    performAndroidUpdate() async {
      await manifestModifier
          .modifyAndroidManifest(parentTagName: 'application', tags: [
        XmlTagFormat(tagName: 'meta-data', attributes: [
          XmlAttributeFormat(
              name: "android:name", value: "com.google.android.geo.API_KEY"),
          XmlAttributeFormat(
              name: "android:value", value: apiKey ?? "YOUR_API_KEY"),
        ])
      ]);
      progressNotifier.value += 1;
    }

    performIosUpdate() async {
      await iosFilesModifier.updateAppDelegateSwift(
          insertionType: InsertionType.after,
          referenceCode: 'import Flutter',
          codeToAdd: 'import GoogleMaps',
          afterDelegator: '\n');

      await iosFilesModifier.updateAppDelegateSwift(
          insertionType: InsertionType.before,
          referenceCode: 'GeneratedPluginRegistrant.register(with: self)',
          codeToAdd:
              'GMSServices.provideAPIKey("${apiKey ?? "YOUR_API_KEY"}")');

      progressNotifier.value += 1;
    }

    performFlutterFileCreation() async {
      await FlutterFileCreator.createFile(
          folderPath: "$projectPath/lib/",
          fileName: "map_example.dart",
          content: kGoogleMapExample);
      progressNotifier.value += 1;
    }

    await Future.wait([
      performAndroidUpdate(),
      performIosUpdate(),
      performFlutterFileCreation()
    ]);

    await Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  imagePickerProcedure() async {
    String packageName = "image_picker", version = "1.1.2";

    PubspecModifier pubspecModifier = PubspecModifier(projectPath);
    ManifestModifier manifestModifier = ManifestModifier(projectPath);
    IOSFilesModifier iosFilesModifier = IOSFilesModifier(
        projectPath: projectPath,
        modifySwiftFile: false,
        modifyInfoPlistFile: true);

    //loader state and steps
    final progressNotifier = ValueNotifier<int>(0);
    final steps = [
      "Checking package existence...",
      "Adding package in pubspec..",
      "Running flutter pub get...",
      "Modifying Info.plist..."
    ];

    showDialog(
        barrierDismissible: false,
        builder: (context) {
          return StepwiseLoader(
            progressNotifier: progressNotifier,
            steps: steps,
          );
        },
        context: context);

    bool isPackageAvailable = await pubspecModifier.hasPackage(
      packageName: packageName,
    );

    // Stop execution if package already in the yaml file
    if (isPackageAvailable) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Package already available"),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    progressNotifier.value += 1; //Used to update loader

    bool isAdded = await pubspecModifier.addPackage(
        packageNameWithVersion: "$packageName:$version");

    // If failed stop execution and show error message
    if (!isAdded) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Unable to add package"),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    progressNotifier.value += 1;

    await pubspecModifier.runPubGet();
    progressNotifier.value += 1;

    await iosFilesModifier.updateInfoPlist(keysToAdd: {
      "NSPhotoLibraryUsageDescription":
          "Description about why accessing gallery",
      "NSCameraUsageDescription": "Description about why accessing camera",
      "NSMicrophoneUsageDescription":
          "Description about why accessing microphone",
    });
    progressNotifier.value += 1;

    await Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }
}
