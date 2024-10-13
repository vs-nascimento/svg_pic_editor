class SvgElement {
  final String name;
  final Map<String, String> attributes;
  final List<SvgElement> children;
  final String svgString;
  final String elementSvgString;

  SvgElement({
    required this.name,
    required this.attributes,
    required this.children,
    required this.svgString,
    required this.elementSvgString,
  });
}
