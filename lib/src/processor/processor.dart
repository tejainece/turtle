import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;

export 'raster/draw_rectangle.dart';
export 'raster/load_image.dart';

abstract class Processor<O extends ProcessorOutput, I extends ProcessorInput> {
  String get label;

  Future<O> process(I input);

  I makeInput(List args);

  List<ProcessorSocket> get inputSocket;
  List<ProcessorSocket> get outputSocket;
}

abstract class ProcessorOutput {
  List get asArgs;

  List<ProcessorSocket> get sockets;
}

abstract class ProcessorInput {
  List<ProcessorSocket> get sockets;
}

// TODO how to represent list
sealed class DataType {
  static const String number = 'number';
  static const String integer = 'integer';
  static const String string = 'string';
  static const String boolean = 'boolean';
  static const String surface = 'surface';
  static const String color = 'color';
}

class ProcessorSocket {
  final String id;
  final String label;
  final String type;

  const ProcessorSocket({
    required this.label,
    required this.type,
    required this.id,
  });
}

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
