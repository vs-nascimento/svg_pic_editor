# SvgPicEditor

**SvgPicEditor** é um widget Flutter que permite carregar e modificar arquivos SVG provenientes de diferentes fontes, como assets locais, strings SVG ou URLs. Ele oferece a possibilidade de realizar modificações específicas nos elementos SVG utilizando a classe `ElementSvg`, que facilita a alteração de propriedades como cor, opacidade, transformação e mais.

## Índice

- [Instalação](#instalação)
- [Uso](#uso)
    - [Importação](#importação)
    - [Exemplo Simples](#exemplo-simples)
    - [Construtores](#construtores)
        - [SvgPicEditor.asset](#svgpiceditorasset)
        - [SvgPicEditor.network](#svgpiceditornetwork)
        - [SvgPicEditor.string](#svgpiceditorstring)
    - [Propriedades](#propriedades-do-widget-svgpiceditor)
    - [Exemplo de Modificações](#exemplo-de-modificações)
- [Conclusão](#conclusão)

## Instalação

Para adicionar o **SvgPicEditor** ao seu projeto Flutter, adicione o seguinte código ao seu `pubspec.yaml`:

```yaml
dependencies:
  svg_pic_editor: ^1.0.0
```

Ou utilize o comando:

```bash
flutter pub add svg_pic_editor
```

## Uso

### Importação

Para utilizar o **SvgPicEditor**, importe o pacote no arquivo Dart onde deseja usá-lo:

```dart
import 'package:svg_pic_editor/svg_pic_editor.dart';
```

### Exemplo Simples

Aqui está um exemplo básico de uso do **SvgPicEditor** dentro de um widget Flutter:

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
            assetName: 'assets/exemplo.svg',
            modifications: [
              ElementSvg(
                id: 'elemento1',
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

Este exemplo carrega um arquivo SVG de um asset local e altera a cor de um elemento SVG com o ID `elemento1` para vermelho.

### Construtores

O **SvgPicEditor** possui três construtores principais para diferentes fontes de SVG:

#### SvgPicEditor.asset

Carrega um SVG de um asset local:

```dart
SvgPicEditor.asset(
  assetName: 'assets/seu_arquivo.svg',
  package: 'seu_pacote',
  modifications: [/* Lista de ElementSvg */],
  width: 100.0,
  height: 100.0,
  fit: BoxFit.contain,
  querySelector: 'seuSelector',
  color: Colors.red,
);
```

#### SvgPicEditor.network

Carrega um SVG a partir de uma URL:

```dart
SvgPicEditor.network(
  svgUrl: 'https://exemplo.com/seu/svg.svg',
  modifications: [/* Lista de ElementSvg */],
  width: 100.0,
  height: 100.0,
  fit: BoxFit.contain,
  querySelector: 'seuSelector',
  color: Colors.red,
);
```

#### SvgPicEditor.string

Carrega um SVG a partir de uma string SVG:

```dart
SvgPicEditor.string(
  svgString: '<svg>...</svg>',
  modifications: [/* Lista de ElementSvg */],
  width: 100.0,
  height: 100.0,
  fit: BoxFit.contain,
  querySelector: 'seuSelector',
  color: Colors.red,
);
```

### Propriedades do Widget SvgPicEditor

Aqui estão as principais propriedades do widget **SvgPicEditor**:

- **assetName** (`String?`): O nome do asset contendo o SVG.
- **svgString** (`String?`): String representando o conteúdo SVG.
- **svgUrl** (`String?`): URL do SVG a ser carregado.
- **package** (`String?`): Nome do pacote que contém o asset.
- **modifications** (`List<ElementSvg>?`): Lista de modificações a serem aplicadas ao SVG.
- **width** (`double?`): Largura do widget.
- **height** (`double?`): Altura do widget.
- **fit** (`BoxFit`): Como o SVG deve se ajustar ao espaço disponível.
- **querySelector** (`String?`): Selecionador de query para escolher elementos específicos.
- **color** (`Color?`): Cor a ser aplicada ao SVG.

### Exemplo de Modificações

A classe `ElementSvg` permite realizar modificações específicas nos elementos SVG, como cor, opacidade e transformação.

```dart
class ElementSvg {
  final String? id;
  final Color? fillColor;
  final Color? strokeColor;
  final String? targetColor;
  final String? targetStrokeColor;
  final double? strokeWidth;
  final double? opacity;
  final String? transform;
  final String? querySelector;
  final String? cssInjector;

  ElementSvg({
    this.id,
    this.fillColor,
    this.strokeColor,
    this.targetColor,
    this.targetStrokeColor,
    this.strokeWidth,
    this.opacity,
    this.transform,
    this.querySelector,
    this.cssInjector,
  });
}
```

### Exemplo de Uso com Modificações

Aqui está um exemplo que usa o **SvgPicEditor** com várias modificações aplicadas a diferentes elementos SVG:

```dart
SvgPicEditor.asset(
  assetName: 'assets/exemplo.svg',
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

Neste exemplo, o elemento `rect1` terá o preenchimento alterado para azul, com contorno preto e espessura de 2.0, enquanto o elemento `circle1` será preenchido de verde com 50% de opacidade.

## Conclusão

O **SvgPicEditor** é uma ferramenta poderosa e flexível para trabalhar com SVGs em Flutter. Ele permite que você personalize facilmente o estilo e as propriedades dos elementos SVG, oferecendo suporte para assets locais, strings SVG e URLs.

Aqui estão mais exemplos de uso do **SvgPicEditor**, demonstrando como utilizar a propriedade `querySelector` para selecionar e modificar elementos SVG com maior flexibilidade:

### Exemplo 1: Usando `querySelector` para Selecionar Elementos Específicos

```dart
SvgPicEditor.asset(
  assetName: 'assets/exemplo.svg',
  modifications: [
    ElementSvg(
      querySelector: '#elemento1',  // Seleciona o elemento com o ID 'elemento1'
      fillColor: Colors.red,
    ),
    ElementSvg(
      querySelector: '.classe1',  // Seleciona todos os elementos com a classe 'classe1'
      strokeColor: Colors.blue,
      strokeWidth: 3.0,
    ),
  ],
  width: 200.0,
  height: 200.0,
  fit: BoxFit.contain,
);
```

### Exemplo 2: Modificando Elementos com Vários Atributos Usando `querySelector`

```dart
SvgPicEditor.network(
  svgUrl: 'https://exemplo.com/seu/svg.svg',
  modifications: [
    ElementSvg(
      querySelector: '[data-tipo="especial"]',  // Seleciona elementos pelo atributo 'data-tipo'
      fillColor: Colors.green,
    ),
    ElementSvg(
      querySelector: '[stroke="black"]',  // Seleciona elementos com contorno preto
      strokeColor: Colors.yellow,
    ),
  ],
  width: 300.0,
  height: 300.0,
  fit: BoxFit.cover,
);
```

### Exemplo 3: Aplicando Modificações a Elementos com Vários Seletivos Combinados

```dart
SvgPicEditor.string(
  svgString: '<svg>...</svg>',
  modifications: [
    ElementSvg(
      querySelector: 'rect#retangulo1',  // Seleciona um retângulo com o ID 'retangulo1'
      fillColor: Colors.orange,
    ),
    ElementSvg(
      querySelector: 'circle.classe2',  // Seleciona um círculo com a classe 'classe2'
      strokeColor: Colors.purple,
      strokeWidth: 4.0,
    ),
    ElementSvg(
      querySelector: 'path',  // Seleciona todos os elementos 'path'
      opacity: 0.7,
    ),
  ],
  width: 250.0,
  height: 250.0,
  fit: BoxFit.contain,
);
```
Esses exemplos demonstram a flexibilidade do **SvgPicEditor** e sua capacidade de modificar SVGs de forma dinâmica e interativa.
