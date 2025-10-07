import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;

export 'draw_rectangle.dart';
export 'load_image.dart';

abstract class Node<O, I> {
  Future<O> process(I input);
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
