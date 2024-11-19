import 'package:flutter/material.dart';
import 'package:pkg_installer/models/pkg_dependency.dart';
import 'package:pkg_installer/services/procedures.dart';
import 'package:pkg_installer/widget/dependency_card.dart';

import '../services/picker.dart';

class DependencyManagerScreen extends StatefulWidget {
  final String initialDirectory;
  final Function(String) onFolderSelect;
  final VoidCallback onClear;
  const DependencyManagerScreen(
      {super.key,
      required this.initialDirectory,
      required this.onClear,
      required this.onFolderSelect});

  @override
  State<DependencyManagerScreen> createState() =>
      _DependencyManagerScreenState();
}

class _DependencyManagerScreenState extends State<DependencyManagerScreen> {
  final List<PkgDependency> _dependencies = List.empty(growable: true);
  late Procedure procedure;
  @override
  void initState() {
    procedure =
        Procedure(projectPath: widget.initialDirectory, context: context);

    _dependencies.add(PkgDependency(
        packageName: "google_maps_flutter",
        version: "2.10.0",
        procedure: () => procedure.googleMapProcedure(),
        changes: [
          'pubspec.yaml',
          'AndroidManifest.xml',
          'AppDelegate.swift',
          'Example Widget'
        ],
        description: "A Flutter plugin that provides a Google Maps widget"));

    _dependencies.add(PkgDependency(
        packageName: "image_picker",
        version: "1.1.2",
        procedure: () => procedure.imagePickerProcedure(),
        changes: ['pubspec.yaml', 'info.plist'],
        description:
            "A Flutter plugin for iOS and Android for picking images from the image library, and taking new pictures with the camera"));

    super.initState();
  }

  Future<void> _reselectDirectory() async {
    String? directory = await Picker.pickFolder(context: context);
    if (directory == null) {
      return;
    }
    widget.onFolderSelect(directory);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_open, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.initialDirectory,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Directory Actions
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _reselectDirectory,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Change'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: widget.onClear,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Install Dependencies:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              itemCount: _dependencies.length,
              itemBuilder: (context, index) {
                final dep = _dependencies[index];
                return DependencyCard(
                  dependency: dep,
                  projectPath: widget.initialDirectory,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
