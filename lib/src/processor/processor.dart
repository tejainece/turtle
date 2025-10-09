import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:flutter/material.dart';

export 'raster/draw_rectangle.dart';
export 'raster/load_image.dart';

abstract class Processor<O extends ProcessorOutput, I extends ProcessorInput> {
  String get label;

  Future<O> process(I input);

  I makeInput(List args);

  List<ProcessorSocket> get inputSockets;
  List<ProcessorSocket> get outputSockets;
}

abstract class ProcessorOutput {
  List get asArgs;

  List<ProcessorSocket> get sockets;

  dynamic get preview;
}

abstract class ProcessorInput {
  List<ProcessorSocket> get sockets;
}

// TODO how to represent list
enum DataType {
  number(col: Colors.blue),
  integer(col: Colors.purple),
  string(col: Colors.cyan),
  boolean(col: Colors.green),
  surface(col: Colors.purple),
  color(col: Colors.orange);

  final Color col;
  const DataType({required this.col});
}

class ProcessorSocket {
  final String id;
  final String label;
  final DataType dataType;

  /// Input or output
  final bool isInput;
  const ProcessorSocket({
    required this.id,
    required this.label,
    required this.dataType,
    required this.isInput,
  });

  String get key => '${isInput ? 'input' : 'output'}.$id';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': label,
    'dataType': dataType.name,
    'isInput': isInput,
  };

  static ProcessorSocket fromJson(Map json) => ProcessorSocket(
    id: json['id'],
    label: json['name'],
    dataType: DataType.values.byName(json['dataType']),
    isInput: json['isInput'],
  );

  static List<ProcessorSocket> fromJsonList(List json) =>
      json.cast<Map>().map((e) => ProcessorSocket.fromJson(e)).toList();
}

/*class ProcessorSocket {
  final String id;
  final String label;
  final String type;

  const ProcessorSocket({
    required this.label,
    required this.type,
    required this.id,
  });
}*/

class Surface {
  final ui.Image image;
  final Offset offset;
  Surface({required this.image, required this.offset});
  static Future<Surface> blank(Rect rect) async {
    im.Image.empty();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      Uint8List(4 * rect.width.ceil() * rect.height.ceil()),
      rect.width.ceil(),
      rect.height.ceil(),
      ui.PixelFormat.rgba8888,
      (v) {
        completer.complete(v);
      },
    );
    ui.Image image = await completer.future;
    return Surface(image: image, offset: rect.topLeft);
  }

  Rect get rect => Rect.fromLTWH(
    offset.dx,
    offset.dy,
    image.width.toDouble(),
    image.height.toDouble(),
  );
}
