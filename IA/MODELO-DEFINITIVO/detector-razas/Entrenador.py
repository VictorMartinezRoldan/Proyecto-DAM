import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
import os

# Configuración de GPU
physical_gpus = tf.config.list_physical_devices('GPU')
if physical_gpus:
    try:
        for gpu in physical_gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        print(f"GPUs detectadas: {[gpu.name for gpu in physical_gpus]}")
    except RuntimeError as e:
        print(f"Error al configurar GPUs: {e}")
else:
    print("No se detectaron GPUs disponibles.")

# Parámetros globales
ANCHURA = 224
ALTURA = 224
RUTA_TRAIN = "dataset_train"
BATCH_SIZE = 64
VALIDATION_SPLIT = 0.2

# Validar existencia de la ruta
if not os.path.exists(RUTA_TRAIN):
    raise FileNotFoundError(f"La ruta especificada '{RUTA_TRAIN}' no existe.")


# -----------------------------------------------------------------

# Cargar y preprocesar datos con ImageDataGenerator
datagen = ImageDataGenerator(
    rescale=1.0/255.0,
    validation_split=VALIDATION_SPLIT
)

train_generator = datagen.flow_from_directory(
    RUTA_TRAIN,
    target_size=(ANCHURA, ALTURA),
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='training'
)

val_generator = datagen.flow_from_directory(
    RUTA_TRAIN,
    target_size=(ANCHURA, ALTURA),
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='validation'
)

# -----------------------------------------------------------------

# Obtener el número de clases
num_clases = len(train_generator.class_indices)
print(f"Se detectaron {num_clases} clases en total.")

cerebro = int(num_clases / 2 * 5)

print(f"Cerebro : {cerebro} neuronas.")
print("--------------------")

# Tipo de clasificación = BINARIA
modelo = tf.keras.Sequential([
    layers.InputLayer(input_shape=(ANCHURA, ALTURA, 3)),
    layers.Conv2D(32, (3,3), activation='relu'),
    layers.MaxPooling2D(pool_size=(2, 2)), # Selecciona el valor máximo de una región y conserva la info más importante.
    layers.Conv2D(64, (3,3), activation='relu'),
    layers.MaxPooling2D(pool_size=(2, 2)),  # Además mejora la eficacia y evita el overfitting.
    layers.Conv2D(64, (4,4), activation='relu'),
    layers.MaxPooling2D(pool_size=(2, 2)),
    layers.Conv2D(128, (6,6), activation='relu'),
    layers.MaxPooling2D(pool_size=(2, 2)),
    layers.Conv2D(128, (9,9), activation='relu'),
    layers.MaxPooling2D(pool_size=(2, 2)),
    layers.Flatten(), # Aplana imagen 2D a un vector 1D para ser procesada por la capas densas.
    layers.Dense(cerebro, activation='relu'),
    layers.Dropout(0.5), # Desactiva aleatoriamente la mitad de las neuronas para que aprenda de otras neuronas.
    layers.Dense(num_clases, activation='softmax') # Neuronas == Num de clases a clasificar
])

modelo.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# -----------------------------------------------------------------
modelo.summary()

# Definir callbacks
callbacks = [
    EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True),
    ModelCheckpoint('DetectorRazas.keras', save_best_only=True)
]
# -----------------------------------------------------------------
# Entrenar el modelo
print("Comenzando el entrenamiento...")

modelo.fit(train_generator, validation_data=val_generator, epochs=12, callbacks=callbacks)

print("Entrenamiento completado. Modelo guardado como 'DetectorRazas.keras'.")