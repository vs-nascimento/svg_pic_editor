
import '../models/svg_element.dart';
import '../repositories/svg_repository.dart';
import '../repositories/svg_repository_imp.dart';

class SvgMapperParts {
  final SvgRepository _repository = SvgRepositoryImpl();


  Future<List<SvgElement>> loadAsset(
      {required String assetPath, required List<String> partNames}) async {
    return _repository.extractComponentPartsAsSvgFromPathOrString(
      svgContentOrPath: assetPath,
      partNames: partNames,
      isAsset: true,
    );
  }

  Future<List<SvgElement>> loadNetwork(
      {required String url, required List<String> partNames}) async {
    final svgContent = await _repository.loadNetwork(url);
    return _repository.extractComponentPartsAsSvgFromPathOrString(
      svgContentOrPath: svgContent,
      partNames: partNames,
    );
  }

  Future<List<SvgElement>> loadString(
      {required String svgContent, required List<String> partNames}) async {
    return _repository.extractComponentPartsAsSvgFromPathOrString(
      svgContentOrPath: svgContent,
      partNames: partNames,
    );
  }
}
