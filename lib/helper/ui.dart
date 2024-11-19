import 'package:flutter/material.dart';

//Few ui widget/method to reuse
showLoaderDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return const AlertDialog(
        backgroundColor: Colors.transparent,
        content: Center(child: CircularProgressIndicator.adaptive()),
      );
    },
  );
}

// Later we can controller the title and description to have reusable dialog
//Right now hard coded for google_maps
showInputModal(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) {
      TextEditingController controller = TextEditingController();
      return StatefulBuilder(
        builder: (context, ss) {
          return AlertDialog(
            title: const Text('Google Maps API Key'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Do you have a API key?'),
                const SizedBox(height: 8),
                const Text(
                  'An API key is required to use Google Maps functionality.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  onChanged: (v) {
                    ss(() {
                      controller.text = v;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter API Key',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Skip it'),
              ),
              TextButton(
                onPressed: controller.text.isNotEmpty
                    ? () {
                        Navigator.pop(context, controller.text.trim());
                      }
                    : null,
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );
    },
  );
}
