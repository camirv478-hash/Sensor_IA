"""
Clasificador de residuos con dos modos:
- Modo offline: TensorFlow local (SOLO 12 clases)
- Modo online: Gemini Vision (requiere API key)
"""
import os
import json
import numpy as np
from PIL import Image, ImageOps, ImageFilter
from django.conf import settings

# Intentar importar TensorFlow
try:
    import tensorflow as tf
    TF_AVAILABLE = True
except ImportError:
    TF_AVAILABLE = False
    print("⚠️ TensorFlow no instalado. Modo offline no disponible.")

# Intentar importar Google Gemini
try:
    from google import genai
    from google.genai import types
    GENAI_AVAILABLE = True
except ImportError:
    GENAI_AVAILABLE = False
    print("⚠️ Google GenAI no instalado. Modo online no disponible.")


class WasteClassifier:
    """
    Clasificador con modos online (Gemini) y offline (TensorFlow 12 clases).
    """

    # Mapeo para modelo de 12 clases (garbage_classification)
    # Mapeo oficial corregido para el modelo de 12 clases (orden alfabético del dataset)
    CATEGORIAS = {
        0: {'nombre': 'carton', 'display': 'Cartón', 'puntos_base': 12, 'caneca': 'Azul', 'color': '#2E86C1'},
        1: {'nombre': 'vidrio', 'display': 'Vidrio', 'puntos_base': 25, 'caneca': 'Verde', 'color': '#28B463'},
        2: {'nombre': 'metal', 'display': 'Metal', 'puntos_base': 20, 'caneca': 'Gris', 'color': '#95A5A6'},
        3: {'nombre': 'papel', 'display': 'Papel', 'puntos_base': 10, 'caneca': 'Azul', 'color': '#2E86C1'},
        4: {'nombre': 'plastico', 'display': 'Plástico', 'puntos_base': 15, 'caneca': 'Blanca', 'color': '#FDFEFE'},
        5: {'nombre': 'baja_confianza', 'display': 'Basura general', 'puntos_base': 5, 'caneca': 'Gris', 'color': '#95A5A6'}, # Tradicionalmente 'trash'
        6: {'nombre': 'baja_confianza', 'display': 'Baterías / Pilas', 'puntos_base': 0, 'caneca': 'Roja', 'color': '#E74C3C'}, # 'battery'
        7: {'nombre': 'electronico', 'display': 'Electrónico', 'puntos_base': 30, 'caneca': 'Roja', 'color': '#E74C3C'}, # 'biological' u 'e-waste' según variante
        8: {'nombre': 'plastico', 'display': 'Plástico (Botellas)', 'puntos_base': 15, 'caneca': 'Blanca', 'color': '#FDFEFE'}, # 'brown-glass' o variantes de botellas
        9: {'nombre': 'vidrio', 'display': 'Vidrio (Verde)', 'puntos_base': 25, 'caneca': 'Verde', 'color': '#28B463'},
        10: {'nombre': 'textil', 'display': 'Textil / Ropa', 'puntos_base': 8, 'caneca': 'Gris', 'color': '#95A5A6'}, # 'clothes'
        11: {'nombre': 'organico', 'display': 'Orgánico / Comida', 'puntos_base': 5, 'caneca': 'Marrón', 'color': '#A67B5B'}, # 'organic-waste'
    }

    def __init__(self):
        self.model = None
        self.gemini_client = None
        self._cargar_modelo_tf()
        self._inicializar_gemini()

    def _cargar_modelo_tf(self):
        """Carga el modelo TensorFlow de 12 clases (producción)."""
        modelo_12_path = os.path.join(settings.BASE_DIR, 'ml_models', 'waste_model_12classes.h5')

        if TF_AVAILABLE and os.path.exists(modelo_12_path):
            try:
                self.model = tf.keras.models.load_model(modelo_12_path)
                # ✅ Impresión de output_shape para verificar que tiene 12 salidas
                print("✅ Modelo TensorFlow de 12 clases cargado correctamente")
                print(f"   OUTPUT SHAPE: {self.model.output_shape}")  # Debe ser (None, 12)
                return
            except Exception as e:
                print(f"❌ Error cargando modelo de 12 clases: {e}")

        self.model = None
        print("⚠️ Modelo de 12 clases no disponible. Modo offline desactivado.")

    def _inicializar_gemini(self):
        """Inicializa el cliente Gemini para modo online."""
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key or not GENAI_AVAILABLE:
            print("⚠️ Gemini no disponible (falta API key o librería). Modo online no disponible.")
            return
        try:
            self.gemini_client = genai.Client(api_key=api_key)
            print("✅ Gemini Vision disponible para modo online")
        except Exception as e:
            print(f"❌ Error inicializando Gemini: {e}")

    # ================= MODO OFFLINE =================
    def clasificar_offline(self, imagen_path, umbral_confianza=60):
        """
        Clasifica usando solo TensorFlow local (12 clases).
        Si confianza < umbral, devuelve 'baja_confianza'.
        """
        if not self.model:
            return {
                "error": "Modelo offline no disponible",
                "categoria": "error",
                "categoria_display": "Error",
                "confianza": 0,
                "metodo": "offline_error"
            }
        try:
            # Preprocesamiento
            img = Image.open(imagen_path).convert('RGB')
            w, h = img.size
            min_dim = min(w, h)
            left = (w - min_dim) // 2
            top = (h - min_dim) // 2
            img = img.crop((left, top, left + min_dim, top + min_dim))
            try:
                resample = Image.Resampling.LANCZOS
            except AttributeError:
                resample = Image.LANCZOS
            img = img.resize((224, 224), resample)
            try:
                img = ImageOps.autocontrast(img, cutoff=1)
                img = img.filter(ImageFilter.SHARPEN)
            except:
                pass
            img_array = np.array(img) / 255.0
            img_array = np.expand_dims(img_array, axis=0)

            predicciones = self.model.predict(img_array, verbose=0)
            idx = int(np.argmax(predicciones[0]))
            confianza = float(predicciones[0][idx] * 100)

            if confianza < umbral_confianza:
                return {
                    "categoria": "baja_confianza",
                    "categoria_display": "No se pudo identificar con suficiente certeza",
                    "confianza": confianza,
                    "puntos_base": 0,
                    "caneca": "No determinada",
                    "color_caneca": "#888888",
                    "metodo": "offline_baja_confianza",
                    "descripcion": f"Confianza demasiado baja ({confianza:.1f}%). Intenta con mejor iluminación o ángulo."
                }

            # ✅ Solo usamos el mapeo de 12 clases (ya no hay CATEGORIAS_6)
            categoria_info = self.CATEGORIAS.get(idx, self.CATEGORIAS[0])

            return {
                "categoria": categoria_info['nombre'],
                "categoria_display": categoria_info['display'],
                "confianza": confianza,
                "puntos_base": categoria_info['puntos_base'],
                "caneca": categoria_info['caneca'],
                "color_caneca": categoria_info['color'],
                "metodo": "offline_tensorflow",
                "descripcion": f"Clasificado localmente con {confianza:.1f}% de confianza."
            }
        except Exception as e:
            print(f"❌ Error en modo offline: {e}")
            return {
                "error": str(e),
                "categoria": "error_tecnico",
                "categoria_display": "Error técnico",
                "confianza": 0,
                "metodo": "offline_exception"
            }

    # ================= MODO ONLINE =================
    def clasificar_online(self, imagen_path, usar_respaldo_tf=True):
        """
        Clasifica usando Gemini Vision (envía la imagen directamente).
        Si Gemini falla o se acaba la cuota, usa TensorFlow local.
        """
        if not self.gemini_client:
            if usar_respaldo_tf:
                print("ℹ️ Gemini no disponible. Usando fallback offline.")
                return self.clasificar_offline(imagen_path)
            else:
                return {
                    "error": "Gemini no disponible y respaldo desactivado",
                    "categoria": "error",
                    "categoria_display": "Error de conectividad",
                    "metodo": "online_error"
                }

        try:
            # Abrimos la imagen con PIL para enviarla directamente al SDK
            raw_image = Image.open(imagen_path)

            prompt_text = """
Eres el motor de IA de SensorIA, un asistente experto en reciclaje de alta precisión.
Analiza la imagen minuciosamente y clasifica el residuo principal en UNA de estas categorías:
plastico, papel, carton, vidrio, metal, organico, electronico, textil.

REGLAS CRÍTICAS DE CLASIFICACIÓN (Evita errores comunes):
1. CUADERNOS, HOJAS Y LIBROS: Aunque tengan espirales plásticos o portadas brillantes, su componente principal es PAPEL o CARTÓN. Clasifícalos estrictamente como 'papel' o 'carton'.
2. REFLEJOS DE LUZ: No confundas el brillo físico de la luz sobre un objeto con material plástico. Asegúrate de distinguir la textura real.
3. BOTELLAS Y ENVASES: Solo clasifica como 'plastico' si es un contenedor, bolsa o polímero evidente.

Si la imagen NO contiene un residuo reciclable (personas, animales, paisajes), responde con categoria: "ninguno".

Devuelve SOLO un JSON válido sin bloques de código markdown:
{
  "categoria": "nombre_categoria",
  "confianza": 95,
  "descripcion": "breve razón analítica en máximo 12 palabras"
}
"""

            response = self.gemini_client.models.generate_content(
                model="gemini-2.5-flash",
                contents=[raw_image, prompt_text]
            )

            texto = response.text.strip()
            # Limpieza segura de bloques markdown
            if "```json" in texto:
                texto = texto.split("```json")[1].split("```")[0].strip()
            else:
                texto = texto.replace("```", "").strip()

            data = json.loads(texto)
            categoria = data.get("categoria", "").lower()

            if categoria == "ninguno":
                return {
                    "categoria": "no_residuo",
                    "categoria_display": "No es un residuo",
                    "confianza": float(data.get("confianza", 90)),
                    "puntos_base": 0,
                    "caneca": "No aplica",
                    "color_caneca": "#888888",
                    "metodo": "online_gemini_no_residuo",
                    "descripcion": data.get("descripcion", "La imagen no contiene un residuo reciclable.")
                }

            # Buscar la categoría en el mapeo de 12
            cat_info = None
            for c in self.CATEGORIAS.values():
                if c['nombre'] == categoria:
                    cat_info = c
                    break

            if not cat_info:
                if usar_respaldo_tf:
                    print(f"⚠️ Categoría no mapeada: '{categoria}'. Usando fallback offline.")
                    return self.clasificar_offline(imagen_path)
                else:
                    return {
                        "categoria": "desconocido",
                        "categoria_display": "Categoría no reconocida por Gemini",
                        "confianza": 0,
                        "metodo": "online_gemini_unknown"
                    }

            return {
                "categoria": cat_info['nombre'],
                "categoria_display": cat_info['display'],
                "confianza": float(data.get("confianza", 85)),
                "puntos_base": cat_info['puntos_base'],
                "caneca": cat_info['caneca'],
                "color_caneca": cat_info['color'],
                "metodo": "online_gemini",
                "descripcion": data.get("descripcion", "Clasificado con IA avanzada.")
            }

        except Exception as e:
            error_msg = str(e)
            if "quota" in error_msg.lower() or "429" in error_msg or "exhausted" in error_msg.lower():
                print("⚠️ [CUOTA EXCEDIDA O LÍMITE DE BUFFER] Conmutando a análisis local inmediatamente.")
            else:
                print(f"❌ Error en modo online con Gemini: {e}")

            if usar_respaldo_tf:
                return self.clasificar_offline(imagen_path)
            else:
                return {
                    "error": error_msg,
                    "categoria": "error_tecnico",
                    "categoria_display": "Error en análisis online",
                    "metodo": "online_exception"
                }

    # ================= MÉTODO GENÉRICO UNIFICADO =================
    def clasificar(self, imagen_path, modo="auto", umbral_confianza=60):
        """
        Método unificado que decide qué modo usar.
        - 'auto' u 'online': Usa Gemini Vision primero; si falla o no hay cuota, usa TF local.
        - 'offline': Fuerza el uso inmediato de TensorFlow local.
        """
        if modo == "online" or modo == "auto":
            return self.clasificar_online(imagen_path, usar_respaldo_tf=True)
        elif modo == "offline":
            return self.clasificar_offline(imagen_path, umbral_confianza)
        else:
            return self.clasificar_offline(imagen_path, umbral_confianza)


# Instancia global única
classifier = WasteClassifier()