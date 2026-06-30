import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'models/element_edit.dart';
import 'models/svg_color_element.dart';
import 'models/svg_element.dart';

/// Central processor for SVG parsing, querying, and modifications.
class SvgEditorCore {
  /// Cleans the SVG content by removing `<style>` and `<script>` tags.
  static String cleanSvg(String svgContent) {
    try {
      final stylePattern = RegExp(r'<style[\s\S]*?</style>', multiLine: true);
      final scriptPattern =
          RegExp(r'<script[\s\S]*?</script>', multiLine: true);
      return svgContent
          .replaceAll(stylePattern, '')
          .replaceAll(scriptPattern, '');
    } catch (e) {
      debugPrint('Error cleaning SVG: $e');
      return svgContent;
    }
  }

  /// Parses the SVG content, applies modifications, and returns the modified SVG string.
  static String modifySvg({
    required String svgContent,
    required List<ElementEdit> modifications,
  }) {
    final document = xml.XmlDocument.parse(svgContent);

    for (final edit in modifications) {
      final querySelector = edit.querySelector;
      final id = edit.id;

      Iterable<xml.XmlElement> targets;
      if (querySelector != null && querySelector.isNotEmpty) {
        targets =
            queryAdvanced(document: document, querySelector: querySelector);
      } else if (id != null && id.isNotEmpty) {
        targets = queryElements(document: document, id: id);
      } else {
        continue;
      }

      for (final element in targets) {
        if (edit.remove == true) {
          element.parent?.children.remove(element);
        } else {
          applyModifications(element, edit);
        }
      }
    }

    return document.toXmlString(pretty: true);
  }

  /// Applies specific modifications (color, opacity, stroke, transform) to an XML element.
  static void applyModifications(xml.XmlElement element, ElementEdit edit) {
    String style = element.getAttribute('style') ?? '';

    if (edit.borderRadius != null) {
      element.setAttribute('rx', edit.borderRadius!.toString());
      element.setAttribute('ry', edit.borderRadius!.toString());
    }

    if (edit.fillColor != null) {
      final colorStr = _colorToSvgString(edit.fillColor!);
      element.setAttribute('fill', colorStr);
      style = _updateStyleValue(style, 'fill', colorStr);
    }

    if (edit.strokeColor != null) {
      final colorStr = _colorToSvgString(edit.strokeColor!);
      element.setAttribute('stroke', colorStr);
      style = _updateStyleValue(style, 'stroke', colorStr);
    }

    if (edit.strokeWidth != null) {
      final widthStr = edit.strokeWidth.toString();
      element.setAttribute('stroke-width', widthStr);
      style = _updateStyleValue(style, 'stroke-width', widthStr);
    }

    if (edit.opacity != null) {
      final opacityStr = edit.opacity.toString();
      element.setAttribute('opacity', opacityStr);
      style = _updateStyleValue(style, 'opacity', opacityStr);
    }

    if (edit.transform != null) {
      element.setAttribute('transform', edit.transform!);
    }

    if (style.isNotEmpty) {
      element.setAttribute('style', style);
    }
  }

  /// Updates or inserts a property value in a CSS style string.
  static String _updateStyleValue(String style, String property, String value) {
    final regex = RegExp('$property\\s*:\\s*[^;]+');
    if (regex.hasMatch(style)) {
      return style.replaceAll(regex, '$property:$value');
    } else {
      if (style.isNotEmpty && !style.endsWith(';')) {
        style += ';';
      }
      return '$style$property:$value;';
    }
  }

  /// Converts a Flutter [Color] to a standard SVG hex or rgba string.
  static String _colorToSvgString(Color color) {
    final rVal = (color.r * 255).round();
    final gVal = (color.g * 255).round();
    final bVal = (color.b * 255).round();
    final aVal = (color.a * 255).round();

    final red = rVal.toRadixString(16).padLeft(2, '0').toUpperCase();
    final green = gVal.toRadixString(16).padLeft(2, '0').toUpperCase();
    final blue = bVal.toRadixString(16).padLeft(2, '0').toUpperCase();

    if (aVal == 255) {
      return '#$red$green$blue';
    } else {
      return 'rgba($rVal, $gVal, $bVal, ${color.a.toStringAsFixed(3)})';
    }
  }

