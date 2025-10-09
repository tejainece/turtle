import 'dart:io';

import 'package:flutter/material.dart';
import 'package:turtle/src/processor/processor.dart';

class LoadImageInput implements ProcessorInput {
  final List<String> paths;

  LoadImageInput({required this.paths});

  factory LoadImageInput.fromArgs(List args) {
    return LoadImageInput(paths: args[0]);
  }

  @override
  List<ProcessorSocket> get sockets => mySockets;

  static const List<ProcessorSocket> mySockets = [
    ProcessorSocket(
      label: 'Paths',
      dataType: DataType.string,
      id: 'paths',
      isInput: true,
    ),
  ];
}

class LoadImageOutput implements ProcessorOutput {
  final List<Surface> surfaces;

  LoadImageOutput({required this.surfaces});

  @override
  late final List<dynamic> asArgs = [surfaces];

  @override
  List<Surface> get preview => surfaces;

  @override
  List<ProcessorSocket> get sockets => mySockets;

  static const List<ProcessorSocket> mySockets = [
    ProcessorSocket(
      label: 'Surfaces',
      dataType: DataType.surface,
      id: 'surfaces',
      isInput: false,
    ),
  ];
}

class LoadImageNode implements Processor<LoadImageOutput, LoadImageInput> {
  @override
  Future<LoadImageOutput> process(LoadImageInput input) async {
    final surfaces = <Surface>[];
    for (final path in input.paths) {
      final bytes = await File(path).readAsBytes();
      final image = await decodeImageFromList(bytes);
      surfaces.add(Surface(image: image, offset: Offset.zero));
    }
    return LoadImageOutput(surfaces: surfaces);
  }

  @override
  LoadImageInput makeInput(List<dynamic> args) => LoadImageInput.fromArgs(args);

  @override
  late final String label = 'Load image';

  @override
  List<ProcessorSocket> get inputSockets => LoadImageInput.mySockets;

  @override
  List<ProcessorSocket> get outputSockets => LoadImageOutput.mySockets;
}
