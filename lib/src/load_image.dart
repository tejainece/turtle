import 'dart:io';

import 'package:flutter/material.dart';
import 'package:turtle/src/node.dart';

class LoadImageInput {
  final String path;

  LoadImageInput({required this.path});
}

class LoadImageOutput {
  final Surface image;

  LoadImageOutput({required this.image});
}

class LoadImageNode implements Node<LoadImageOutput, LoadImageInput> {
  @override
  Future<LoadImageOutput> process(LoadImageInput input) async  {
    final bytes = await File(input.path).readAsBytes();
    final image = await decodeImageFromList(bytes);
    return LoadImageOutput(image: Surface(image: image, offset: Offset.zero));
  }
}