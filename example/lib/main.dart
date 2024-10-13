import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:svg_pic_editor/svg_pic_editor.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SvgMapperParts mapperParts;
  final List<SvgElement> parts = [];
  final ValueNotifier<Color> color = ValueNotifier<Color>(Colors.red);
  final ValueNotifier<String?> selectedPart = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    mapperParts = SvgMapperParts();
    _getSvgMapperParts();
  }

  _getSvgMapperParts() async {
    List<SvgElement> assets =
    await mapperParts.loadAsset(assetPath: 'assets/test.svg', partNames: []);
    parts.addAll(assets);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Picture Edit'),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<String?>(
            valueListenable: selectedPart,
            builder: (context, value, child) {
              return Expanded(
                flex: 3,
                child: Center(
                  child: SvgPicEditor.asset(
                    assetName: 'assets/test.svg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    modifications: [
                      ElementSvg(
                        querySelector: 'cor=#68A240',
                        fillColor: Colors.red ,
                      ),

                    ],
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}
