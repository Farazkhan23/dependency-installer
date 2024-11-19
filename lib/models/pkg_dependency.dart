class PkgDependency {
  final String packageName, version;
  String? description;
  final Function procedure;
  final List<String> changes;

  PkgDependency({
    required this.packageName,
    required this.version,
    required this.procedure,
    required this.changes,
    this.description,
  });
}
