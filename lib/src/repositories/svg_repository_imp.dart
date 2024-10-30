import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import '../models/element.dart';
import '../models/svg_element.dart';
import '../repositories/svg_repository.dart';

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
  void applyModifications(xml.XmlElement element, ElementSvg entity) {
    bool applyModification = false;

    // Verifica se o elemento corresponde ao alvo especificado
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

    // Aplica as modificações somente se o elemento corresponder ao alvo
    if (applyModification) {
      // Recupera ou cria o atributo style do elemento
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

      // Atualiza o atributo 'style' se houver modificações
      if (style.isNotEmpty) {
        element.setAttribute('style', style);
      }
    }
  }

// //Função auxiliar para obter o valor de uma propriedade no estilo
//   String? _getStyleValue(String style, String property) {
//     final regex = RegExp(r'${property}\s*:\s*([^;]+)');
//     final match = regex.firstMatch(style);
//     return match?.group(1);
//   }

// Função auxiliar para atualizar ou adicionar um valor no estilo
  String _updateStyleValue(String style, String property, String value) {
    // Cria a expressão regular corretamente com interpolação de strings
    final regex = RegExp('$property\\s*:\\s*[^;]+');

    if (regex.hasMatch(style)) {
      // Substitui a propriedade no estilo existente
      return style.replaceAll(regex, '$property:$value');
    } else {
      // Verifica se precisa adicionar ponto-e-vírgula no fim do estilo
      if (style.isNotEmpty && !style.endsWith(';')) {
        style += ';';
      }
      // Adiciona a nova propriedade ao estilo
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

  // Função para query avançada

  Iterable<xml.XmlElement> queryAdvanced({
    required xml.XmlDocument document,
    required String querySelector,
  }) {
    // Divide a consulta por "[" para separar o nome do elemento e os atributos
    final splitQuery = querySelector.split('[');
    final elementName = splitQuery[0];
    int? index;

    // Verifica se o índice está no último componente entre colchetes
    final lastPart = splitQuery.last;
    if (RegExp(r'^\d+\]$').hasMatch(lastPart)) {
      index = int.tryParse(lastPart.replaceAll(']', ''));
      splitQuery.removeLast(); // Remove o índice da lista de atributos
    }

    final attributes =
        splitQuery.sublist(1).map((attr) => attr.replaceAll(']', '')).toList();

    // Filtra os elementos pelo nome
    var elements = document.findAllElements(elementName);

    // Filtra os elementos pelos atributos
    if (attributes.isNotEmpty) {
      for (final attribute in attributes) {
        final splitAttribute = attribute.split('=');
        final attributeName = splitAttribute[0];
        final attributeValue = splitAttribute[1]
            .substring(1, splitAttribute[1].length - 1); // Remove as aspas

        elements = elements.where((element) {
          final elementAttrValue = element.getAttribute(attributeName);
          return elementAttrValue != null && elementAttrValue == attributeValue;
        });
      }
    } else {
      final elementName = splitQuery[0];
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

    // Retorna apenas o elemento no índice especificado, ou todos se índice for nulo
    if (index != null && index < elements.length) {
      return [elements.elementAt(index)];
    }
    return elements;
  }

  @override
  List<SvgElement> extractComponentPartsAsSvg({
    required xml.XmlDocument document,
    List<String>? partNames,
  }) {
    List<SvgElement> svgElements = [];
    Set<String> extractedParts = <String>{};

    // Se partNames for nulo ou vazio, consideramos todas as partes
    final elements = partNames == null || partNames.isEmpty
        ? document.descendants.whereType<xml.XmlElement>()
        : document.descendants
            .whereType<xml.XmlElement>()
            .where((element) => partNames.contains(element.name.local));

    for (final element in elements) {
      if (element.name.local != 'svg') {
        var svgElementString = element.toXmlString(pretty: true);

        // Remover transformações existentes (como translate)
        if (element.getAttribute('transform') != null) {
          final updatedElement = element.copy();
          updatedElement.removeAttribute('transform');
          svgElementString = updatedElement.toXmlString(pretty: true);
        }

        if (!extractedParts.contains(svgElementString)) {
          extractedParts.add(svgElementString);

          // Cria o objeto SvgElement
          final svgElement = _createSvgElementFromXml(element);

          // Adiciona o SvgElement à lista
          svgElements.add(svgElement);
        }
      }
    }

    return svgElements;
  }

  Future<xml.XmlDocument> injectCss(xml.XmlDocument document, String css) {
    // Encontra o elemento <defs> no documento SVG, se existir
    final defsElements = document.findAllElements('defs');
    final styleElements = document.findAllElements('style');
    final defsElement = defsElements.isNotEmpty ? defsElements.first : null;

    // Cria um elemento <style> com o CSS fornecido
    final styleElement = xml.XmlElement(
      xml.XmlName('style'),
      [xml.XmlAttribute(xml.XmlName('type'), 'text/css')],
      [xml.XmlText(css)],
    );

    if (defsElement != null) {
      if (styleElements.isNotEmpty) {
        // Atualiza o conteúdo do primeiro elemento <style>
        final existingStyleElement = styleElements.first;
        existingStyleElement.children.clear();
        existingStyleElement.children.add(xml.XmlText(css));
      } else {
        // Adiciona o novo elemento <style> ao elemento <defs>
        defsElement.children.add(styleElement);
      }
    } else {
      // Se não existir, adiciona o elemento <defs> ao documento
      final newDefsElement = xml.XmlElement(
        xml.XmlName('defs'),
        [],
        [styleElement],
      );
      document.children.insert(0, newDefsElement);
    }

    // Retorna o documento modificado
    return Future.value(document);
  }

  SvgElement _createSvgElementFromXml(xml.XmlElement element) {
    // Cria um mapa de atributos a partir dos atributos do XmlElement
    final attributes = <String, String>{};
    for (var attr in element.attributes) {
      attributes[attr.name.local] = attr.value;
    }

    // Cria uma lista de filhos recursivamente
    final children = element.children
        .whereType<xml.XmlElement>()
        .map((child) => _createSvgElementFromXml(child))
        .toList();

    const header = '''<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="800px" height="800px" viewBox="0 0 1024 1024" version="1.1" class="icon">''';

    const footer = '</svg>';

    // Retorna o SvgElement com os dados do elemento XML
    return SvgElement(
        name: element.name.local,
        attributes: attributes,
        children: children,
        elementSvgString: element.toXmlString(pretty: true),
        svgString: """
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
}
