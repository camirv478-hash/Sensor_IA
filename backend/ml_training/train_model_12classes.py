import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
import numpy as np
import os
import matplotlib.pyplot as plt

# ================= CONFIGURACIÓN =================
DATA_DIR = "ml_training/dataset/garbage12/garbage_classification"  # Carpeta con las 12 subcarpetas
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 20
NUM_CLASSES = 12  # Mantenemos 12 clases para más riqueza (luego mapearemos a 6 si quieres)
MODEL_SAVE_PATH = "modelo_sensoria_12clases.h5"
TFLITE_SAVE_PATH = "modelo_sensoria_12clases.tflite"

# ================= PREPROCESAMIENTO =================
datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=20,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    validation_split=0.2  # 20% para validación
)

train_generator = datagen.flow_from_directory(
    DATA_DIR,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='training'
)

val_generator = datagen.flow_from_directory(
    DATA_DIR,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='validation'
)

print("Clases encontradas:", list(train_generator.class_indices.keys()))

# ================= CONSTRUIR MODELO (Transfer Learning con MobileNetV2) =================
base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
base_model.trainable = False  # Congelamos capas iniciales

x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(128, activation='relu')(x)
x = Dropout(0.5)(x)
predictions = Dense(NUM_CLASSES, activation='softmax')(x)

model = Model(inputs=base_model.input, outputs=predictions)
model.compile(optimizer=Adam(learning_rate=0.001),
              loss='categorical_crossentropy',
              metrics=['accuracy'])

model.summary()

# ================= ENTRENAMIENTO =================
history = model.fit(
    train_generator,
    steps_per_epoch=train_generator.samples // BATCH_SIZE,
    epochs=EPOCHS,
    validation_data=val_generator,
    validation_steps=val_generator.samples // BATCH_SIZE,
    verbose=1
)

# ================= GUARDAR MODELO KERAS =================
model.save(MODEL_SAVE_PATH)
print(f"Modelo guardado en {MODEL_SAVE_PATH}")

# ================= CONVERTIR A TENSORFLOW LITE =================
# Convertir a TFLite con cuantización para reducir tamaño y acelerar
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]  # Cuantización por defecto
converter.target_spec.supported_types = [tf.float16]  # Opcional: fp16
tflite_model = converter.convert()

with open(TFLITE_SAVE_PATH, 'wb') as f:
    f.write(tflite_model)
print(f"Modelo TFLite guardado en {TFLITE_SAVE_PATH}")

# ================= GRÁFICAS DE RENDIMIENTO =================
plt.figure(figsize=(12,4))
plt.subplot(1,2,1)
plt.plot(history.history['accuracy'], label='Entrenamiento')
plt.plot(history.history['val_accuracy'], label='Validación')
plt.title('Precisión')
plt.legend()
plt.subplot(1,2,2)
plt.plot(history.history['loss'], label='Entrenamiento')
plt.plot(history.history['val_loss'], label='Validación')
plt.title('Pérdida')
plt.legend()
plt.savefig('training_history.png')
plt.show()