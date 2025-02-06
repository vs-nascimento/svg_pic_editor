import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../svg_pic_editor.dart';
import '../../usecases/load_network_svg_use_case.dart';
import '../../usecases/load_svg_use_case.dart';

/// Widget que exibe um SVG com possibilidade de modificação e,
/// por padrão, com efeito de toque (splash) no formato do próprio SVG.
class SvgPicEditor extends StatefulWidget {
  final String? assetName;
  final String? svgString;
  final String? svgUrl;
  final String? package;
  final List<ElementEdit>? modifications;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? querySelector;
  final Color? color;
  final Function(String)? listenEdit;
  final Function(List<SvgElement>)? getParts;
  final Function(List<SvgColorElement>)? getColors;
  final Function? onTap;

  /// Permite que o usuário informe um ShapeBorder customizado para o splash.
  /// Se não for informado, usaremos o formato extraído do SVG (quando possível).
  final ShapeBorder? splashShape;

  const SvgPicEditor._({
    Key? key,
    this.assetName,
    this.svgString,
    this.svgUrl,
    this.package,
    this.modifications,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.querySelector,
    this.color,
    this.listenEdit,
    this.getParts,
    this.getColors,
    this.onTap,
    this.splashShape,
  }) : super(key: key);

  static SvgPicEditor asset(
    String assetName, {
    String? package,
    List<ElementEdit>? modifications,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    String? querySelector,
    Color? color,
    Function(String)? listenEdit,
    Function(List<SvgElement>)? getParts,
    Function(List<SvgColorElement>)? getColors,
    Function? onTap,
    ShapeBorder? splashShape,
  }) {
    return SvgPicEditor._(
      assetName: assetName,
      package: package,
      modifications: modifications,
      width: width,
      height: height,
      fit: fit,
      querySelector: querySelector,
      color: color,
      listenEdit: listenEdit,
      getParts: getParts,
      getColors: getColors,
      onTap: onTap,
      splashShape: splashShape,
    );
  }

  static SvgPicEditor network(
    String svgUrl, {
    List<ElementEdit>? modifications,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    String? querySelector,
    Color? color,
    Function(String)? listenEdit,
    Function(List<SvgElement>)? getParts,
    Function(List<SvgColorElement>)? getColors,
    Function? onTap,
    ShapeBorder? splashShape,
  }) {
    return SvgPicEditor._(
      svgUrl: svgUrl,
      modifications: modifications,
      width: width,
      height: height,
      fit: fit,
      querySelector: querySelector,
      color: color,
      listenEdit: listenEdit,
      getParts: getParts,
      getColors: getColors,
      onTap: onTap,
      splashShape: splashShape,
    );
  }

  static SvgPicEditor string(
    String svgString, {
    List<ElementEdit>? modifications,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    String? querySelector,
    Color? color,
    Function(String)? listenEdit,
    Function(List<SvgElement>)? getParts,
    Function(List<SvgColorElement>)? getColors,
    Function(String? svgModifiedString)? onTap,
    ShapeBorder? splashShape,
  }) {
    return SvgPicEditor._(
      svgString: svgString,
      modifications: modifications,
      width: width,
      height: height,
      fit: fit,
      querySelector: querySelector,
      color: color,
      listenEdit: listenEdit,
      getParts: getParts,
      getColors: getColors,
      onTap: onTap,
      splashShape: splashShape,
    );
  }

  @override
  SvgPicEditorState createState() => SvgPicEditorState();
}

class SvgPicEditorState extends State<SvgPicEditor> {
  String? modifiedSvgString;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _modifySvg();
    _loadSvgParts();
  }

  @override
  void didUpdateWidget(covariant SvgPicEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modifications != widget.modifications) {
      _modifySvg();
    }
  }

  Future<void> _loadSvgParts() async {
    if (widget.getParts == null) return;

    final svgMapperParts = SvgMapperParts();
    try {
      List<SvgElement> parts = [];
      if (widget.assetName != null) {
        parts = await svgMapperParts.loadAsset(
          assetPath: widget.assetName!,
          partNames: [],
        );
      } else if (widget.svgString != null) {
        parts = await svgMapperParts.loadString(
          svgContent: widget.svgString!,
          partNames: [],
        );
      } else if (widget.svgUrl != null) {
        parts = await svgMapperParts.loadNetwork(
          url: widget.svgUrl!,
          partNames: [],
        );
      }
      widget.getParts!(parts);
    } catch (e) {
      debugPrint('Erro ao carregar partes do SVG: $e');
    }
  }

  Future<void> _modifySvg() async {
    try {
      final modifySvg = ModifySvgUseCase(SvgRepositoryImpl());
      String svgContent = await _loadSvgContent();

      svgContent = _cleanSvg(svgContent);

      if (widget.getColors != null) {
        final colors = await modifySvg.getColors(svgContent);
        widget.getColors!(colors);
      }

      final modifiedSvg = await modifySvg(
        svgContent: svgContent,
        elements: widget.modifications ?? [],
      );

      setState(() {
        modifiedSvgString = modifiedSvg;
        hasError = false;
      });
    } catch (e) {
      debugPrint('Erro ao modificar SVG: $e');
      setState(() {
        modifiedSvgString = null;
        hasError = true;
      });
      if (widget.listenEdit != null) widget.listenEdit!("");
    }
  }

  Future<String> _loadSvgContent() async {
    final loadAsset = LoadSvgUseCase();
    final loadNetworkSvg = LoadNetworkSvgUseCase();

    if (widget.assetName != null) {
      return await loadAsset(widget.assetName!, widget.package);
    } else if (widget.svgString != null) {
      return widget.svgString!;
    } else if (widget.svgUrl != null) {
      return await loadNetworkSvg(widget.svgUrl!);
    } else {
      throw Exception('Nenhuma fonte SVG válida fornecida');
    }
  }

  String _cleanSvg(String svgContent) {
    try {
      final stylePattern = RegExp(r'<style[\s\S]*?</style>', multiLine: true);
      final scriptPattern =
          RegExp(r'<script[\s\S]*?</script>', multiLine: true);
      return svgContent
          .replaceAll(stylePattern, '')
          .replaceAll(scriptPattern, '');
    } catch (e) {
      debugPrint('Erro ao limpar SVG: $e');
      return svgContent;
    }
  }

  void _handleTap() {
    if (widget.onTap is void Function()) {
      (widget.onTap as void Function())();
    } else if (widget.onTap is void Function(String?)) {
      (widget.onTap as void Function(String?))(modifiedSvgString);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return const Center(
        child: Icon(Icons.error, color: Colors.red),
      );
    }

    if (modifiedSvgString != null) {
      if (widget.listenEdit != null) widget.listenEdit!(modifiedSvgString!);
      return GestureDetector(
        onTap: widget.onTap == null ? null : _handleTap,
        child: SvgPicture.string(
          modifiedSvgString!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          colorFilter: widget.color != null
              ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
              : null,
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
