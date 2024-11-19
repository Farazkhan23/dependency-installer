import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pkg_installer/services/picker.dart';

class EmptyStateFolderPicker extends StatefulWidget {
  final void Function(String) onFolderSelected;

  const EmptyStateFolderPicker({
    super.key,
    required this.onFolderSelected,
  });

  @override
  State<EmptyStateFolderPicker> createState() => _EmptyStateFolderPickerState();
}

class _EmptyStateFolderPickerState extends State<EmptyStateFolderPicker>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String? webFolder;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Folder Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.folder_open_outlined,
                      size: 48,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    "Select Your Flutter Project Directory",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    "Choose a root folder of your flutter project. This will help us organize files & manage dependency better.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          letterSpacing: 0,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Doing this because of lack of path during selecting folder on web
                  //TODO: Find solution for web and fix it
                  kIsWeb
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.red.withOpacity(.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(
                                  CupertinoIcons.info_circle,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Flexible(
                                child: Text(
                                  "Due to limited knowledge about shell scripting. I am unable to make this work on Web. I will find some solution for it soon. So far tested on MacOS",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        )
                      :
                      // Folder Picker Button
                      MouseRegion(
                          onEnter: (_) {
                            setState(() => _isHovered = true);
                            _controller.forward();
                          },
                          onExit: (_) {
                            setState(() => _isHovered = false);
                            _controller.reverse();
                          },
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isHovered
                                    ? [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : null,
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  String? directory =
                                      await Picker.pickFolder(context: context);
                                  if (directory == null) {
                                    return;
                                  }
                                  widget.onFolderSelected(directory);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isHovered
                                      ? Colors.blue.shade600
                                      : Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: _isHovered ? 4 : 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_rounded,
                                      size: 20,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Choose Folder',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
