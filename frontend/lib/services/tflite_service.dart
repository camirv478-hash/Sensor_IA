import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';

class TFLiteService {
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  Interpreter? _interpreter;
  // List<String> _labels = [];
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
      // _labels = _categorias;
      _isLoaded = true;
      return true;
    } catch (e) {
      print('Error cargando modelo TFLite: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> classify(XFile image) async {
    if (!_isLoaded) {
      final loaded = await loadModel();
      if (!loaded) return null;
    }

    try {
      // Preprocesamiento pendiente
       await File(image.path).readAsBytes();
      // Aquí iría el preprocesamiento de la imagen (224x224, normalizar)
      // Por ahora devolvemos clasificación simulada
      return _classifySimulated(image.path);
    } catch (e) {
      print('Error clasificando: $e');
      return null;
    }
  }

  // Clasificación simulada (mientras se integra el preprocesamiento real)
  Map<String, dynamic> _classifySimulated(String path) {
    final random = DateTime.now().millisecondsSinceEpoch % _categorias.length;
    final categoria = _categorias[random];
    final info = _infoCategorias[categoria]!;
    
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