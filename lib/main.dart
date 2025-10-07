import 'package:flutter/material.dart';
import 'package:turtle/src/node.dart';

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

  Future<void> _process() async {
    final loaded = await LoadImageNode().process(LoadImageInput(path: 'sprites/penguin_funny_blue_water.jpg'));
    /*setState(() {
      image = loaded.image;
    });*/
    DrawRectangleInput input = DrawRectangleInput(
      surface: loaded.image,
      x: 0,
      y: 0,
      width: 50,
      height: 50,
      color: 'black',
    );
    DrawRectangleNode node = DrawRectangleNode();
    final output = await node.process(input);
    setState(() {
      image = output.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Wrap(
          children: <Widget>[
            if (image != null) RawImage(image: image!.image, scale: 1),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _process,
        tooltip: 'Process',
        child: const Icon(Icons.add),
      ),
    );
  }
}
