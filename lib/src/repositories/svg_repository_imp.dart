import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import '../../svg_pic_editor.dart';

class SvgRepositoryImpl implements SvgRepository {
  @override
  Future<String> loadSvg(String path, String? package) async {
    return await rootBundle.loadString(
      package != null ? 'packages/$package/$path' : path,
    );
  }

  @override
  Iterable<xml.XmlElement> queryElements({
    required xml.XmlDocument document,
    String? id,
    String? className,
    int? childIndex,
  }) {
    Iterable<xml.XmlElement> elements =
        document.descendants.whereType<xml.XmlElement>();

    if (id != null || className != null || childIndex != null) {
      if (id != null) {
        elements =
            elements.where((element) => element.getAttribute('id') == id);
      } else if (className != null) {
        elements = elements.where((element) {
          final classAttr = element.getAttribute('class');
          return classAttr != null && classAttr.split(' ').contains(className);
        });
      }

      if (childIndex != null && childIndex < elements.length) {
        elements = [elements.elementAt(childIndex)];
      }

      return elements;
    }
    return elements;
  }

  @override
  void applyModifications(xml.XmlElement element, ElementEdit entity) {
    bool applyModification = false;

    // Checks if the element matches the specified target
    if (entity.id != null && element.getAttribute('id') == entity.id) {
      applyModification = true;
    }

    if (entity.querySelector != null) {
      final queryElements = queryAdvanced(
          document: element.document!, querySelector: entity.querySelector!);
      if (queryElements.contains(element)) {
        applyModification = true;
      }
    }

    // Applies modifications only if the element matches the target
    if (applyModification) {
      // Retrieves or creates the element's style attribute
      String style = element.getAttribute('style') ?? '';

      if (entity.fillColor != null) {
        element.setAttribute('fill', _colorToSvgString(entity.fillColor!));
        style = _updateStyleValue(
            style, 'fill', _colorToSvgString(entity.fillColor!));
      }

      if (entity.strokeColor != null) {
        element.setAttribute('stroke', _colorToSvgString(entity.strokeColor!));
        style = _updateStyleValue(
            style, 'stroke', _colorToSvgString(entity.strokeColor!));
      }

      if (entity.strokeWidth != null) {
        element.setAttribute('stroke-width', entity.strokeWidth.toString());
        style = _updateStyleValue(
            style, 'stroke-width', entity.strokeWidth.toString());
      }

      if (entity.opacity != null) {
        element.setAttribute('opacity', entity.opacity.toString());
        style = _updateStyleValue(style, 'opacity', entity.opacity.toString());
      }

      if (entity.transform != null) {
        element.setAttribute('transform', entity.transform!);
      }

      // Update the 'style' attribute if there are changes
      if (style.isNotEmpty) {
        element.setAttribute('style', style);
      }
    }
  }

// Helper function to update or add a value to the style
  String _updateStyleValue(String style, String property, String value) {
    // Create regular expression correctly with string interpolation
    final regex = RegExp('$property\\s*:\\s*[^;]+');

    if (regex.hasMatch(style)) {
      // Replaces the property in the existing style
      return style.replaceAll(regex, '$property:$value');
    } else {
      // Check if you need to add a semicolon at the end of the style
      if (style.isNotEmpty && !style.endsWith(';')) {
        style += ';';
      }
      // Add the new property to the style
      return '$style$property:$value;';
    }
  }

  String _colorToSvgString(Color color) {
    final red = color.red.toRadixString(16).padLeft(2, '0').toUpperCase();
    final green = color.green.toRadixString(16).padLeft(2, '0').toUpperCase();
    final blue = color.blue.toRadixString(16).padLeft(2, '0').toUpperCase();

    if (color.alpha == 255) {
      return '#$red$green$blue';
    } else {
      return 'rgba($red, $green, $blue, ${color.alpha / 255.0})';
    }
  }

  // Function for advanced query

