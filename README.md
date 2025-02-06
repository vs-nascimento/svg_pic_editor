
## SvgPicEditor

SvgPicEditor is a Flutter widget that allows you to load and modify SVG files from various sources, such as local assets, SVG strings, or URLs. This widget also lets you modify specific SVG elements using the ElementEdit class, making it easy to change properties like color, opacity, transformations, and more. The new `listenEdit` and `getColors` features further expand the possibilities for manipulating and customizing SVGs.

### Table of Contents
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
  - [New Feature Example](#new-feature-example)
- [Conclusion](#conclusion)

---

### Installation
To add SvgPicEditor to your Flutter project, include the following in your pubspec.yaml:

```yaml
dependencies:
  svg_pic_editor: ^3.0.0
```

Or run the command:

```bash
flutter pub add svg_pic_editor
```

---

### Usage

#### Import
To use SvgPicEditor, import the package into your Dart file:

```dart
import 'package:svg_pic_editor/svg_pic_editor.dart';
```

#### Basic Example
Here is a basic example of how to use SvgPicEditor inside a Flutter widget:

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
              ElementEdit(
                querySelector: '#element1',
                fillColor: Colors.red,
              ),
            ],
            width: 200.0,
            height: 200.0,
            fit: BoxFit.contain,
            listenEdit: (svgContent) {
              print('Edited SVG content: $svgContent');
            },
            onTap: (modifiedSvgString) {
              print('Tapped SVG: $modifiedSvgString');
            },
          ),
        ),
      ),
    );
  }
}
```

This example loads an SVG file from a local asset, modifies it, and adds the `onTap` callback to handle tap actions, printing either the modified SVG string or no value at all.

---

### Constructors

#### SvgPicEditor.asset
Loads an SVG from a local asset:

```dart
SvgPicEditor.asset(
  'assets/your_file.svg',
  modifications: [/* List of ElementEdit */],
  width: 100.0,
  height: 100.0,
  fit: BoxFit.contain,
  querySelector: '#yourID',
  color: Colors.red,
  listenEdit: (svgContent) => print('Updated SVG: $svgContent'),
  onTap: (modifiedSvgString) => print('Tapped SVG: $modifiedSvgString'),
);
```

#### SvgPicEditor.network
Loads an SVG from a URL:

```dart
SvgPicEditor.network(
  'https://example.com/your/svg.svg',
  modifications: [/* List of ElementEdit */],
  width: 100.0,
  height: 100.0,
  fit: BoxFit.contain,
  querySelector: '.yourClass',
  color: Colors.red,
  listenEdit: (svgContent) => print('SVG content: $svgContent'),
  onTap: (modifiedSvgString) => print('Tapped SVG: $modifiedSvgString'),
);
```

#### SvgPicEditor.string
Loads an SVG from an SVG string:

```dart
SvgPicEditor.string(
  '<svg>...</svg>',
  modifications: [/* List of ElementEdit */],
  width: 100.0,
  height: 100.0,
  fit: BoxFit.contain,
  querySelector: '[attribute="value"]',
  color: Colors.red,
  listenEdit: (svgContent) => print('Updated SVG: $svgContent'),
  onTap: (modifiedSvgString) => print('Tapped SVG: $modifiedSvgString'),
);
```

---

### Widget Properties
Main properties of the SvgPicEditor widget:

- **assetName (String?)**: The name of the asset containing the SVG.
- **svgString (String?)**: A string representing the SVG content.
- **svgUrl (String?)**: The URL of the SVG to be loaded.
- **listenEdit (Function(String)?)**: A callback function to listen for changes in the SVG content.
- **package (String?)**: The package name containing the asset.
- **modifications (List<ElementEdit>?)**: A list of modifications to apply to the SVG.
- **width (double?)**: The width of the widget.
- **height (double?)**: The height of the widget.
- **fit (BoxFit)**: How the SVG should fit within the available space.
- **querySelector (String?)**: A query selector to select specific elements.
- **color (Color?)**: The color to apply to the SVG.
- **onTap (Function(String)?)**: A callback function triggered when the SVG is tapped, receiving either the modified SVG string or no value at all.

---

### Modification Example
The ElementEdit class allows you to make specific modifications to SVG elements, such as changing the color, opacity, or applying transformations.

```dart
class ElementEdit {
  final String? id;
  final Color? fillColor;
  final Color? strokeColor;
  final double? strokeWidth;
  final double? opacity;
  final String? transform;
  final String? querySelector;

  ElementEdit({
    this.id,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth,
    this.opacity,
    this.transform,
    this.querySelector,
  });
}
```

---

### New Feature Example

#### Using listenEdit to Track Changes
The `listenEdit` feature allows you to listen for edits made to the SVG content and get updates about the modified SVG.

```dart
SvgPicEditor.asset(
  'assets/example.svg',
  modifications: [
    ElementEdit(
      querySelector: '#element1',
      fillColor: Colors.red,
    ),
  ],
  width: 200.0,
  height: 200.0,
  fit: BoxFit.contain,
  listenEdit: (svgContent) {
    // Whenever the SVG is edited, the updated content will be printed
    print('Edited SVG content: $svgContent');
  },
);
```

#### Using getColors to Retrieve Colors from the SVG
The `getColors` feature allows you to extract color information from an SVG. It returns an `SvgColorElement` containing the color and the elements associated with it in the SVG.

```dart
SvgPicEditor.asset(
  'assets/example.svg',
  modifications: [
    ElementEdit(
      querySelector: '#element1',
      fillColor: Colors.red,
    ),
  ],
  width: 200.0,
  height: 200.0,
  fit: BoxFit.contain,
  getColor: (List<SvgColorElement> colors) {
    // Retrieve the colors and associated elements from the SVG
    colors.forEach((colorElement) {
      print('Color: ${colorElement.color}');
      colorElement.parts.forEach((part) { // List of associated elements
        print('Element: ${part.querySelector}');
      });
    });
  },
);
```

---

### Conclusion
With the new `listenEdit`, `getColors`, and `onTap` features, SvgPicEditor becomes an even more powerful and flexible tool for manipulating and customizing SVGs in Flutter. Now, in addition to modifying SVG elements, you can track real-time edits, extract valuable information about the colors and elements within the SVG, and trigger actions when the SVG is tapped.

---

## Support the Project

If you would like to support the development of this project, you can make a contribution through PayPal. Your support helps keep the development active and adds new features.

### Contribute via Inter Pix

You can make your donation by scanning the QR code below:

![QR Code](https://seu-dominio.com/qrcode.png)

We truly appreciate your support!


### Version 3.2.0

#### Improvements
- Refined the `onTap` functionality, now supporting both void and modified SVG string returns for better flexibility.
- Enhanced error handling in the `SvgPicEditor` widget, ensuring smoother user experience when errors occur.
- Updated the `modifiedSvgString` update logic to improve the reactivity and ensure faster rendering.

#### New Features
- Introduced the `onTap` callback function, allowing users to trigger actions when the SVG is tapped, either with the modified SVG string or without any return value.
- Added shimmer effect loading for a smoother experience when the SVG is being processed.

#### Fixes
- Corrected a potential issue with the SVG string processing, improving the integrity of the final modified output.
- Minor optimizations in the way SVG parts are loaded for performance improvements.
```

