import 'package:flutter/material.dart';

/// Represents a set of modifications to be applied to a specific SVG element.
class ElementEdit {
  /// The ID of the SVG element to modify.
  final String? id;

  /// The CSS query selector to identify the element(s) to modify.
  /// Examples: `#element-id`, `path[fill="#ffffff"]`, `.class-name`.
  final String? querySelector;

  /// The new fill color of the element.
  final Color? fillColor;

  /// The new stroke color of the element.
  final Color? strokeColor;

  /// The new stroke width of the element.
  final double? strokeWidth;

  /// The new opacity of the element (0.0 to 1.0).
  final double? opacity;

  /// The new transform attribute of the element (e.g. `translate(10, 20)`).
  final String? transform;

  /// Whether the element should be removed from the SVG.
  final bool? remove;

  /// The border radius of the element (applicable to rects as rx/ry).
  final double? borderRadius;

  ElementEdit({
    this.id,
    this.querySelector,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth,
    this.opacity,
    this.transform,
    this.remove,
    this.borderRadius,
  });

  /// Creates an [ElementEdit] by parsing an SVG element string.
  factory ElementEdit.fromElementSvgString(String elementSvgString) {
    final RegExp tagPattern = RegExp(r'<(\w+)(.*?)\/?>', dotAll: true);
    final match = tagPattern.firstMatch(elementSvgString);

    if (match == null) {
      throw const FormatException('Invalid SVG element');
    }

    final attributesString = match.group(2)!;
    final attributes = _parseAttributes(attributesString);

    return ElementEdit(
      querySelector: elementSvgString,
      fillColor: parseColor(attributes['fill']),
      strokeColor: parseColor(attributes['stroke']),
      strokeWidth: _parseDouble(attributes['stroke-width']),
      opacity: _parseDouble(attributes['opacity']),
      transform: attributes['transform'],
      remove: false,
      borderRadius: _parseDouble(attributes['rx']) ?? _parseDouble(attributes['ry']),
    );
  }

  static Map<String, String> _parseAttributes(String attributesString) {
    final Map<String, String> attributes = {};
    final attributePattern = RegExp(r'([\w\-]+)="([^"]*)"');
    final matches = attributePattern.allMatches(attributesString);

    for (final match in matches) {
      final key = match.group(1);
      final value = match.group(2);
      if (key != null && value != null) {
        attributes[key] = value;
      }
    }

    return attributes;
  }

  static Color? parseColor(String? colorString) {
    if (colorString == null || colorString == 'none') return null;

    try {
      if (colorString.startsWith('#')) {
        final hexColor = colorString.replaceFirst('#', '');
        if (hexColor.length == 3) {
          // Handle shorthand hex like #FFF -> #FFFFFF
          final r = hexColor[0];
          final g = hexColor[1];
          final b = hexColor[2];
          return Color(int.parse('FF$r$r$g$g$b$b', radix: 16));
        }
        final colorValue = int.parse(hexColor, radix: 16);
        if (hexColor.length == 8) {
          return Color(colorValue);
        }
        return Color(colorValue | 0xFF000000);
      } else if (colorString.startsWith('rgba')) {
        final rgbaValues = RegExp(r'rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d*(?:\.\d+)?)\s*\)')
            .firstMatch(colorString);
        if (rgbaValues != null) {
          final r = int.parse(rgbaValues.group(1)!);
          final g = int.parse(rgbaValues.group(2)!);
          final b = int.parse(rgbaValues.group(3)!);
          final a = double.parse(rgbaValues.group(4)!) * 255;
          return Color.fromARGB(a.toInt(), r, g, b);
        }
      } else if (colorString.startsWith('rgb')) {
        final rgbValues = RegExp(r'rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)')
            .firstMatch(colorString);
        if (rgbValues != null) {
          final r = int.parse(rgbValues.group(1)!);
          final g = int.parse(rgbValues.group(2)!);
          final b = int.parse(rgbValues.group(3)!);
          return Color.fromARGB(255, r, g, b);
        }
      }
    } catch (e) {
      debugPrint('Error parsing color: $e');
    }
    return null;
  }

  static double? _parseDouble(String? value) {
    if (value == null) return null;
    return double.tryParse(value);
  }

  ElementEdit copyWith({
    String? id,
    String? querySelector,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    double? opacity,
    String? transform,
    bool? remove,
    double? borderRadius,
  }) {
    return ElementEdit(
      id: id ?? this.id,
      querySelector: querySelector ?? this.querySelector,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      opacity: opacity ?? this.opacity,
      transform: transform ?? this.transform,
      remove: remove ?? this.remove,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}
