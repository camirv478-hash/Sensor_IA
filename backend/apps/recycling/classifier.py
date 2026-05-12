"""
Clasificador de residuos con IA.
Usa un modelo preentrenado MobileNetV2 para clasificar imágenes.
"""
import os
import numpy as np
from PIL import Image
from django.conf import settings


class WasteClassifier:
    """
    Clasificador de residuos usando TensorFlow.
    En producción, carga un modelo entrenado con dataset de reciclaje.
    """
    
    CATEGORIAS = {
        0: {'nombre': 'carton', 'display': 'Cartón', 'puntos_base': 12},
        1: {'nombre': 'vidrio', 'display': 'Vidrio', 'puntos_base': 25},
        2: {'nombre': 'metal', 'display': 'Metal', 'puntos_base': 20},
        3: {'nombre': 'papel', 'display': 'Papel', 'puntos_base': 10},
        4: {'nombre': 'plastico', 'display': 'Plástico', 'puntos_base': 15},
        5: {'nombre': 'organico', 'display': 'Orgánico', 'puntos_base': 5},
        6: {'nombre': 'electronico', 'display': 'Electrónico', 'puntos_base': 30},
        7: {'nombre': 'textil', 'display': 'Textil', 'puntos_base': 8},
    }
    
    def __init__(self):
        self.model = None
        self._cargar_modelo()
    
    def _cargar_modelo(self):
        """Cargar el modelo de IA."""
        modelo_path = os.path.join(settings.BASE_DIR, 'ml_models', 'waste_model.h5')
        
        if os.path.exists(modelo_path):
            import tensorflow as tf
            self.model = tf.keras.models.load_model(modelo_path)
            print("✅ Modelo de IA cargado exitosamente")
        else:
            print("⚠️ Modelo no encontrado. Usando clasificador por simulacion.")
            self.model = None
    
    def clasificar(self, imagen_path):
        """
        Clasifica una imagen de residuo.
        
        Args:
            imagen_path: Ruta de la imagen a clasificar.
        
        Returns:
            dict: {
                'categoria': str,
                'categoria_display': str,
                'confianza': float (0-100),
                'puntos_base': int,
            }
        """
        if self.model:
            return self._clasificar_con_modelo(imagen_path)
        else:
            return self._clasificar_simulado(imagen_path)
    
    def _clasificar_con_modelo(self, imagen_path):
        """Clasificación real con TensorFlow."""
        import tensorflow as tf
        
        # Cargar y preprocesar imagen
        img = Image.open(imagen_path).resize((224, 224))
        img_array = np.array(img) / 255.0
        img_array = np.expand_dims(img_array, axis=0)
        
        # Predecir
        predicciones = self.model.predict(img_array, verbose=0)
        categoria_idx = np.argmax(predicciones[0])
        confianza = float(predicciones[0][categoria_idx] * 100)
        
        categoria = self.CATEGORIAS.get(categoria_idx, self.CATEGORIAS[0])
        
        return {
            'categoria': categoria['nombre'],
            'categoria_display': categoria['display'],
            'confianza': round(confianza, 2),
            'puntos_base': categoria['puntos_base'],
        }
    
    def _clasificar_simulado(self, imagen_path):
        """
        Simulación de clasificación para desarrollo.
        Usa el nombre del archivo o características básicas para "predecir".
        """
        import random
        
        # Intentar adivinar por el nombre del archivo
        nombre = os.path.basename(imagen_path).lower()
        
        for idx, cat in self.CATEGORIAS.items():
            if cat['nombre'] in nombre:
                return {
                    'categoria': cat['nombre'],
                    'categoria_display': cat['display'],
                    'confianza': round(random.uniform(85, 99), 2),
                    'puntos_base': cat['puntos_base'],
                }
        
        # Clasificación aleatoria simulada
        idx = random.randint(0, 4)  # Principalmente plástico, vidrio, metal, papel, cartón
        categoria = self.CATEGORIAS[idx]
        
        return {
            'categoria': categoria['nombre'],
            'categoria_display': categoria['display'],
            'confianza': round(random.uniform(70, 95), 2),
            'puntos_base': categoria['puntos_base'],
        }


# Instancia global
classifier = WasteClassifier()