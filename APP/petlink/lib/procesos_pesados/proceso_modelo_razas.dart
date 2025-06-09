import 'dart:io';
import 'dart:math';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

@pragma('vm:entry-point')
void procesoRazas(List<dynamic> args) async {
  SendPort sendPort = args[0];
  Interpreter modeloRazas = args[1];
  String imagePath = args[2];

  try {
    final imageBytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(imageBytes);
    if (original == null) throw Exception("❌ Imagen no válida");

    final inputSize = 224;

    // 1. Redimensionar manteniendo proporción
    final scale = inputSize / max(original.width, original.height);
    final newWidth = (original.width * scale).round();
    final newHeight = (original.height * scale).round();
    final resized = img.copyResize(original, width: newWidth, height: newHeight);

    // 2. Calcular padding (relleno) para centrar la imagen en un cuadrado
    final dx = ((inputSize - newWidth) / 2).round();
    final dy = ((inputSize - newHeight) / 2).round();

    // 3. Crear imagen cuadrada (letterboxed) y rellenar de negro
    final square = img.Image(width: inputSize, height: inputSize);
    for (int y = 0; y < square.height; y++) {
      for (int x = 0; x < square.width; x++) {
        square.setPixel(x, y, img.ColorRgb8(0, 0, 0)); // negro RGB
      }
    }

    // 4. Insertar imagen redimensionada centrada dentro del cuadrado
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        square.setPixel(x + dx, y + dy, pixel);
      }
    }

    // 5. Preparar input [1, 224, 224, 3] normalizado
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = square.getPixelSafe(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0
            ];
          },
        ),
      ),
    );

    // 6. Salida esperada: [1, num_clases]
    final output = List.generate(1, (_) => List.filled(172, 0.0)); // Cambia 172 si hay más clases

    modeloRazas.run(input, output);

    final predictions = output[0];
    final maxProb = predictions.reduce(max);
    final classIndex = predictions.indexOf(maxProb);

    print("✅ Raza detectada: Clase $classIndex con probabilidad $maxProb");

    sendPort.send({
      'classIndex': classIndex,
      'confidence': maxProb,
    });

  } catch (e) {
    // ❌ Error en procesoRazas: $e
    sendPort.send("ERROR");
  }
}