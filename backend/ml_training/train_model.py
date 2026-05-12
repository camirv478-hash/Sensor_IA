"""
Entrenamiento del modelo de clasificación de residuos.
Dataset: TrashNet (6 categorías)
"""
import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import matplotlib.pyplot as plt

# Configuración
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 15
MODEL_PATH = '../ml_models/waste_model.h5'

def crear_modelo(num_clases=6):
    """Crear modelo CNN con Transfer Learning (MobileNetV2)."""
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(224, 224, 3),
        include_top=False,
        weights='imagenet'
    )
    base_model.trainable = False  # Congelar pesos preentrenados
    
    model = keras.Sequential([
        base_model,
        layers.GlobalAveragePooling2D(),
        layers.Dropout(0.3),
        layers.Dense(256, activation='relu'),
        layers.BatchNormalization(),
        layers.Dropout(0.3),
        layers.Dense(128, activation='relu'),
        layers.Dense(num_clases, activation='softmax')
    ])
    
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model


def cargar_datos(data_dir):
    """Cargar dataset con aumento de datos."""
    datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=30,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=0.2,
        zoom_range=0.3,
        horizontal_flip=True,
        fill_mode='nearest',
        validation_split=0.2
    )
    
    train_generator = datagen.flow_from_directory(
        data_dir,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='training',
        shuffle=True
    )
    
    val_generator = datagen.flow_from_directory(
        data_dir,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='validation',
        shuffle=False
    )
    
    return train_generator, val_generator


def main():
    print("=" * 50)
    print("🧠 ENTRENANDO MODELO DE CLASIFICACIÓN DE RESIDUOS")
    print("=" * 50)
    
    # Verificar si hay dataset descargado
    data_dir = 'ml_training/dataset/trashnet'
    if not os.path.exists(data_dir):
        print("\n⚠️  Dataset no encontrado. Descargando TrashNet...")
        os.makedirs('dataset', exist_ok=True)
        
        # Intentar descargar con kagglehub
        try:
            import kagglehub
            path = kagglehub.dataset_download("tarundalal/dataset-trashnet")
            print(f"✅ Dataset descargado en: {path}")
            data_dir = path
        except:
            print("\n❌ No se pudo descargar automáticamente.")
            print("Descarga manual de: https://www.kaggle.com/datasets/tarundalal/dataset-trashnet")
            print("Extrae en: ml_training/dataset/trashnet/")
            print("\nEstructura esperada:")
            print("dataset/trashnet/")
            print("  ├── glass/")
            print("  ├── paper/")
            print("  ├── cardboard/")
            print("  ├── plastic/")
            print("  ├── metal/")
            print("  └── trash/")
            return
    
    # Cargar datos
    print("\n📂 Cargando dataset...")
    train_gen, val_gen = cargar_datos(data_dir)
    
    clases = list(train_gen.class_indices.keys())
    print(f"\n📊 Categorías detectadas: {clases}")
    print(f"   Imágenes de entrenamiento: {train_gen.samples}")
    print(f"   Imágenes de validación: {val_gen.samples}")
    
    # Crear y entrenar modelo
    print("\n🏗️  Construyendo modelo...")
    model = crear_modelo(num_clases=len(clases))
    model.summary()
    
    # Callbacks
    early_stop = keras.callbacks.EarlyStopping(
        monitor='val_accuracy',
        patience=5,
        restore_best_weights=True
    )
    
    reduce_lr = keras.callbacks.ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.2,
        patience=3,
        min_lr=1e-6
    )
    
    # Entrenar
    print("\n🚀 Iniciando entrenamiento...")
    history = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=EPOCHS,
        callbacks=[early_stop, reduce_lr],
        verbose=1
    )
    
    # Guardar modelo
    os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)
    model.save(MODEL_PATH)
    print(f"\n💾 Modelo guardado en: {MODEL_PATH}")
    
    # Mostrar resultados
    val_acc = max(history.history['val_accuracy'])
    print(f"\n📈 Mejor precisión de validación: {val_acc:.2%}")
    
    # Guardar nombres de clases
    with open('../ml_models/classes.txt', 'w') as f:
        f.write('\n'.join(clases))
    print(f"📝 Clases guardadas: {clases}")
    
    print("\n✅ ¡Entrenamiento completado!")


if __name__ == '__main__':
    main()