import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:svg_pic_editor/svg_pic_editor.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Picture Edit'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: SvgPicEditor.asset(
                'assets/test.svg',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                modifications: [
                  ElementSvg(
                    querySelector: 'color=#68A240',
                    fillColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
