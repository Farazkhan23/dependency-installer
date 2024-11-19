import 'package:flutter/material.dart';
import 'package:pkg_installer/screens/empty_state.dart';

import 'dependency_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? projectPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Dependency Manager'),
        centerTitle: false,
        primary: true,
      ),
      body: projectPath == null
          ? EmptyStateFolderPicker(
              onFolderSelected: (selectedDirectory) {
                setState(() {
                  projectPath = selectedDirectory;
                });
              },
            )
          : DependencyManagerScreen(
              initialDirectory: projectPath!,
              onClear: () {
                setState(() {
                  projectPath = null;
                });
              },
              onFolderSelect: (selectedPath) {
                setState(() {
                  projectPath = selectedPath;
                });
              }),
    );
  }
}
