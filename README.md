# SvgPicEditor

**SvgPicEditor** is a Flutter widget that enables loading and modifying SVG files from multiple sources, such as local assets, SVG strings, or URLs. This widget allows specific SVG elements to be modified using the `ElementSvg` class, making it easy to change properties like color, opacity, transformations, and more.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
    - [Import](#import)
    - [Basic Example](#basic-example)
    - [Constructors](#constructors)
        - [SvgPicEditor.asset](#svgpiceditorasset)
        - [SvgPicEditor.network](#svgpiceditornetwork)
        - [SvgPicEditor.string](#svgpiceditorstring)
    - [Widget Properties](#widget-properties)
    - [Modification Example](#modification-example)
- [Conclusion](#conclusion)

## Installation

To add **SvgPicEditor** to your Flutter project, include the following in your `pubspec.yaml`:

```yaml
dependencies:
  svg_pic_editor: ^1.0.0
```

Or run the command:

```bash
flutter pub add svg_pic_editor
```

## Usage

### Import

To use **SvgPicEditor**, import the package in your Dart file:

```dart
import 'package:svg_pic_editor/svg_pic_editor.dart';
```

### Basic Example

Below is a basic example of how to use **SvgPicEditor** inside a Flutter widget:

```dart
import 'package:flutter/material.dart';
import 'package:svg_pic_editor/svg_pic_editor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('SvgPicEditor Example')),
        body: Center(
          child: SvgPicEditor.asset(
            'assets/example.svg',
            modifications: [
              ElementSvg(
                querySelector: '#element1',
                fillColor: Colors.red,
              ),
            ],
            width: 200.0,
            height: 200.0,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
```

This example loads an SVG file from a local asset and changes the color of an SVG element with the ID `element1` to red.

### Constructors

**SvgPicEditor** has three main constructors for different SVG sources:

#### SvgPicEditor.asset

Loads an SVG from a local asset:

```dart
SvgPicEditor.asset(
  'assets/your_file.svg',
  package: 'your_package',
  modifications: [/* List of ElementSvg */],
  width: 100.0,
  height: 100.0,
  fit: BoxFit.contain,
  querySelector: '#yourID',
  color: Colors.red,
);
```

#### SvgPicEditor.network

Loads an SVG from a URL:

```dart
SvgPicEditor.network(
  'https://example.com/your/svg.svg',
  modifications: [/* List of ElementSvg */],
  width: 100.0,
  height: 100.0,
  fit: BoxFit.contain,
  querySelector: '.yourClass',
  color: Colors.red,
);
```

#### SvgPicEditor.string

Loads an SVG from an SVG string:

```dart
SvgPicEditor.string(
  '<svg>...</svg>',
  modifications: [/* List of ElementSvg */],
  width: 100.0,
  height: 100.0,
  fit: BoxFit.contain,
  querySelector: '[attribute="value"]',
  color: Colors.red,
);
```

### Widget Properties

Key properties of the **SvgPicEditor** widget:

- **assetName** (`String?`): The asset name containing the SVG.
- **svgString** (`String?`): A string representing the SVG content.
- **svgUrl** (`String?`): The URL of the SVG to be loaded.
- **package** (`String?`): The package name containing the asset.
- **modifications** (`List<ElementSvg>?`): List of modifications to be applied to the SVG.
- **width** (`double?`): Width of the widget.
- **height** (`double?`): Height of the widget.
- **fit** (`BoxFit`): How the SVG should fit within the available space.
- **querySelector** (`String?`): A query selector to target specific elements.
- **color** (`Color?`): Color to apply to the SVG.

### Modification Example

The `ElementSvg` class allows specific modifications to SVG elements, such as color, opacity, and transformations.

```dart
class ElementSvg {
  final String? id;
  final Color? fillColor;
  final Color? strokeColor;
  final double? strokeWidth;
  final double? opacity;
  final String? transform;
  final String? querySelector;
  final String? cssInjector;

  ElementSvg({
    this.id,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth,
    this.opacity,
    this.transform,
    this.querySelector,
    this.cssInjector,
  });
}
```

### Modification Examples Using querySelector

#### Selecting Specific Elements with `querySelector`

```dart
SvgPicEditor.asset(
  'assets/example.svg',
  modifications: [
    ElementSvg(
      querySelector: '#element1',
      fillColor: Colors.red,
    ),
    ElementSvg(
      querySelector: '.class1',
      strokeColor: Colors.blue,
      strokeWidth: 3.0,
    ),
  ],
  width: 200.0,
  height: 200.0,
  fit: BoxFit.contain,
);
```

#### Modifying Elements with Specific Attributes Using `querySelector`

```dart
SvgPicEditor.network(
  'https://example.com/your/svg.svg',
  modifications: [
    ElementSvg(
      querySelector: '[data-type="special"]',
      fillColor: Colors.green,
    ),
    ElementSvg(
      querySelector: '[stroke="black"]',
      strokeColor: Colors.yellow,
    ),
  ],
  width: 300.0,
  height: 300.0,
  fit: BoxFit.cover,
);
```

### Animation Examples with SvgPicEditor

Below is an example of how to use custom animations for `SvgPicEditor`:

```dart
SvgPicEditor.asset(
  'assets/example.svg',
  modifications: [
    ElementSvg(
      querySelector: 'rect#rectangle',
      fillColor: Colors.orange,
    ),
  ],
).shake(
  vsync: this,
  duration: Duration(milliseconds: 500),
  offset: 10.0,
  isInfinite: true,
);
```

In this example, the selected element is animated with a shake effect, creating a horizontal oscillation movement.