  Iterable<xml.XmlElement> queryAdvanced({
    required xml.XmlDocument document,
    required String querySelector,
  }) {
    // Divide the query by commas to handle multiple selectors
    final queries = querySelector.split(',').map((query) => query.trim());

// List to accumulate all found elements
    final results = <xml.XmlElement>[];

    for (final query in queries) {
      final isFullElement = query.startsWith('<') && query.endsWith('>');

      if (isFullElement) {
        // Search for the complete element within the document
        final rawElement = xml.XmlDocument.parse(query).rootElement;
        final matchedElements =
            document.findAllElements(rawElement.name.local).where((element) {
          return element.toString() == rawElement.toString();
        });
        results.addAll(matchedElements);
      } else {
        // Divide the query by "[" to separate the element name and attributes
        final splitQuery = query.split('[');
        final elementName = splitQuery[0];
        int? index;

        // Checks if the index is in the last component between square brackets
        final lastPart = splitQuery.last;
        if (RegExp(r'^\d+\]$').hasMatch(lastPart)) {
          index = int.tryParse(lastPart.replaceAll(']', ''));
          splitQuery.removeLast(); // Remove o índice da lista de atributos
        }

        final attributes = splitQuery
            .sublist(1)
            .map((attr) => attr.replaceAll(']', ''))
            .toList();

        // Filter elements by name
        var elements = document.findAllElements(elementName);

        // Filter elements by attributes
        if (attributes.isNotEmpty) {
          for (final attribute in attributes) {
            final splitAttribute = attribute.split('=');
            final attributeName = splitAttribute[0];
            final attributeValue =
                splitAttribute[1].substring(1, splitAttribute[1].length - 1);

            elements = elements.where((element) {
              final elementAttrValue = element.getAttribute(attributeName);
              return elementAttrValue != null &&
                  elementAttrValue == attributeValue;
            });
          }
        } else {
          final String? id =
              elementName.startsWith('#') ? elementName.substring(1) : null;
          final String? className =
              elementName.startsWith('.') ? elementName.substring(1) : null;
          final int? childIndex = int.tryParse(elementName);

          elements = queryElements(
            document: document,
            id: id,
            className: className,
            childIndex: childIndex,
          );
        }

        // Adds the element at the specified index, or all if index is null
        if (index != null && index < elements.length) {
          results.add(elements.elementAt(index));
        } else {
          results.addAll(elements);
        }
      }
    }

    return results;
  }

  @override
  List<SvgElement> extractComponentPartsAsSvg({
    required xml.XmlDocument document,
    List<String>? partNames,
  }) {
    List<SvgElement> svgElements = [];
    Set<String> extractedParts = <String>{};

// If partNames is null or empty, we consider all parts
    final elements = partNames == null || partNames.isEmpty
        ? document.descendants.whereType<xml.XmlElement>()
        : document.descendants
            .whereType<xml.XmlElement>()
            .where((element) => partNames.contains(element.name.local));

    for (final element in elements) {
      if (element.name.local != 'svg') {
        var svgElementString = element.toXmlString(pretty: true);

        // Remove existing transformations (like translate)
        if (element.getAttribute('transform') != null) {
          final updatedElement = element.copy();
          updatedElement.removeAttribute('transform');
          svgElementString = updatedElement.toXmlString(pretty: true);
        }

        if (!extractedParts.contains(svgElementString)) {
          extractedParts.add(svgElementString);

          // Create the SvgElement object
          final svgElement = _createSvgElementFromXml(element);

          // Add SvgElement to the list
          svgElements.add(svgElement);
        }
      }
    }

    return svgElements;
  }

  Future<xml.XmlDocument> injectCss(xml.XmlDocument document, String css) {
// Find the <defs> element in the SVG document, if it exists
    final defsElements = document.findAllElements('defs');
    final styleElements = document.findAllElements('style');
    final defsElement = defsElements.isNotEmpty ? defsElements.first : null;

    // Create a <style> element with the given CSS
    final styleElement = xml.XmlElement(
      xml.XmlName('style'),
      [xml.XmlAttribute(xml.XmlName('type'), 'text/css')],
      [xml.XmlText(css)],
    );

    if (defsElement != null) {
      if (styleElements.isNotEmpty) {
        // Update the content of the first <style> element
        final existingStyleElement = styleElements.first;
        existingStyleElement.children.clear();
        existingStyleElement.children.add(xml.XmlText(css));
      } else {
        // Add the new <style> element to the <defs> element
        defsElement.children.add(styleElement);
      }
    } else {
      // If it doesn't exist, add the <defs> element to the document
      final newDefsElement = xml.XmlElement(
        xml.XmlName('defs'),
        [],
        [styleElement],
      );
      document.children.insert(0, newDefsElement);
    }

    // Returns the modified document
    return Future.value(document);
  }

