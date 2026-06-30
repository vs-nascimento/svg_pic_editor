import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import 'models/element_edit.dart';
import 'models/svg_color_element.dart';
import 'models/svg_element.dart';
import 'svg_editor_core.dart';

/// A Flutter widget that displays an SVG and allows dynamic in-memory modifications.
class SvgPicEditor extends StatefulWidget {
  /// The asset path of the SVG.
  final String? assetName;

  /// A raw SVG string to render.
  final String? svgString;

  /// The network URL of the SVG.
  final String? svgUrl;

  /// The package name containing the asset.
  final String? package;

  /// A list of modifications to apply to the SVG elements.
  final List<ElementEdit>? modifications;

  /// The width of the widget.
  final double? width;

  /// The height of the widget.
  final double? height;

  /// How the SVG should fit within the available space.
  final BoxFit fit;

  /// The color to apply to the SVG (using [ColorFilter.mode]).
  final Color? color;

  /// A callback triggered whenever the SVG is successfully edited.
  final ValueChanged<String>? listenEdit;

  /// A callback returning all parsed SVG elements.
  final ValueChanged<List<SvgElement>>? getParts;

  /// A callback returning all unique colors and their associated elements.
  final ValueChanged<List<SvgColorElement>>? getColors;

  /// A callback triggered when the SVG is tapped, returning the modified SVG string.
  final ValueChanged<String>? onTap;

  /// A custom widget to show while the SVG is loading.
  /// If null, a default pulsing placeholder will be shown.
  final WidgetBuilder? placeholderBuilder;

  const SvgPicEditor._({
    super.key,
    this.assetName,
    this.svgString,
    this.svgUrl,
    this.package,
    this.modifications,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.listenEdit,
    this.getParts,
    this.getColors,
    this.onTap,
    this.placeholderBuilder,
  });

  /// Loads an SVG from a local asset.
  static SvgPicEditor asset(
    String assetName, {
    Key? key,
    String? package,
    List<ElementEdit>? modifications,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    ValueChanged<String>? listenEdit,
    ValueChanged<List<SvgElement>>? getParts,
    ValueChanged<List<SvgColorElement>>? getColors,
    ValueChanged<String>? onTap,
    WidgetBuilder? placeholderBuilder,
  }) {
    return SvgPicEditor._(
      key: key,
      assetName: assetName,
      package: package,
      modifications: modifications,
      width: width,
      height: height,
      fit: fit,
      color: color,
      listenEdit: listenEdit,
      getParts: getParts,
      getColors: getColors,
      onTap: onTap,
      placeholderBuilder: placeholderBuilder,
    );
  }

  /// Loads an SVG from a network URL.
  static SvgPicEditor network(
    String svgUrl, {
    Key? key,
    List<ElementEdit>? modifications,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    ValueChanged<String>? listenEdit,
    ValueChanged<List<SvgElement>>? getParts,
    ValueChanged<List<SvgColorElement>>? getColors,
    ValueChanged<String>? onTap,
    WidgetBuilder? placeholderBuilder,
  }) {
    return SvgPicEditor._(
      key: key,
      svgUrl: svgUrl,
      modifications: modifications,
      width: width,
      height: height,
      fit: fit,
      color: color,
      listenEdit: listenEdit,
      getParts: getParts,
      getColors: getColors,
      onTap: onTap,
      placeholderBuilder: placeholderBuilder,
    );
  }

  /// Loads an SVG from a raw SVG string.
  static SvgPicEditor string(
    String svgString, {
    Key? key,
    List<ElementEdit>? modifications,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    ValueChanged<String>? listenEdit,
    ValueChanged<List<SvgElement>>? getParts,
    ValueChanged<List<SvgColorElement>>? getColors,
    ValueChanged<String>? onTap,
    WidgetBuilder? placeholderBuilder,
  }) {
    return SvgPicEditor._(
      key: key,
      svgString: svgString,
      modifications: modifications,
      width: width,
      height: height,
      fit: fit,
      color: color,
      listenEdit: listenEdit,
      getParts: getParts,
      getColors: getColors,
      onTap: onTap,
      placeholderBuilder: placeholderBuilder,
    );
  }

