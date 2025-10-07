import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:turtle/src/node.dart';

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
    return await Surface.blank(ui.Rect.fromLTWH(x, y, width, height));
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
    final canvas = ui.Canvas(recorder, inputSurface.rect);

    if (input.surface != null) {
      canvas.drawImage(input.surface!.image, input.surface!.offset, ui.Paint());
    }
    canvas.drawRect(
      ui.Rect.fromLTWH(input.x, input.y, input.width, input.height),
      ui.Paint()..color = Colors.black,
    );

    final out = await recorder.endRecording().toImage(
      inputSurface.image.width,
      inputSurface.image.height,
    );
    return DrawRectangleOutput(
      image: Surface(image: out, offset: inputSurface.offset),
    );
  }
}
