import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:turtle/src/editor/editor.dart';
import 'package:turtle/src/model/model.dart';
import 'package:turtle/src/model/program.dart';

class ConnectionWidget extends StatelessWidget {
  final Program program;
  final Connection connection;
  final ProgramViewport viewport;

  const ConnectionWidget({
    required this.connection,
    required this.program,
    required this.viewport,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final start =
        viewport.center + program.getConnectionOffset(connection.socketA)!;
    final end =
        viewport.center + program.getConnectionOffset(connection.socketB)!;
    final Path path = Path();

    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    return Positioned.fill(
      child: CustomPaint(
        painter: ConnectionPainter(
          start: start,
          end: end,
          path: path,
          color: program.getConnectionDataType(connection.socketA)!.col,
        ),
      ),
    );
  }
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
    final start = viewport.center + program.getConnectionOffset(socket)!;
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
          color: program.getConnectionDataType(socket)!.col,
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

  ConnectionPainter({
    required this.start,
    required this.end,
    required this.color,
    required this.path,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 4.0
        ..isAntiAlias = true
        ..imageFilter = ImageFilter.blur(sigmaX: 3, sigmaY: 3)
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 4.0
        ..isAntiAlias = true
        ..imageFilter = ImageFilter.blur(sigmaX: 2, sigmaY: 2)
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
        oldDelegate.end != end &&
            oldDelegate.color != color &&
            oldDelegate.path != path;
  }
}
