import 'package:flutter/material.dart';
import 'package:turtle/src/processor/processor.dart';

Future<void> _process() async {
  final loaded = await LoadImageNode().process(
    LoadImageInput(paths: ['sprites/penguin_funny_blue_water.jpg']),
  );
  /*setState(() {
      image = loaded.image;
    });*/
  DrawRectangleInput input = DrawRectangleInput(
    surfaces: loaded.surfaces,
    x: 0,
    y: 0,
    width: 50,
    height: 50,
    color: Colors.black,
  );
  DrawRectangleNode node = DrawRectangleNode();
  final output = await node.process(input);
  /*setState(() {
    image = output.surfaces.first;
  });*/
}
