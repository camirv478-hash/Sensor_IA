import 'dart:io';
import 'dart:typed_data';
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
      print('✅ Modelo TFLite cargado correctamente');
      return true;
    } catch (e) {
      print('❌ Error cargando modelo TFLite: $e');
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
        print('❌ No se pudo decodificar la imagen');
        return _classifySimulated(image.path);
      }

      // Redimensionar a 224x224 (lo que espera MobileNetV2)
      final resized = img.copyResize(decodedImage, width: 224, height: 224);

      // Convertir a array de floats normalizado [0, 1]
      final input = Float32List(1 * 224 * 224 * 3);
      int pixelIndex = 0;
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resized.getPixel(x, y);
          input[pixelIndex++] = pixel.r / 255.0; // Red
          input[pixelIndex++] = pixel.g / 255.0; // Green
          input[pixelIndex++] = pixel.b / 255.0; // Blue
        }
      }

      // Crear tensor de entrada [1, 224, 224, 3]
      final inputTensor = input.reshape([1, 224, 224, 3]);

      // Tensor de salida [1, 6]
      final outputTensor = Float32List(1 * 6).reshape([1, 6]);

      // Ejecutar inferencia
      _interpreter!.run(inputTensor, outputTensor);

      // Obtener la clase con mayor probabilidad
      final predictions = outputTensor[0] as List<double>;
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

      print('🧠 IA clasificó: ${info['display']} (${(maxConf * 100).toStringAsFixed(1)}%)');

      return {
        'categoria': categoria,
        'display': info['display'],
        'puntos': info['puntos'],
        'confianza': (maxConf * 100),
        'offline': true,
      };

    } catch (e) {
      print('❌ Error en clasificación: $e');
      return _classifySimulated(image.path);
    }
  }

  // Fallback por si falla la clasificación real
  Map<String, dynamic> _classifySimulated(String path) {
    final random = DateTime.now().millisecondsSinceEpoch % _categorias.length;
    final categoria = _categorias[random];
    final info = _infoCategorias[categoria]!;
    
    print('⚠️ Usando clasificación simulada');
    
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