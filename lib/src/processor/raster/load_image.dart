import 'dart:io';

import 'package:flutter/material.dart';
import 'package:turtle/src/processor/processor.dart';

class LoadImageInput implements InProcessSocket {
  final List<String> paths;

  LoadImageInput({required this.paths});

  factory LoadImageInput.fromArgs(List args) {
    return LoadImageInput(paths: args[0]);
  }
}

class LoadImageOutput implements OutProcessSocket {
  final List<Surface> surfaces;

  LoadImageOutput({required this.surfaces});

  @override
  late final List<dynamic> asArgs = [surfaces];
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
  late final String name = 'LoadImage';
}
