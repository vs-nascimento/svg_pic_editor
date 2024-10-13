import 'package:xml/xml.dart' as xml;
import 'package:flutter/material.dart';

import '../models/element.dart';

class ApplyModificationsUseCase {
  void call(xml.XmlElement element, ElementSvg entity) {
    bool applyModification = false;

    if (entity.id != null && element.getAttribute('id') == entity.id) {
      applyModification = true;
    }

    if (applyModification) {
      if (entity.fillColor != null) {
          element.setAttribute('fill', _colorToSvgString(entity.fillColor!));
      }

      if (entity.strokeColor != null) {
          element.setAttribute('stroke', _colorToSvgString(entity.strokeColor!));
      }

      if (entity.strokeWidth != null) {
        element.setAttribute('stroke-width', entity.strokeWidth.toString());
      }

      if (entity.opacity != null) {
        element.setAttribute('opacity', entity.opacity.toString());
      }

      if (entity.transform != null) {
        element.setAttribute('transform', entity.transform!);
      }
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
}
