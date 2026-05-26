import 'package:http/http.dart' as http;

class Esp32Service {
  static String ipEsp32 = '192.168.137.1';

  static Future<bool> _enviarPeticion(String ruta) async {
    try {
      final url = Uri.parse('http://$ipEsp32$ruta');
      print('Enviando petición a: $url');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        print('ESP32 respondió: ${response.body}');
        return true;
      }
      return false;
    } catch (e) {
      print('No se pudo conectar al ESP32: $e');
      return false;
    }
  }

  static Future<bool> abrirSegunResiduo(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat.contains('organ') || cat.contains('verde')) {
      return abrirCanecaVerde();
    } else if (cat.contains('recicl') || cat.contains('azul')) {
      return abrirCanecaAzul();
    } else {
      return abrirCanecaGris();
    }
  }

  static Future<bool> abrirCanecaVerde() => _enviarPeticion('/verde');
  static Future<bool> abrirCanecaAzul() => _enviarPeticion('/azul');
  static Future<bool> abrirCanecaGris() => _enviarPeticion('/gris');

  static void cambiarIp(String nuevaIp) {
    ipEsp32 = nuevaIp;
    print('IP actualizada a: $ipEsp32');
  }
}
