import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';

import '../models/element.dart';
import '../repositories/svg_repository_imp.dart';

class ModifySvgUseCase {
  final SvgRepositoryImpl _repository;

  ModifySvgUseCase(this._repository);

  Future<String> call({
    required String svgContent,
    required List<ElementSvg> elements,
  }) async {
    XmlDocument document = xml.XmlDocument.parse(svgContent);

    for (final element in elements) {
      if (element.querySelector != null) {
        final queryResult = _repository.queryAdvanced(
          document: document,
          querySelector: element.querySelector!,
        );
        for (final xmlElement in queryResult) {
          _repository.applyModifications(xmlElement, element);
        }
      } else {
        final queryResult = _repository.queryElements(
          document: document,
          id: element.id,
        );
        for (final xmlElement in queryResult) {
          _repository.applyModifications(xmlElement, element);
        }
      }
    }
    return document.toXmlString(pretty: true);
  }
}
