import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart' as xml;
import 'package:svg_pic_editor/svg_pic_editor.dart';

void main() {
  const sampleSvg = '''<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <style>
    .cls-1 { fill: #ffffff; }
  </style>
  <script>
    console.log("hello");
  </script>
  <rect id="background" fill="#000000" width="100" height="100" />
  <circle class="bullet" fill="#FF0000" cx="50" cy="50" r="10" opacity="0.8" />
  <path id="star" fill="#00FF00" d="M50 0 L60 40 L100 40 L70 60 L80 100 L50 80 L20 100 L30 60 L0 40 L40 40 Z" />
</svg>''';

  group('SvgEditorCore Tests', () {
    test('cleanSvg should remove style and script tags', () {
      final cleaned = SvgEditorCore.cleanSvg(sampleSvg);
      expect(cleaned, isNot(contains('<style>')));
      expect(cleaned, isNot(contains('</style>')));
      expect(cleaned, isNot(contains('<script>')));
      expect(cleaned, isNot(contains('</script>')));
      expect(cleaned, contains('id="background"'));
    });

    test('modifySvg should modify element by ID', () {
      final modified = SvgEditorCore.modifySvg(
        svgContent: sampleSvg,
        modifications: [
          ElementEdit(
            id: 'background',
            fillColor: Colors.blue,
            opacity: 0.5,
          ),
        ],
      );

      final doc = xml.XmlDocument.parse(modified);
      final bg = doc.descendants.whereType<xml.XmlElement>().firstWhere((el) => el.getAttribute('id') == 'background');

      // Colors.blue is 0xFF2196F3 -> #2196F3
      expect(bg.getAttribute('fill'), equals('#2196F3'));
    });

    test('modifySvg should remove element when remove is true', () {
      final modified = SvgEditorCore.modifySvg(
        svgContent: sampleSvg,
        modifications: [
          ElementEdit(
            id: 'background',
            remove: true,
          ),
        ],
      );

      final doc = xml.XmlDocument.parse(modified);
      final hasBg = doc.descendants.whereType<xml.XmlElement>().any((el) => el.getAttribute('id') == 'background');
      expect(hasBg, isFalse);
    });

    test('modifySvg should apply borderRadius to rect elements', () {
      final modified = SvgEditorCore.modifySvg(
        svgContent: sampleSvg,
        modifications: [
          ElementEdit(
            id: 'background',
            borderRadius: 15.0,
          ),
        ],
      );

      final doc = xml.XmlDocument.parse(modified);
      final bg = doc.descendants.whereType<xml.XmlElement>().firstWhere((el) => el.getAttribute('id') == 'background');
      expect(bg.getAttribute('rx'), equals('15.0'));
      expect(bg.getAttribute('ry'), equals('15.0'));
    });

    test('modifySvg should modify elements by CSS query selector', () {
      final modified = SvgEditorCore.modifySvg(
        svgContent: sampleSvg,
        modifications: [
          ElementEdit(
            querySelector: 'circle.bullet',
            fillColor: Colors.yellow,
            strokeColor: Colors.black,
            strokeWidth: 2.0,
          ),
          ElementEdit(
            querySelector: 'path[fill="#00FF00"]',
            fillColor: Colors.purple,
            transform: 'rotate(45 50 50)',
          ),
        ],
      );

      final doc = xml.XmlDocument.parse(modified);
      
      final circle = doc.descendants.whereType<xml.XmlElement>().firstWhere((el) => el.name.local == 'circle');
      expect(circle.getAttribute('fill'), equals('#FFEB3B')); // Colors.yellow
      expect(circle.getAttribute('stroke'), equals('#000000'));
      expect(circle.getAttribute('stroke-width'), equals('2.0'));

      final path = doc.descendants.whereType<xml.XmlElement>().firstWhere((el) => el.name.local == 'path');
      expect(path.getAttribute('fill'), equals('#9C27B0')); // Colors.purple
      expect(path.getAttribute('transform'), equals('rotate(45 50 50)'));
    });

    test('extractColorsAndElements should find all unique colors', () {
      final colors = SvgEditorCore.extractColorsAndElements(sampleSvg);

      // Colors in the SVG:
      // #000000 (black) in rect
      // #FF0000 (red) in circle
      // #00FF00 (green) in path
      expect(colors.length, equals(3));
      
      final hexColors = colors.map((c) => c.color.toARGB32().toRadixString(16).substring(2).toUpperCase()).toList();
      expect(hexColors, contains('000000'));
      expect(hexColors, contains('FF0000'));
      expect(hexColors, contains('00FF00'));
    });

    test('extractComponentPartsAsSvg should extract parts', () {
      final doc = xml.XmlDocument.parse(sampleSvg);
      final parts = SvgEditorCore.extractComponentPartsAsSvg(document: doc);

      // Parts should be: rect, circle, path
      expect(parts.length, equals(3));
      expect(parts[0].name, equals('rect'));
      expect(parts[1].name, equals('circle'));
      expect(parts[2].name, equals('path'));

      expect(parts[0].svgMountedString, contains('<svg'));
      expect(parts[0].svgMountedString, contains('</svg>'));
    });
  });
}
