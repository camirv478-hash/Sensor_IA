"""
Crear dataset sintético pequeño para prueba del pipeline.
En producción, usa el dataset TrashNet real.
"""
import os
import numpy as np
from PIL import Image

CATEGORIAS = ['plastico', 'vidrio', 'metal', 'papel', 'carton', 'organico']
COLORES = {
    'plastico': (0, 100, 255),    # Azul
    'vidrio': (100, 255, 100),    # Verde
    'metal': (200, 200, 200),     # Gris
    'papel': (255, 255, 200),     # Amarillo claro
    'carton': (180, 130, 80),     # Marrón
    'organico': (100, 180, 50),   # Verde oscuro
}

def crear_dataset_sintetico():
    base_dir = 'dataset/trashnet'
    
    for categoria in CATEGORIAS:
        train_dir = os.path.join(base_dir, categoria)
        os.makedirs(train_dir, exist_ok=True)
        
        for i in range(50):  # 50 imágenes por categoría
            img = Image.new('RGB', (224, 224), COLORES[categoria])
            # Añadir variación aleatoria
            pixels = np.array(img)
            ruido = np.random.randint(-30, 30, pixels.shape).astype(np.int16)
            pixels = np.clip(pixels.astype(np.int16) + ruido, 0, 255).astype(np.uint8)
            img = Image.fromarray(pixels)
            img.save(os.path.join(train_dir, f'{categoria}_{i:03d}.jpg'))
        
        print(f"✅ Creadas 50 imágenes de {categoria}")
    
    print("\n🎉 Dataset sintético creado!")
    print("Ejecuta: python train_model.py para entrenar")

if __name__ == '__main__':
    crear_dataset_sintetico()