import 'package:flutter/material.dart';
import 'package:turtle/src/app/app.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';
import 'package:turtle/src/processor/processor.dart';

class PropertiesEditor extends StatefulWidget {
  final Program program;
  final Set<Node> nodes;

  const PropertiesEditor({
    required this.program,
    required this.nodes,
    super.key,
  });

  @override
  State<PropertiesEditor> createState() => _PropertiesEditorState();
}

class _PropertiesEditorState extends State<PropertiesEditor> {
  @override
  Widget build(BuildContext context) {
    final theme = ThemeInjector.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.panelBackground,
        border: theme.panelBorder,
        borderRadius: theme.panelBorderRadius,
      ),
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.headerBackground,
              borderRadius: theme.headerBorderRadius,
            ),
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
            child: Text('Properties', style: theme.headerTitleStyle),
          ),
          // make it two directional scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final node in nodes)
                    // TODO set key
                    NodePropertyEditor(program: program, node: node),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Program get program => widget.program;

  Set<Node> get nodes => widget.nodes;
}

class NodePropertyEditor extends StatelessWidget {
  final Program program;
  final Node node;

  const NodePropertyEditor({
    required this.program,
    required this.node,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final socket in node.inputSockets)
          // TODO set key
          PropertyEditor(program: program, node: node, socket: socket),
      ],
    );
  }
}

class PropertyEditor extends StatefulWidget {
  final Program program;
  final Node node;
  final ProcessorSocket socket;

  const PropertyEditor({
    required this.program,
    required this.node,
    required this.socket,
    super.key,
  });

  @override
  State<PropertyEditor> createState() => _PropertyEditorState();
}

class _PropertyEditorState extends State<PropertyEditor> {
  @override
  Widget build(BuildContext context) {
    if (socket.dataType == DataType.boolean) {
      return Container(
        child: Checkbox(
          value: node.getProperty(socket.id),
          onChanged: (value) {
            node.setProperty(socket.id, value);
          },
        ),
      );
    } else if (socket.dataType == DataType.number) {
      return Container(
        child: TextField(
          keyboardType: TextInputType.number,
          controller: _controller,
          decoration: InputDecoration(labelText: socket.label),
          onChanged: (value) {
            node.setProperty(socket.id, double.tryParse(value));
          },
        ),
      );
    }
    return Container();
  }

  void initState() {
    super.initState();
    _controller.text = node.getProperty(socket.id).toString();
  }

  final _controller = TextEditingController();

  Program get program => widget.program;
  Node get node => widget.node;
  ProcessorSocket get socket => widget.socket;
}