  SvgElement _createSvgElementFromXml(xml.XmlElement element) {
// Create an attribute map from the XmlElement attributes
    final attributes = <String, String>{};
    for (var attr in element.attributes) {
      attributes[attr.name.local] = attr.value;
    }

    // Create a list of children recursively
    final children = element.children
        .whereType<xml.XmlElement>()
        .map((child) => _createSvgElementFromXml(child))
        .toList();

    const header = '''<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="800px" height="800px" viewBox="0 0 1024 1024" version="1.1" class="icon">''';

    const footer = '</svg>';

    // Returns SvgElement with the XML element data
    return SvgElement(
        name: element.name.local,
        attributes: attributes,
        children: children,
        elementString: element.toXmlString(pretty: true),
        elementSvg: ElementEdit.fromElementSvgString(element.toXmlString()),
        svgMountedString: """
      $header
      ${element.toXmlString(pretty: true)}
      $footer
      """);
  }

  @override
  Future<List<SvgElement>> extractComponentPartsAsSvgFromPathOrString({
    required String svgContentOrPath,
    List<String>? partNames,
    bool isAsset = false,
  }) async {
    final content = isAsset
        ? await rootBundle.loadString(svgContentOrPath)
        : svgContentOrPath;

    final document = xml.XmlDocument.parse(content);

    return extractComponentPartsAsSvg(
      document: document,
      partNames: partNames,
    );
  }

  @override
  Future<String> loadNetwork(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load SVG from network');
    }
  }

  Future<List<SvgColorElement>> extractColorsAndElements(
      String svgContent) async {
    // Parse the SVG document
    final document = xml.XmlDocument.parse(svgContent);

    // Regex to search for color in fill or stroke
    final colorPattern = RegExp(r'(?:fill|stroke)="([^"]+)"');
    final elements = document.descendants.whereType<xml.XmlElement>();

    // Color mapping for SVG element list
    final colorElementsMap = <Color, List<SvgElement>>{};

    for (final element in elements) {
      final elementString = element.toXmlString(pretty: true);

      // Search for color in the current element
      final colorMatch = colorPattern.firstMatch(elementString);
      if (colorMatch != null) {
        final colorString = colorMatch.group(1)!;
        final color = _parseColor(colorString);

// If the color is valid, add the element to the map
        if (color != null) {
          final svgElement = _createSvgElementFromXml(element);

          // Adds the element to the color map; prevents key duplication
          colorElementsMap.putIfAbsent(color, () => []).add(svgElement);
        }
      }
    }

    // Remove any additional duplication and convert the map to a list
    final uniqueColorElements = <SvgColorElement>[];
    final seenColors = <Color>{};

    for (var entry in colorElementsMap.entries) {
      if (seenColors.add(entry.key)) {
        uniqueColorElements
            .add(SvgColorElement(color: entry.key, parts: entry.value));
      }
    }

    return uniqueColorElements;
  }

// Helper function to convert color string to Color object
  Color? _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        final hexColor = colorString.replaceFirst('#', '');
        final color = int.parse(hexColor, radix: 16);
        return Color(color | 0xFF000000); // If hexadecimal, sets full opacity
      } else if (colorString.startsWith('rgba')) {
// Parse of rgba (ex: rgba(255, 0, 0, 1))
        final rgbaValues = RegExp(r'rgba\((\d+), (\d+), (\d+), (\d+.\d+)\)')
            .firstMatch(colorString);
        if (rgbaValues != null) {
          final r = int.parse(rgbaValues.group(1)!);
          final g = int.parse(rgbaValues.group(2)!);
          final b = int.parse(rgbaValues.group(3)!);
          final a = double.parse(rgbaValues.group(4)!) * 255;

          return Color.fromARGB(a.toInt(), r, g, b);
        }
      }
    } catch (e) {
      debugPrint('Erro ao converter cor: $e');
    }
    return null;
  }
}
