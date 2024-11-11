import 'package:flutter/material.dart';

import '../../svg_pic_editor.dart';

class SvgColorElement {
  final Color color;
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
