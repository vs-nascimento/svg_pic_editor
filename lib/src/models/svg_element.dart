import '../../svg_pic_editor.dart';

class SvgElement {
  final String name;
  final Map<String, String> attributes;
  final List<SvgElement> children;
  final String svgMountedString;
  final String elementString;
  final ElementEdit elementSvg;

  SvgElement({
    required this.name,
    required this.attributes,
    required this.children,
    required this.svgMountedString,
    required this.elementString,
    required this.elementSvg,
  });
}
