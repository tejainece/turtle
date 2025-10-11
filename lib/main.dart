import 'dart:io';

import 'package:flutter/material.dart';
import 'package:turtle/src/app/app.dart';
import 'package:turtle/src/app/theme.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';
import 'package:turtle/src/processor/processor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Surface? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemeInjector(
        theme: MyTheme.dark,
        child: App(
          program: Program(
            nodes: [
              Node(
                id: 'LoadImage1',
                offset: Offset(70, 170),
                size: Size(300, 300),
                processor: LoadImageNode(),
                properties: {
                  'paths': ['sprites/penguin_funny_blue_water.jpg'],
                },
              ),
              Node(
                id: 'Rectangle1',
                offset: Offset(490, 170),
                size: Size(300, 300),
                processor: DrawRectangleNode(),
                properties: {
                  'x': 0,
                  'y': 0,
                  'width': 50,
                  'height': 50,
                  'color': Colors.black,
                },
              ),
              Node(
                id: 'Rectangle2',
                offset: Offset(910, 170),
                size: Size(300, 300),
                processor: DrawRectangleNode(),
                properties: {
                  'x': 50,
                  'y': 50,
                  'width': 50,
                  'height': 50,
                  'color': Colors.red,
                },
              ),
            ],
            connections: [
              Connection(
                socketA: 'LoadImage1.output.surfaces',
                socketB: 'Rectangle1.input.surfaces',
                shape: [],
              ),
              Connection(
                socketA: 'Rectangle1.output.surfaces',
                socketB: 'Rectangle2.input.surfaces',
                shape: [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
