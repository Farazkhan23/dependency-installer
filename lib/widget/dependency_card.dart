import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pkg_installer/models/pkg_dependency.dart';
import 'package:pkg_installer/services/pubspec.dart';

class DependencyCard extends StatefulWidget {
  final PkgDependency dependency;
  final String projectPath;
  const DependencyCard(
      {super.key, required this.dependency, required this.projectPath});

  @override
  State<DependencyCard> createState() => _DependencyCardState();
}

class _DependencyCardState extends State<DependencyCard> {
  late PkgDependency currentDependency;
  bool? doesExists;

  checkExistence() async {
    setState(() {
      doesExists = null;
    });
    doesExists = await PubspecModifier(widget.projectPath).hasPackage(
        packageName: currentDependency.packageName, isDevDependency: false);
    setState(() {});
  }

  installDependency() async {
    await currentDependency.procedure();
    checkExistence();
  }

  @override
  void initState() {
    currentDependency = widget.dependency;
    checkExistence();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: doesExists == false ? installDependency : null,
        title: Row(
          children: [
            Text(currentDependency.packageName),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                currentDependency.version,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (doesExists == true)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Package Installed",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 4,
            ),
            Text(
              currentDependency.description ?? "No Description",
              style: const TextStyle(fontSize: 12, letterSpacing: 0),
            ),
            const SizedBox(
              height: 8,
            ),
            Wrap(
              children: currentDependency.changes.map((change) {
                return Container(
                  margin: const EdgeInsets.only(right: 4, top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton.icon(
                onPressed: checkExistence,
                label: const Text(
                  "Refresh",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  iconColor: Colors.red,
                ),
                icon: const Icon(
                  Icons.refresh,
                  size: 20,
                )),
            const SizedBox(
              width: 8,
            ),
            doesExists == null
                ? const CircularProgressIndicator.adaptive()
                : Icon(
                    doesExists!
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.add_circled_solid,
                    color: doesExists! ? Colors.green : Colors.grey,
                  )
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
