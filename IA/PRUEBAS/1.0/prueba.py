import tensorflow as tf
from datasets import load_dataset # Para cargar el DATA-SET
import matplotlib.pyplot as plt # Para mostrar las imágenes literalmente
import random
import numpy as np
from PIL import Image

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

numero_aleatorio = random.randint(0, 254)
imagen = dataset['train'][numero_aleatorio]['flag']


# Función para procesar imágenes
def preprocesar_imagen(imagen):
    # Convertir a formato PIL si es necesario
    if not isinstance(imagen, Image.Image):
        imagen = Image.fromarray(np.array(imagen))
    # Redimensionar la imagen
    imagen = imagen.convert("RGB").resize((224, 224))
    # Convertir a array de NumPy
    img_array = np.array(imagen)
    # Añadir una dimensión extra para batch
    img_array = np.expand_dims(img_array, axis=0)

    return img_array

# Procesar imagenes
imagen_preprocesada = preprocesar_imagen(imagen)

# CARGAR MODELO

custom_objects = {'softmax_v2': tf.keras.activations.softmax}

modelo = tf.keras.models.load_model('primer_modelo_banderas.h5', custom_objects=custom_objects)

print("MODELO CARGADO")


# Para mostrar las imágenes literalmente
plt.imshow(datos_entrenamiento[numero_aleatorio]['flag'])
plt.title(datos_entrenamiento[numero_aleatorio]['country'] + " --> " + str(numero_aleatorio))
plt.axis('off')  # Desactivar los ejes
plt.show()



resultado = modelo.predict(imagen_preprocesada)
indice = np.argmax(resultado)
indice = int(indice)

nombre = datos_entrenamiento[indice]['country']

print(f"INDICE: {indice} --> Resultado: {nombre}")