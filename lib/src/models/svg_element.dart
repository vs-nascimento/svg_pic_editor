import 'element_edit.dart';

/// Represents a parsed element from an SVG document.
class SvgElement {
  /// The XML tag name of the element (e.g., `path`, `rect`).
  final String name;

  /// The attributes of this XML element.
  final Map<String, String> attributes;

  /// The child elements of this element.
  final List<SvgElement> children;

  /// The element rendered as a standalone, complete SVG string.
  final String svgMountedString;

  /// The raw XML string representation of this element.
  final String elementString;

  /// The [ElementEdit] representation parsed from this element.
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
