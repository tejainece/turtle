import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:turtle/src/processor/processor.dart';

class DrawRectangleInput implements ProcessorInput {
  final List<Surface> surfaces;
  final double x;
  final double y;
  final double width;
  final double height;
  final Color color;
  // TODO fill properties
  // TODO stroke properties

  DrawRectangleInput({
    required this.surfaces,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
  });

  factory DrawRectangleInput.fromArgs(List args) {
    return DrawRectangleInput(
      surfaces: args[0],
      x: args[1],
      y: args[2],
      width: args[3],
      height: args[4],
      color: args[5],
    );
  }

  @override
  late final List<ProcessorSocket> sockets = sockets;

  static final List<ProcessorSocket> mySockets = [
    ProcessorSocket(label: 'Surfaces', type: DataType.surface, id: 'surfaces'),
    ProcessorSocket(label: 'Left', type: DataType.number, id: 'x'),
    ProcessorSocket(label: 'Top', type: DataType.number, id: 'y'),
    ProcessorSocket(label: 'Width', type: DataType.number, id: 'width'),
    ProcessorSocket(label: 'Height', type: DataType.number, id: 'height'),
    ProcessorSocket(label: 'Color', type: DataType.color, id: 'color'),
  ];
}

class DrawRectangleOutput implements ProcessorOutput {
  final List<Surface> surfaces;

  DrawRectangleOutput({required this.surfaces});

  @override
  List get asArgs => [surfaces];

  @override
  late final List<ProcessorSocket> sockets = mySockets;

  static final List<ProcessorSocket> mySockets = [
    ProcessorSocket(label: 'Surfaces', type: DataType.surface, id: 'surfaces'),
  ];
}

class DrawRectangleNode
    implements Processor<DrawRectangleOutput, DrawRectangleInput> {
  @override
  Future<DrawRectangleOutput> process(DrawRectangleInput input) async {
    final outSurfaces = <Surface>[];

    if (input.surfaces.isNotEmpty) {
      for (final inputSurface in input.surfaces) {
        outSurfaces.add(await _processOneSurface(input, inputSurface));
      }
    } else {
      outSurfaces.add(await _processOneSurface(input, null));
    }
    return DrawRectangleOutput(surfaces: outSurfaces);
  }

  Future<Surface> _processOneSurface(
    DrawRectangleInput input,
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
  DrawRectangleInput makeInput(List<dynamic> args) =>
      DrawRectangleInput.fromArgs(args);

  @override
  final String label = 'Draw rectangle';

  @override
  List<ProcessorSocket> get inputSocket => DrawRectangleInput.mySockets;

  @override
  List<ProcessorSocket> get outputSocket => DrawRectangleOutput.mySockets;
}
