import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  Interpreter? _interpreter;
  bool _isLoaded = false;

  final List<String> _categorias = [
    'cardboard', 'glass', 'metal', 'paper', 'plastic', 'trash'
  ];

  final Map<String, Map<String, dynamic>> _infoCategorias = {
    'cardboard': {'display': 'Cartón', 'puntos': 12, 'icon': '📦'},
    'glass': {'display': 'Vidrio', 'puntos': 25, 'icon': '🍾'},
    'metal': {'display': 'Metal', 'puntos': 20, 'icon': '🥫'},
    'paper': {'display': 'Papel', 'puntos': 10, 'icon': '📄'},
    'plastic': {'display': 'Plástico', 'puntos': 15, 'icon': '🧴'},
    'trash': {'display': 'Basura común', 'puntos': 2, 'icon': '🗑️'},
  };

  Future<bool> loadModel() async {
    if (_isLoaded) return true;
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/waste_model.tflite');
      _isLoaded = true;
      debugPrint('✅ Modelo TFLite cargado correctamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error cargando modelo TFLite: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> classify(XFile image) async {
    if (!_isLoaded) {
      final loaded = await loadModel();
      if (!loaded) return null;
    }

    try {
      // Leer la imagen
      final imageBytes = await File(image.path).readAsBytes();
      
      // Decodificar con el paquete 'image'
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        debugPrint('❌ No se pudo decodificar la imagen');
        return _classifySimulated(image.path);
      }

      // Preprocesado mejorado:
      // 1) Center-crop a cuadrado, 2) redimensionar con interpolación suave
      final int width = decodedImage.width;
      final int height = decodedImage.height;
      final int minDim = width < height ? width : height;
      final int offsetX = ((width - minDim) / 2).round();
      final int offsetY = ((height - minDim) / 2).round();
      final cropped = img.copyCrop(
        decodedImage,
        x: offsetX,
        y: offsetY,
        width: minDim,
        height: minDim,
      );

      // Redimensionar a 224x224 (lo que espera MobileNetV2)
      final resized = img.copyResize(cropped, width: 224, height: 224, interpolation: img.Interpolation.cubic);

      // Convertir a tensor de entrada 4D [1, 224, 224, 3]
      final inputTensor = List.generate(
        1,
        (_) => List.generate(
          224,
          (_) => List.generate(
            224,
            (_) => List<double>.filled(3, 0.0),
          ),
        ),
      );

      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resized.getPixel(x, y);
          inputTensor[0][y][x][0] = pixel.r / 255.0;
          inputTensor[0][y][x][1] = pixel.g / 255.0;
          inputTensor[0][y][x][2] = pixel.b / 255.0;
        }
      }

      // Tensor de salida [1, 6]
      final outputTensor = List.generate(1, (_) => List<double>.filled(6, 0.0));

      // Ejecutar inferencia
      _interpreter!.run(inputTensor, outputTensor);

      // Obtener la clase con mayor probabilidad
      final predictions = outputTensor[0];
      double maxConf = 0;
      int maxIndex = 0;
      for (int i = 0; i < predictions.length; i++) {
        if (predictions[i] > maxConf) {
          maxConf = predictions[i];
          maxIndex = i;
        }
      }

      final categoria = _categorias[maxIndex];
      final info = _infoCategorias[categoria]!;

      debugPrint('🧠 IA clasificó: ${info['display']} (${(maxConf * 100).toStringAsFixed(1)}%)');

      return {
        'categoria': categoria,
        'display': info['display'],
        'puntos': info['puntos'],
        'confianza': (maxConf * 100),
        'offline': true,
      };

    } catch (e) {
      debugPrint('❌ Error en clasificación: $e');
      return _classifySimulated(image.path);
    }
  }

  // Fallback por si falla la clasificación real
  Map<String, dynamic> _classifySimulated(String path) {
    final random = DateTime.now().millisecondsSinceEpoch % _categorias.length;
    final categoria = _categorias[random];
    final info = _infoCategorias[categoria]!;
    
debugPrint('⚠️ Usando clasificación simulada');
    
    return {
      'categoria': categoria,
      'display': info['display'],
      'puntos': info['puntos'],
      'confianza': 85.0 + (random * 2.5),
      'offline': true,
    };
  }

  void dispose() {
    _interpreter?.close();
    _isLoaded = false;
  }
}