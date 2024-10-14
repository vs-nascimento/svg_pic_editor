
---
# SvgPicEditor

**SvgPicEditor** is a Flutter widget that allows you to load and modify SVG files from various sources, such as

local assets, SVG strings, or URLs. It provides the ability to make specific modifications to the SVG elements using the `ElementSvg` class, which facilitates changing properties such as color, opacity, transformation, and more.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
    - [Importing](#importing)
    - [Simple Example](#simple-example)
    - [Constructors](#constructors)
        - [SvgPicEditor.asset](#svgpiceditorasset)
        - [SvgPicEditor.network](#svgpiceditornetwork)
        - [SvgPicEditor.string](#svgpiceditorstring)
    - [Properties](#svgpiceditor-properties)
    - [Modification Example](#modification-example)
- [Conclusion](#conclusion)

## Installation

To add **SvgPicEditor** to your Flutter project, include the following code in your `pubspec.yaml`:

```yaml
dependencies:
  svg_pic_editor: ^1.0.0
```

Or use the command:

```bash
flutter pub add svg_pic_editor
```

## Usage

### Importing

To use **SvgPicEditor**, import the package in the Dart file where you want to use it:

```dart
import 'package:svg_pic_editor/svg_pic_editor.dart';
```

### Simple Example

Here’s a basic example of using **SvgPicEditor** inside a Flutter widget:

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
                id: 'element1',
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
  querySelector: 'yourSelector',
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
  querySelector: 'yourSelector',
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
  querySelector: 'yourSelector',
  color: Colors.red,
);
```

### Properties of SvgPicEditor Widget

Here are the main properties of the **SvgPicEditor** widget:

- **assetName** (`String?`): The name of the asset containing the SVG.
- **svgString** (`String?`): A string representing the SVG content.
- **svgUrl** (`String?`): The URL of the SVG to load.
- **package** (`String?`): The name of the package containing the asset.
- **modifications** (`List<ElementSvg>?`): A list of modifications to be applied to the SVG.
- **width** (`double?`): The width of the widget.
- **height** (`double?`): The height of the widget.
- **fit** (`BoxFit`): How the SVG should fit in the available space.
- **querySelector** (`String?`): A query selector to choose specific elements.
- **color** (`Color?`): Color to be applied to the SVG.

### Modification Example

The `ElementSvg` class allows you to perform specific modifications to SVG elements, such as color, opacity, and transformation.

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

### Example Usage with Modifications

Here’s an example that uses **SvgPicEditor** with several modifications applied to different SVG elements:

```dart
SvgPicEditor.asset(
  'assets/example.svg',
  modifications: [
    ElementSvg(
      id: 'rect1',
      fillColor: Colors.blue,
      strokeColor: Colors.black,
      strokeWidth: 2.0,
    ),
    ElementSvg(
      id: 'circle1',
      fillColor: Colors.green,
      opacity: 0.5,
    ),
  ],
  width: 200.0,
  height: 200.0,
  fit: BoxFit.contain,
);
```

In this example, the element `rect1` will have its fill color changed to blue, with a black stroke and a width of 2.0, while the element `circle1` will be filled green with 50% opacity.

## Conclusion

**SvgPicEditor** is a powerful and flexible tool for working with SVGs in Flutter. It allows you to easily customize the style and properties of SVG elements, providing support for local assets, SVG strings, and URLs.

Here are more usage examples of **SvgPicEditor**, demonstrating how to use the `querySelector` property to select and modify SVG elements with greater flexibility:

### Example 1: Using `querySelector` to Select Specific Elements

```dart
SvgPicEditor.asset(
  'assets/example.svg',
  modifications: [
    ElementSvg(
      querySelector: '#element1',  // Selects the element with ID 'element1'
      fillColor: Colors.red,
    ),
    ElementSvg(
      querySelector: '.class1',  // Selects all elements with class 'class1'
      strokeColor: Colors.blue,
      strokeWidth: 3.0,
    ),
  ],
  width: 200.0,
  height: 200.0,
  fit: BoxFit.contain,
);
```

### Example 2: Modifying Elements with Multiple Attributes Using `querySelector`

```dart
SvgPicEditor.network(
  'https://example.com/your/svg.svg',
  modifications: [
    ElementSvg(
      querySelector: '[data-type="special"]',  // Selects elements by 'data-type' attribute
      fillColor: Colors.green,
    ),
    ElementSvg(
      querySelector: '[stroke="black"]',  // Selects elements with black stroke
      strokeColor: Colors.yellow,
    ),
  ],
  width: 300.0,
  height: 300.0,
  fit: BoxFit.cover,
);
```

### Example 3: Applying Modifications to Elements with Combined Selectors

```dart
SvgPicEditor.string(
  '<svg>...</svg>',
  modifications: [
    ElementSvg(
      querySelector: 'rect#rectangle1',  // Selects a rectangle with ID 'rectangle1'
      fillColor: Colors.orange,
    ),
    ElementSvg(
      querySelector: 'circle.class2',  // Selects a circle with class 'class2'
      strokeColor: Colors.purple,
      strokeWidth: 4.0,
    ),
    ElementSvg(
      querySelector: 'path',  // Selects all 'path' elements
      opacity: 0.7,
    ),
  ],
  width: 250.0,
  height: 250.0,
  fit: BoxFit.contain,
);
```
These examples demonstrate the flexibility of **SvgPicEditor** and its ability to dynamically and interactively modify SVGs.

---