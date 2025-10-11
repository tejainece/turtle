import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:turtle/src/app/app.dart';
import 'package:turtle/src/editor/editor.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';

class ConnectionWidget extends StatefulWidget {
  final Program program;
  final Connection connection;
  final ProgramViewport viewport;
  final Stream<PointerEvent> onPointer;

  const ConnectionWidget({
    required this.connection,
    required this.program,
    required this.viewport,
    required this.onPointer,
    super.key,
  });

  @override
  State<ConnectionWidget> createState() => _ConnectionWidgetState();
}

class _ConnectionWidgetState extends State<ConnectionWidget> with AfterInit {
  @override
  Widget build(BuildContext context) {
    if (start == null || end == null || path == null || color == null) {
      return Container();
    }
    return Positioned.fill(
      child: CustomPaint(
        painter: ConnectionPainter(
          start: start!,
          end: end!,
          path: path!,
          color: color!,
          isHovering: _hovering,
        ),
      ),
    );
  }

  void _onPointerEvent(PointerEvent event) {
    if (event is PointerHoverEvent) {
      if (path != null) {
        Offset position = event.localPosition;
        final metric = path!.computeMetrics().first;
        for (double i = 0; i < metric.length; i++) {
          final tangent = metric.getTangentForOffset(i.toDouble());
          if (tangent == null) continue;
          final distance = (tangent.position - position).distance;
          if (distance.abs() < ConnectionPainter.defaultStrokeWidth) {
            _setHovering(true);
            return;
          }
        }
      }
      _setHovering(false);
    }
  }

  void _setHovering(bool value) {
    if (_hovering == value) return;
    setState(() {
      _hovering = value;
    });
  }

  late final MyTheme theme;

  @override
  void afterInit() {
    theme = ThemeInjector.of(context);
    _update();
    final nodes = program.getConnectionNodes(
      connection.socketA,
      connection.socketB,
    )!;

    _subs.add(
      viewport.stream.listen((e) {
        _update();
      }),
    );
    _subs.add(nodes.$1.stream.listen((e) => _update()));
    _subs.add(nodes.$2.stream.listen((e) => _update()));

    _subs.add(widget.onPointer.listen(_onPointerEvent));
  }

  @override
  void dispose() {
    while (_subs.isNotEmpty) {
      _subs.removeLast().cancel();
    }
    super.dispose();
  }

  final List<StreamSubscription> _subs = [];

  bool _hovering = false;

  Path? path;
  Offset? start, end;
  Color? color;

  void _update() {
    final connectionData = program.getConnectionData(connection, theme);
    if (connectionData == null) {
      setState(() {
        path = null;
        start = null;
        end = null;
        color = null;
      });
      return;
    }

    color = connectionData.dataType.col;
    start = viewport.center + connectionData.socketAOffset;
    end = viewport.center + connectionData.socketBOffset;
    path = Path();

    path!.moveTo(start!.dx, start!.dy);
    path!.lineTo(end!.dx, end!.dy);
    setState(() {});
  }

  ProgramViewport get viewport => widget.viewport;

  Program get program => widget.program;

  Connection get connection => widget.connection;
}

class ConnectionDragWidget extends StatelessWidget {
  final Program program;
  final String socket;
  final Offset current;
  final ProgramViewport viewport;

  const ConnectionDragWidget({
    required this.program,
    required this.socket,
    required this.viewport,
    required this.current,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeInjector.of(context);
    final start = viewport.center + program.getConnectionOffset(socket, theme)!;
    final end = current;

    final Path path = Path();
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    return Positioned.fill(
      child: CustomPaint(
        painter: ConnectionPainter(
          start: start,
          end: end,
          path: path,
          color: program.getSocketDataType(socket)!.col,
          isHovering: false,
        ),
      ),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final Path path;
  final bool isHovering;

  ConnectionPainter({
    required this.start,
    required this.end,
    required this.color,
    required this.path,
    required this.isHovering,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = defaultStrokeWidth;
    Color strokeColor = color;
    double glowSize = 2;
    if (isHovering) {
      strokeWidth = 2;
      glowSize = 4;
      strokeColor = strokeColor.lighter(20);
    }

    final Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true
        ..imageFilter = ImageFilter.blur(sigmaX: glowSize, sigmaY: glowSize)
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true
        ..imageFilter = ImageFilter.blur(sigmaX: 1, sigmaY: 1)
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(path, paint);

    canvas.drawCircle(
      start,
      5,
      Paint()
        ..color = color
        ..isAntiAlias = true
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      end,
      5,
      Paint()
        ..color = color
        ..isAntiAlias = true
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! ConnectionPainter) return false;
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.color != color ||
        oldDelegate.path != path ||
        oldDelegate.isHovering != isHovering;
  }

  static /* const */ double defaultStrokeWidth = 2.0;
}

mixin AfterInit {
  bool _onlyOnce = false;

  void didChangeDependencies() {
    triggerAfterInit();
  }

  void triggerAfterInit() {
    if (_onlyOnce) return;

    afterInit();
    _onlyOnce = true;
  }

  void afterInit();
}
