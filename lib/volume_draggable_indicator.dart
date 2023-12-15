import 'package:flutter/material.dart';

class VerticalLinearProgressPointer extends CustomPainter {
  final double volume;
  final Color color;
  VerticalLinearProgressPointer({required this.color, required this.volume});

  @override
  void paint(Canvas canvas, Size size) {
    Paint total = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.height;
    Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.height;

    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), total);

    canvas.drawLine(Offset(0, size.height),
        Offset(volume * size.width, size.height), progressPaint);

    canvas.drawCircle(Offset(volume * size.width, size.height),
        size.height * 0.65, progressPaint);
  }

  @override
  bool shouldRepaint(oldDelegate) {
    return true;
  }
}
