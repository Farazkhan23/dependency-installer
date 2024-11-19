import 'dart:developer';
import 'dart:io';

import 'package:pkg_installer/models/xml_element.dart';
import 'package:xml/xml.dart';

class ManifestModifier {
  late final File manifestFile;

  ManifestModifier(String path) {
    manifestFile = File('$path/android/app/src/main/AndroidManifest.xml');
  }

  Future<XmlDocument?> parse() async {
    try {
      if (!await manifestFile.exists()) {
        return null;
      }
      // Read existing manifest content
      String manifestContent = await manifestFile.readAsString();
      return XmlDocument.parse(manifestContent);
    } catch (e) {
      log("Error while parsing $e");
    }
    return null;
  }

  updateManifest(String document) async {
    await manifestFile.writeAsString(document);
  }

  Future<bool> modifyAndroidManifest({
    required String parentTagName,
    required List<XmlTagFormat> tags,
  }) async {
    try {
      XmlDocument? document = await parse();
      if (document == null) {
        return false;
      }
      XmlElement applicationElement =
          document.findAllElements(parentTagName).first;

      bool isInsertHappen = false;
      for (XmlTagFormat tag in tags) {
        bool tagExists = document.findAllElements(tag.tagName).any((element) {
          return tag.attributes
              .any((e) => element.getAttribute('android:name') == e.value);
        });

        // Skipping the tag insertion
        if (tagExists) {
          log("Tag ${tag.tagName} ${tag.attributes.where((e) => e.name == 'android:name').firstOrNull?.value} already exists");
          continue;
        }

        isInsertHappen = true;
        XmlElement apiTag = XmlElement(
            XmlName(tag.tagName),
            tag.attributes.map((attribute) =>
                XmlAttribute(XmlName(attribute.name), attribute.value)));
        applicationElement.children.insert(1, apiTag);
      }

      if (isInsertHappen) {
        await updateManifest(document.toXmlString(pretty: true));
      }
    } catch (e) {
      log("Error modifyAndroidManifest: $e");
    }
    return false;
  }
}
