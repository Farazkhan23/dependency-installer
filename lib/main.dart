import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedPath;

  Future<void> _pickFolderOrFiles() async {
    if (kIsWeb) {
      // On Web: Mimic directory selection by allowing file selection
      // try {
      //   FilePickerResult? result = await FilePicker.platform.pickFiles(
      //     allowMultiple: true,
      //   );
      //
      //   if (result != null) {
      //     // Extract directory-like path from the first selected file
      //
      //     String? firstFilePath = result.files.first.name;
      //     log("Results $firstFilePath \n INFO ${result.files.first}");
      //
      //     if (firstFilePath != null) {
      //       selectedPath = firstFilePath
      //           .split('/')
      //           .sublist(0, firstFilePath.split('/').length - 1)
      //           .join('/');
      //     }
      //
      //     setState(() {});
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Directory selected: $selectedPath')),
      //     );
      //   } else {
      //     // User canceled the picker
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('No files selected.')),
      //     );
      //   }
      // } catch (e) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('An error occurred: $e')),
      //   );
      // }
    } else {
      // Non-Web: Use folder picker
      String? folderPath = await FilePicker.platform.getDirectoryPath();
      if (folderPath != null) {
        setState(() {
          selectedPath = folderPath;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Folder selected: $selectedPath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No folder selected.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Flutter Pub Get'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickFolderOrFiles,
              child: const Text('Pick Folder (or Files on Web)'),
            ),
          ],
        ),
      ),
    );
  }
}
