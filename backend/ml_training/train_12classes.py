import os
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import ModelCheckpoint

# ================= CONFIGURACIÓN =================
DATA_DIR = "dataset/garbage12/garbage_classification"
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 20
MODEL_SAVE_PATH = "../ml_models/waste_model_12classes.h5"
TFLITE_SAVE_PATH = "../ml_models/waste_model_12classes.tflite"
CHECKPOINT_PATH = "checkpoint_12class.weights.h5"

# Verificar dataset
if not os.path.exists(DATA_DIR):
    raise Exception(f"No se encontró la carpeta: {DATA_DIR}")

# ================= DATA AUGMENTATION =================
datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=20,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    validation_split=0.2
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

# ================= MODELO =================
base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224,224,3))
base_model.trainable = False

x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(128, activation='relu')(x)
x = Dropout(0.5)(x)
predictions = Dense(train_generator.num_classes, activation='softmax')(x)

model = Model(inputs=base_model.input, outputs=predictions)
model.compile(optimizer=Adam(learning_rate=0.001),
              loss='categorical_crossentropy',
              metrics=['accuracy'])

model.summary()

# ================= REANUDAR DESDE CHECKPOINT =================
initial_epoch = 0
if os.path.exists(CHECKPOINT_PATH):
    model.load_weights(CHECKPOINT_PATH)
    print(f"✅ Checkpoint cargado: {CHECKPOINT_PATH}")
    # Si existe, podemos leer el epoch desde el nombre del archivo o simplemente continuar.
    # Por simplicidad, continuaremos desde donde se quedó. 
    # Como empezamos de cero, esto no se aplicará.
else:
    print("No se encontró checkpoint, comenzando desde cero.")

# Callback para guardar después de cada época
checkpoint_cb = ModelCheckpoint(
    CHECKPOINT_PATH,
    save_weights_only=True,
    save_best_only=False,
    verbose=1
)

# ================= ENTRENAMIENTO =================
history = model.fit(
    train_generator,
    steps_per_epoch=train_generator.samples // BATCH_SIZE,
    epochs=EPOCHS,
    validation_data=val_generator,
    validation_steps=val_generator.samples // BATCH_SIZE,
    verbose=1,
    initial_epoch=initial_epoch,
    callbacks=[checkpoint_cb]
)

# ================= GUARDAR MODELO FINAL =================
model.save(MODEL_SAVE_PATH)
print(f"✅ Modelo guardado en {MODEL_SAVE_PATH}")

# Convertir a TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()
with open(TFLITE_SAVE_PATH, 'wb') as f:
    f.write(tflite_model)
print(f"✅ TFLite guardado en {TFLITE_SAVE_PATH}")

try:
    import matplotlib.pyplot as plt
    plt.plot(history.history['accuracy'], label='Entrenamiento')
    plt.plot(history.history['val_accuracy'], label='Validación')
    plt.legend()
    plt.savefig('training_history.png')
    print("✅ Gráfica guardada")
except:
    pass