  @override
  State<SvgPicEditor> createState() => _SvgPicEditorState();
}

class _SvgPicEditorState extends State<SvgPicEditor> {
  String? _rawSvgContent;
  String? _modifiedSvgString;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRawSvg();
  }

  @override
  void didUpdateWidget(covariant SvgPicEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    final sourceChanged = oldWidget.assetName != widget.assetName ||
        oldWidget.svgString != widget.svgString ||
        oldWidget.svgUrl != widget.svgUrl ||
        oldWidget.package != widget.package;

    if (sourceChanged) {
      _loadRawSvg();
    } else if (oldWidget.modifications != widget.modifications) {
      _applyModificationsAndNotify();
    }
  }

  Future<void> _loadRawSvg() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      String content;
      if (widget.assetName != null) {
        content = await rootBundle.loadString(
          widget.package != null ? 'packages/${widget.package}/${widget.assetName}' : widget.assetName!,
        );
      } else if (widget.svgString != null) {
        content = widget.svgString!;
      } else if (widget.svgUrl != null) {
        final response = await http.get(Uri.parse(widget.svgUrl!));
        if (response.statusCode == 200) {
          content = response.body;
        } else {
          throw Exception('Failed to load SVG from network (Status: ${response.statusCode})');
        }
      } else {
        throw Exception('No valid SVG source provided');
      }

      _rawSvgContent = SvgEditorCore.cleanSvg(content);
      _applyModificationsAndNotify();
    } catch (e) {
      debugPrint('Error loading SVG: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      if (widget.listenEdit != null) {
        widget.listenEdit!('');
      }
    }
  }

  void _applyModificationsAndNotify() {
    if (_rawSvgContent == null) return;

    try {
      // Extract parts if needed
      if (widget.getParts != null) {
        final document = xml.XmlDocument.parse(_rawSvgContent!);
        final parts = SvgEditorCore.extractComponentPartsAsSvg(document: document);
        widget.getParts!(parts);
      }

      // Extract colors if needed
      if (widget.getColors != null) {
        final colors = SvgEditorCore.extractColorsAndElements(_rawSvgContent!);
        widget.getColors!(colors);
      }

      // Modify SVG in-memory
      final modified = SvgEditorCore.modifySvg(
        svgContent: _rawSvgContent!,
        modifications: widget.modifications ?? [],
      );

      if (mounted) {
        setState(() {
          _modifiedSvgString = modified;
          _isLoading = false;
          _hasError = false;
        });
      }

      if (widget.listenEdit != null) {
        widget.listenEdit!(modified);
      }
    } catch (e) {
      debugPrint('Error modifying SVG: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Icon(Icons.error_outline, color: Colors.red, size: 32),
      );
    }

    if (_isLoading) {
      if (widget.placeholderBuilder != null) {
        return widget.placeholderBuilder!(context);
      }
      return _DefaultLoadingPlaceholder(width: widget.width, height: widget.height);
    }

    if (_modifiedSvgString != null) {
      final svgPicture = SvgPicture.string(
        _modifiedSvgString!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
      );

      Widget result = svgPicture;

      if (widget.onTap != null) {
        result = GestureDetector(
          onTap: () => widget.onTap!(_modifiedSvgString!),
          child: svgPicture,
        );
      }

      return RepaintBoundary(
        child: result,
      );
    }

    return const SizedBox.shrink();
  }
}

class _DefaultLoadingPlaceholder extends StatefulWidget {
  final double? width;
  final double? height;

  const _DefaultLoadingPlaceholder({this.width, this.height});

  @override
  State<_DefaultLoadingPlaceholder> createState() => _DefaultLoadingPlaceholderState();
}

class _DefaultLoadingPlaceholderState extends State<_DefaultLoadingPlaceholder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_controller.value * 0.4),
          child: Container(
            width: widget.width ?? 100,
            height: widget.height ?? 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
