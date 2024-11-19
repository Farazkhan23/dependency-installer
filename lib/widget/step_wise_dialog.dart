import 'package:flutter/material.dart';

class StepwiseLoader extends StatelessWidget {
  final ValueNotifier<int> progressNotifier;
  final List<String> steps;

  const StepwiseLoader({
    super.key,
    required this.progressNotifier,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ValueListenableBuilder<int>(
          valueListenable: progressNotifier,
          builder: (context, progress, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: progress < steps.length
                      ? const CircularProgressIndicator.adaptive()
                      : const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                ),
                const SizedBox(height: 20),
                Text(
                  "$progress/${steps.length}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  progress < steps.length
                      ? steps[progress]
                      : "Installation finished",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
