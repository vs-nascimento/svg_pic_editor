import 'package:flutter/material.dart';

class ElementEdit {
  final String? id;
  final Color? fillColor;
  final Color? strokeColor;
  final double? strokeWidth;
  final double? opacity;
  final String? transform;
  final String? querySelector;

  ElementEdit({
    this.id,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth,
    this.opacity,
    this.transform,
    this.querySelector,
  });

  // Função para criar um ElementSvg a partir de uma string SVG
  static ElementEdit fromElementSvgString(String elementSvgString) {
    final RegExp tagPattern = RegExp(r'<(\w+)(.*?)\/?>', dotAll: true);
    final match = tagPattern.firstMatch(elementSvgString);

    if (match == null) {
      throw const FormatException('Elemento SVG inválido');
    }

    final attributesString = match.group(2)!;

    // Parse de atributos
    final attributes = _parseAttributes(attributesString);

    return ElementEdit(
      querySelector: elementSvgString,
      fillColor: _parseColor(attributes['fill']),
      strokeColor: _parseColor(attributes['stroke']),
      strokeWidth: _parseDouble(attributes['stroke-width']),
      opacity: _parseDouble(attributes['opacity']),
      transform: attributes['transform'],
    );
  }

  // Função auxiliar para extrair os atributos de uma string
  static Map<String, String> _parseAttributes(String attributesString) {
    final Map<String, String> attributes = {};

    final attributePattern = RegExp(r'(\w+)="([^"]*)"');
    final matches = attributePattern.allMatches(attributesString);

    for (var match in matches) {
      final key = match.group(1);
      final value = match.group(2);
      if (key != null && value != null) {
        attributes[key] = value;
      }
    }

    return attributes;
  }

  // Função auxiliar para converter string de cor para objeto Color
  static Color? _parseColor(String? colorString) {
    if (colorString == null) return null;

    try {
      if (colorString.startsWith('#')) {
        final hexColor = colorString.replaceFirst('#', '');
        final color = int.parse(hexColor, radix: 16);
        return Color(
            color | 0xFF000000); // Se for hexadecimal, define opacidade total
      } else if (colorString.startsWith('rgba')) {
        // Parse de rgba (ex: rgba(255, 0, 0, 1))
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

  // Função auxiliar para converter string de double
  static double? _parseDouble(String? value) {
    if (value == null) return null;
    return double.tryParse(value);
  }

  ElementEdit copyWith({
    String? id,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    double? opacity,
    String? transform,
    String? querySelector,
  }) {
    return ElementEdit(
      id: id ?? this.id,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      opacity: opacity ?? this.opacity,
      transform: transform ?? this.transform,
      querySelector: querySelector ?? this.querySelector,
    );
  }
}