  /// Queries the XML document using CSS-like selectors.
  static Iterable<xml.XmlElement> queryAdvanced({
    required xml.XmlDocument document,
    required String querySelector,
  }) {
    final queries = querySelector.split(',').map((q) => q.trim());
    final results = <xml.XmlElement>{};

    for (final query in queries) {
      if (query.isEmpty) continue;

      // Handle raw XML matching (e.g. <path id="xxx" ... />)
      if (query.startsWith('<') && query.endsWith('>')) {
        try {
          final rawElement = xml.XmlDocument.parse(query).rootElement;
          final matched =
              document.findAllElements(rawElement.name.local).where((element) {
            return element.toString() == rawElement.toString();
          });
          results.addAll(matched);
        } catch (_) {
          // Fallback if parsing fails
        }
        continue;
      }

      // Parse CSS selector attributes and index
      final splitQuery = query.split('[');
      final elementName = splitQuery[0].trim();
      int? index;

      // Check if last part is an index like [0]
      final lastPart = splitQuery.last;
      if (RegExp(r'^\d+\]$').hasMatch(lastPart)) {
        index = int.tryParse(lastPart.replaceAll(']', ''));
        splitQuery.removeLast();
      }

      final attributes = splitQuery
          .sublist(1)
          .map((attr) => attr.replaceAll(']', '').trim())
          .toList();

      Iterable<xml.XmlElement> elements;

      if (elementName.startsWith('#')) {
        elements =
            queryElements(document: document, id: elementName.substring(1));
      } else if (elementName.startsWith('.')) {
        elements = queryElements(
            document: document, className: elementName.substring(1));
      } else if (RegExp(r'^\d+$').hasMatch(elementName)) {
        elements = queryElements(
            document: document, childIndex: int.parse(elementName));
      } else {
        String targetTagName = elementName;
        String? targetClassName;
        if (elementName.contains('.')) {
          final parts = elementName.split('.');
          targetTagName = parts[0];
          targetClassName = parts[1];
        }

        elements = targetTagName.isEmpty
            ? document.descendants.whereType<xml.XmlElement>()
            : document.findAllElements(targetTagName);

        if (targetClassName != null && targetClassName.isNotEmpty) {
          elements = elements.where((element) {
            final classAttr = element.getAttribute('class');
            return classAttr != null &&
                classAttr.split(' ').contains(targetClassName);
          });
        }
      }

      // Filter by attributes
      if (attributes.isNotEmpty) {
        for (final attribute in attributes) {
          final splitAttribute = attribute.split('=');
          final attributeName = splitAttribute[0].trim();
          if (splitAttribute.length > 1) {
            var attributeValue = splitAttribute[1].trim();
            // Strip quotes around value
            if ((attributeValue.startsWith('"') &&
                    attributeValue.endsWith('"')) ||
                (attributeValue.startsWith("'") &&
                    attributeValue.endsWith("'"))) {
              attributeValue =
                  attributeValue.substring(1, attributeValue.length - 1);
            }

            elements = elements.where((element) {
              final val = element.getAttribute(attributeName);
              return val != null && val == attributeValue;
            });
          } else {
            // Just check if attribute exists
            elements = elements.where(
                (element) => element.getAttribute(attributeName) != null);
          }
        }
      }

      if (index != null) {
        if (index >= 0 && index < elements.length) {
          results.add(elements.elementAt(index));
        }
      } else {
        results.addAll(elements);
      }
    }

    return results;
  }

  /// Basic element query by ID, class, or child index.
  static Iterable<xml.XmlElement> queryElements({
    required xml.XmlDocument document,
    String? id,
    String? className,
    int? childIndex,
  }) {
    Iterable<xml.XmlElement> elements =
        document.descendants.whereType<xml.XmlElement>();

    if (id != null) {
      elements = elements.where((element) => element.getAttribute('id') == id);
    }

    if (className != null) {
      elements = elements.where((element) {
        final classAttr = element.getAttribute('class');
        return classAttr != null && classAttr.split(' ').contains(className);
      });
    }

    if (childIndex != null && childIndex >= 0 && childIndex < elements.length) {
      elements = [elements.elementAt(childIndex)];
    }

    return elements;
  }

  /// Extracts the parts of an SVG document into a list of [SvgElement]s.
  static List<SvgElement> extractComponentPartsAsSvg({
    required xml.XmlDocument document,
    List<String>? partNames,
  }) {
    final svgElements = <SvgElement>[];
    final extractedParts = <String>{};

    final elements = partNames == null || partNames.isEmpty
        ? document.descendants.whereType<xml.XmlElement>()
        : document.descendants
            .whereType<xml.XmlElement>()
            .where((element) => partNames.contains(element.name.local));

    const ignoredTags = {'svg', 'style', 'script', 'defs'};

    for (final element in elements) {
      if (!ignoredTags.contains(element.name.local)) {
        var svgElementString = element.toXmlString(pretty: true);

        // Remove existing transformations for the preview part
        if (element.getAttribute('transform') != null) {
          final updatedElement = element.copy();
          updatedElement.removeAttribute('transform');
          svgElementString = updatedElement.toXmlString(pretty: true);
        }

        if (extractedParts.add(svgElementString)) {
          svgElements.add(_createSvgElementFromXml(element));
        }
      }
    }

    return svgElements;
  }

  /// Extracts unique colors and maps them to their respective [SvgElement]s.
  static List<SvgColorElement> extractColorsAndElements(String svgContent) {
    final document = xml.XmlDocument.parse(svgContent);
    final colorPattern = RegExp(r'(?:fill|stroke)="([^"]+)"');
    final elements = document.descendants.whereType<xml.XmlElement>();

    final colorElementsMap = <Color, List<SvgElement>>{};

    for (final element in elements) {
      final elementString = element.toXmlString(pretty: true);
      final colorMatch = colorPattern.firstMatch(elementString);

      if (colorMatch != null) {
        final colorString = colorMatch.group(1)!;
        final color = ElementEdit.parseColor(colorString);

        if (color != null) {
          final svgElement = _createSvgElementFromXml(element);
          colorElementsMap.putIfAbsent(color, () => []).add(svgElement);
        }
      }
    }

    return colorElementsMap.entries
        .map((entry) => SvgColorElement(color: entry.key, parts: entry.value))
        .toList();
  }

  static SvgElement _createSvgElementFromXml(xml.XmlElement element) {
    final attributes = <String, String>{};
    for (final attr in element.attributes) {
      attributes[attr.name.local] = attr.value;
    }

    final children = element.children
        .whereType<xml.XmlElement>()
        .map((child) => _createSvgElementFromXml(child))
        .toList();

    const header = '''<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="800px" height="800px" viewBox="0 0 1024 1024" version="1.1" class="icon">''';
    const footer = '</svg>';

    final elementXmlString = element.toXmlString(pretty: true);

    return SvgElement(
      name: element.name.local,
      attributes: attributes,
      children: children,
      elementString: elementXmlString,
      elementSvg: ElementEdit.fromElementSvgString(element.toXmlString()),
      svgMountedString: '$header\n$elementXmlString\n$footer',
    );
  }
}
