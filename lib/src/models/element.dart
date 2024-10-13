import 'package:flutter/material.dart';

class ElementSvg {
  final String? id;
  final Color? fillColor;
  final Color? strokeColor;
  final double? strokeWidth;
  final double? opacity;
  final String? transform;
  final String? querySelector;
  final String? cssInjector;

  ElementSvg({
    this.id,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth,
    this.opacity,
    this.transform,
    this.querySelector,
    this.cssInjector,
  });
}
