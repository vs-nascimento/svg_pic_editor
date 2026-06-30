import 'package:flutter/material.dart';
import 'svg_element.dart';

/// Represents a unique color found in an SVG, mapped to all [SvgElement]s that use it.
class SvgColorElement {
  /// The color value.
  final Color color;

  /// The list of SVG elements containing this color (in fill or stroke).
  final List<SvgElement> parts;

  SvgColorElement({
    required this.color,
    required this.parts,
  });

  SvgColorElement copyWith({
    Color? color,
    List<SvgElement>? parts,
  }) {
    return SvgColorElement(
      color: color ?? this.color,
      parts: parts ?? this.parts,
    );
  }
}
