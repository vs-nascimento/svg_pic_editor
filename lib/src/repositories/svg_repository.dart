
import 'package:xml/xml.dart' as xml;

import '../models/element.dart';
import '../models/svg_element.dart';

abstract class SvgRepository {
  Future<String> loadSvg(String path, String? package);
  Future<String> loadNetwork(String url);

  Iterable<xml.XmlElement> queryElements({
    required xml.XmlDocument document,
    String? id,
    String? className,
    int? childIndex,
  });

  void applyModifications(xml.XmlElement element, ElementSvg entity);

  List<SvgElement> extractComponentPartsAsSvg({
    required xml.XmlDocument document,
     List<String>? partNames,
  });

  Future<List<SvgElement>> extractComponentPartsAsSvgFromPathOrString({
    required String svgContentOrPath,
    List<String>? partNames,
    bool isAsset = false,
  });
}
