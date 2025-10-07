import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;

import 'package:flutter/material.dart';

abstract class Node<O, I> {
  Future<O> process(I input);
}

class DrawRectangleInput {
  final Surface? surface;
  final double x;
  final double y;
  final double width;
  final double height;
  final String color;
  // TODO fill properties
  // TODO stroke properties

  DrawRectangleInput({
    required this.surface,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
  });

  Future<Surface> makeSurface() async {
    if (surface != null) return surface!;
    return await Surface.blank(Rect.fromLTWH(x, y, width, height));
  }
}

class DrawRectangleOutput {
  final Surface image;

  DrawRectangleOutput({required this.image});
}

class DrawRectangleNode
    implements Node<DrawRectangleOutput, DrawRectangleInput> {
  @override
  Future<DrawRectangleOutput> process(DrawRectangleInput input) async {
    final recorder = ui.PictureRecorder();
    final inputSurface = await input.makeSurface();
    final canvas = Canvas(recorder, inputSurface.rect);

    if (input.surface != null) {
      canvas.drawImage(input.surface!.image, input.surface!.offset, Paint());
    }
    canvas.drawRect(Rect.fromLTWH(input.x, input.y, input.width, input.height), Paint()..color = Colors.black);

    final out = await recorder.endRecording().toImage(input.width.ceil(), input.height.ceil());
    return DrawRectangleOutput(image: Surface(image: out, offset: inputSurface.offset));
  }
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
