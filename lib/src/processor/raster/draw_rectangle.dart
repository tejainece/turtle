import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:turtle/src/processor/processor.dart';

class RasteredRectangleInput implements InProcessSocket {
  final List<Surface> surfaces;
  final double x;
  final double y;
  final double width;
  final double height;
  final Color color;
  // TODO fill properties
  // TODO stroke properties

  RasteredRectangleInput({
    required this.surfaces,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
  });

  factory RasteredRectangleInput.fromArgs(List args) {
    return RasteredRectangleInput(
      surfaces: args[0],
      x: args[1],
      y: args[2],
      width: args[3],
      height: args[4],
      color: args[5],
    );
  }
}

class RasteredRectangleOutput implements OutProcessSocket {
  final List<Surface> surfaces;

  RasteredRectangleOutput({required this.surfaces});

  @override
  List get asArgs => [surfaces];
}

class RasteredRectangleNode
    implements Processor<RasteredRectangleOutput, RasteredRectangleInput> {
  @override
  Future<RasteredRectangleOutput> process(RasteredRectangleInput input) async {
    final outSurfaces = <Surface>[];

    if (input.surfaces.isNotEmpty) {
      for (final inputSurface in input.surfaces) {
        outSurfaces.add(await _processOneSurface(input, inputSurface));
      }
    } else {
      outSurfaces.add(await _processOneSurface(input, null));
    }
    return RasteredRectangleOutput(surfaces: outSurfaces);
  }

  Future<Surface> _processOneSurface(
    RasteredRectangleInput input,
    Surface? inputSurface,
  ) async {
    final recorder = ui.PictureRecorder();
    late final Canvas canvas;
    if (inputSurface == null) {
      canvas = ui.Canvas(
        recorder,
        Rect.fromLTWH(0, 0, input.width.toDouble(), input.height.toDouble()),
      );
    } else {
      canvas = ui.Canvas(recorder, inputSurface.rect);
    }

    if (inputSurface != null) {
      canvas.drawImage(
        inputSurface.image,
        Offset.zero,
        ui.Paint()..filterQuality = ui.FilterQuality.high,
      );
    }
    canvas.drawRect(
      ui.Rect.fromLTWH(input.x, input.y, input.width, input.height),
      ui.Paint()..color = input.color,
    );

    final outImage = await recorder.endRecording().toImage(
      inputSurface?.image.width ?? input.width.toInt(),
      inputSurface?.image.height ?? input.height.toInt(),
    );
    return Surface(
      image: outImage,
      offset: inputSurface?.offset ?? Offset.zero,
    );
  }

  @override
  RasteredRectangleInput makeInput(List<dynamic> args) =>
      RasteredRectangleInput.fromArgs(args);

  @override
  final String name = 'RasteredRectangle';
}
