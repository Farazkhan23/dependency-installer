class XmlTagFormat {
  final String tagName;
  final List<XmlAttributeFormat> attributes;

  XmlTagFormat({required this.tagName, required this.attributes});
}

class XmlAttributeFormat {
  final String name, value;
  // Prepare this just to have simpler version of XmlAttribute while inserting multiple tags
  XmlAttributeFormat({required this.name, required this.value});
}
