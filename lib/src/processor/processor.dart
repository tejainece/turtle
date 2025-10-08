import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;

export 'raster/draw_rectangle.dart';
export 'raster/load_image.dart';

abstract class Processor<
  O extends OutProcessSocket,
  I extends InProcessSocket
> {
  String get name;

  Future<O> process(I input);

  I makeInput(List args);
}

abstract class OutProcessSocket {
  List get asArgs;
}

abstract class InProcessSocket {}

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
