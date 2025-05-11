import 'package:flutter/material.dart';

class EsquinasCamara extends StatelessWidget {
  final double x;
  final double y;
  final double width;
  final double height;

  const EsquinasCamara({
    super.key,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: width,
        height: height,
        
        child: CustomPaint(
          painter: EsquinasPainter(),
        ),
      ),
    );
  }
}

class EsquinasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    const radius = 10.0;

    // Esquinas (4)
    final path = Path();
    // Esquina superior izquierda
    path.moveTo(0, radius + cornerLength);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(radius + cornerLength, 0);

    // Esquina superior derecha
    path.moveTo(size.width - radius - cornerLength, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, radius + cornerLength);

    // Esquina inferior derecha
    path.moveTo(size.width, size.height - radius - cornerLength);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
    path.lineTo(size.width - radius - cornerLength, size.height);

    // Esquina inferior izquierda
    path.moveTo(radius + cornerLength, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, size.height - radius - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
