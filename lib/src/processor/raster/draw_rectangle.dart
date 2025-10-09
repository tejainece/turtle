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
      x: (args[1] as num).toDouble(),
      y: (args[2] as num).toDouble(),
      width: (args[3] as num).toDouble(),
      height: (args[4] as num).toDouble(),
      color: args[5],
    );
  }

  @override
  late final List<ProcessorSocket> sockets = sockets;

  static final List<ProcessorSocket> mySockets = [
    ProcessorSocket(
      label: 'Surfaces',
      dataType: DataType.surface,
      id: 'surfaces',
      isInput: true,
    ),
    ProcessorSocket(
      label: 'Left',
      dataType: DataType.number,
      id: 'x',
      isInput: true,
    ),
    ProcessorSocket(
      label: 'Top',
      dataType: DataType.number,
      id: 'y',
      isInput: true,
    ),
    ProcessorSocket(
      label: 'Width',
      dataType: DataType.number,
      id: 'width',
      isInput: true,
    ),
    ProcessorSocket(
      label: 'Height',
      dataType: DataType.number,
      id: 'height',
      isInput: true,
    ),
    ProcessorSocket(
      label: 'Color',
      dataType: DataType.color,
      id: 'color',
      isInput: true,
    ),
  ];
}

class DrawRectangleOutput implements ProcessorOutput {
  final List<Surface> surfaces;

  DrawRectangleOutput({required this.surfaces});

  @override
  List get asArgs => [surfaces];

  @override
  late final List<ProcessorSocket> sockets = mySockets;

  @override
  List<Surface> get preview => surfaces;

  dynamic valueBySocketId(String socketId) {
    if (socketId == 'surfaces') return surfaces;
    throw Exception('Socket $socketId not found');
  }

  static final List<ProcessorSocket> mySockets = [
    ProcessorSocket(
      label: 'Surfaces',
      dataType: DataType.surface,
      id: 'surfaces',
      isInput: false,
    ),
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
  List<ProcessorSocket> get inputSockets => DrawRectangleInput.mySockets;

  @override
  List<ProcessorSocket> get outputSockets => DrawRectangleOutput.mySockets;
}
