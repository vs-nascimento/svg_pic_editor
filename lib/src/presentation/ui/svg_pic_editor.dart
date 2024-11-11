import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../svg_pic_editor.dart';
import '../../usecases/load_network_svg_use_case.dart';
import '../../usecases/load_svg_use_case.dart';

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
    );
  }

  @override
  SvgPicEditorState createState() => SvgPicEditorState();
}

class SvgPicEditorState extends State<SvgPicEditor> {
  String? modifiedSvgString;
  bool hasError = false; // Variável para controle de erro

  @override
  void initState() {
    super.initState();
    _modifySvg();
    if (widget.getParts != null) {
      final svgMapperParts = SvgMapperParts();
      if (widget.assetName != null) {
        svgMapperParts.loadAsset(
          assetPath: widget.assetName!,
          partNames: [],
        ).then((value) => widget.getParts!(value));
      } else if (widget.svgString != null) {
        svgMapperParts.loadString(
          svgContent: widget.svgString!,
          partNames: [],
        ).then((value) => widget.getParts!(value));
      } else if (widget.svgUrl != null) {
        svgMapperParts.loadNetwork(
          url: widget.svgUrl!,
          partNames: [],
        ).then((value) => widget.getParts!(value));
      }
    }
  }

  @override
  void didUpdateWidget(covariant SvgPicEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modifications != widget.modifications) {
      _modifySvg();
    }
  }

  Future<void> _modifySvg() async {
    try {
      final modifySvg = ModifySvgUseCase(SvgRepositoryImpl());
      final loadAsset = LoadSvgUseCase();
      final loadNetworkSvg = LoadNetworkSvgUseCase();
      String svgContent = '';

      // Carrega o SVG com base na fonte (asset, string ou URL)
      if (widget.assetName != null) {
        svgContent = await loadAsset(widget.assetName!, widget.package);
      } else if (widget.svgString != null) {
        svgContent = widget.svgString!;
      } else if (widget.svgUrl != null) {
        svgContent = await loadNetworkSvg(widget.svgUrl!);
      } else {
        throw Exception('Nenhuma fonte SVG válida fornecida');
      }

      svgContent = _cleanSvg(svgContent);

      if (widget.getColors != null) {
        final colors = await modifySvg.getColors(svgContent);
        widget.getColors!(colors);
      }

      // Aplica as modificações no SVG
      final modifiedSvg = await modifySvg(
        svgContent: svgContent,
        elements: widget.modifications ?? [],
      );

      setState(() {
        modifiedSvgString = modifiedSvg;
        hasError = false; // Reinicia a variável de erro
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

  // Limpa conteúdo de estilo e script do SVG para evitar problemas de compatibilidade
  String _cleanSvg(String svgContent) {
    try {
      final stylePattern = RegExp(r'<style[\s\S]*?</style>', multiLine: true);
      svgContent = svgContent.replaceAll(stylePattern, '');

      final scriptPattern =
          RegExp(r'<script[\s\S]*?</script>', multiLine: true);
      svgContent = svgContent.replaceAll(scriptPattern, '');

      return svgContent;
    } catch (e) {
      debugPrint('Erro ao limpar SVG: $e');
      return svgContent;
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
      return SvgPicture.string(
        modifiedSvgString!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
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
