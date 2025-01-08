import tensorflow as tf
from datasets import load_dataset # Para cargar el DATA-SET
import matplotlib.pyplot as plt # Para mostrar las imágenes literalmente
from sklearn.preprocessing import LabelEncoder # Para transformar las etiquetas

print("------------------")
print("Buscando DATA-SET")
print("------------------")
print("Cargando...")
# ----------------------------------------------------------------
# PARA CARGAR EL DATA-SET LOCAL
ruta_dataset = 'RUTA'
dataset = load_dataset('parquet', data_files=ruta_dataset) # 'EXTENSIÓN DE LOS DATOS DE ENTRENAMIENTO', data_files=ruta
# ----------------------------------------------------------------
print("------------------")
print("DATA-SET Cargado")
print("------------------")
# ----------------------------------------------
datos_entrenamiento = dataset['train']
num_datos_entrenamiento = len(dataset["train"])
# ----------------------------------------------
print("Número de datos de entrenamiento: " + str(num_datos_entrenamiento))
print("EJEMPLO 1: " +  str(datos_entrenamiento[0]))
''' # Para mostrar las imágenes literalmente
plt.imshow(datos_entrenamiento[0]['flag'])
plt.title(datos_entrenamiento[0]['country'])
plt.axis('off')  # Desactivar los ejes
plt.show()
'''
# Función para procesar imágenes
def procesar_imagenes(image):
    return image.resize((224, 224)) # Redimensionar la imagen a un tamaño fijo (ej. 224x224)

# Función para procesar dataset
def procesar_dataset(examples):
    examples['flag'] = [procesar_imagenes(image.convert('RGB')) for image in examples['flag']]
    return examples

# Procesar el dataset
dataset['train'] = dataset['train'].map(procesar_dataset, batched=True)

#------------------------------------------------------------------
# Convertir las etiquetas string a números (índices)
# Crear un codificador de etiquetas
label_encoder = LabelEncoder()

# Obtener todas las etiquetas de país
etiquetas = [ejemplo['country'] for ejemplo in dataset['train']]

# Codificar las etiquetas (de string a enteros)
etiquetas_codificadas = label_encoder.fit_transform(etiquetas)

# Actualizar el dataset con las etiquetas codificadas
dataset['train'] = dataset['train'].map(lambda ejemplo, idx: {'country': etiquetas_codificadas[idx], 'flag': ejemplo['flag']}, with_indices=True)
#------------------------------------------------------------------

# Convertir a tf.data.Dataset (DataSet adaptado a TensorFlow)
train_dataset = dataset['train'].to_tf_dataset(
    columns='flag',
    label_cols='country',
    shuffle=True,
    batch_size=32
)

# Pasar a caché los datos para el entrenamiento
train_dataset = train_dataset.cache()

modelo = tf.keras.Sequential ([
    tf.keras.layers.Flatten(input_shape=(224,224, 3)), #3 RGB
    tf.keras.layers.Dense(128, activation=tf.nn.relu), # 1º Capa Densa / 128 neuronas
    tf.keras.layers.Dense(128, activation=tf.nn.relu), # 2º Capa Densa / 128 neuronas
    tf.keras.layers.Dense(128, activation=tf.nn.relu), # 3º Capa Densa / 128 neuronas
    tf.keras.layers.Dense(255, activation=tf.nn.softmax), # Capa de salida, softmax asegura que siempre de una respuesta / 10 neuronas
])

# Compilar el modelo
modelo.compile(
    optimizer='adam', # Optimizador
    loss=tf.keras.losses.SparseCategoricalCrossentropy(), # Función de pérdida (Cuando se equivoca)
    metrics=['accuracy'] # Para medir la precisión
)

# ----------------------------------------------
# COMENZAR A ENTRENAR
# ----------------------------------------------
# epoch = Para decir cuantas veces quieres darle vueltas a los datos.
historial = modelo.fit(train_dataset, epochs=10)

# Ver resultados del entrenamiento
plt.xlabel("VUELTAS")
plt.ylabel("ERRORES")
plt.plot(historial.history["loss"], label="Pérdida", color='blue')
# Añadir título y etiquetas
plt.title("Pérdida durante el Entrenamiento")
plt.xlabel("Épocas")
plt.ylabel("Valor de la Pérdida")
# Mostrar leyenda
plt.legend()
# Mostrar gráfico
plt.show()

# Guardar Modelo
modelo.save('primer_modelo_banderas', save_format="tf")