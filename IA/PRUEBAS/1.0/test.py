import tensorflow as tf
from datasets import load_dataset # Para cargar el DATA-SET
import matplotlib.pyplot as plt # Para mostrar las imágenes literalmente
from sklearn.preprocessing import LabelEncoder # Para transformar las etiquetas
import random
import numpy as np

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

numero_aleatorio = random.randint(0, 254)
# Para mostrar las imágenes literalmente
plt.imshow(datos_entrenamiento[numero_aleatorio]['flag'])
plt.title(datos_entrenamiento[numero_aleatorio]['country'] + " --> " + str(numero_aleatorio))
plt.axis('off')  # Desactivar los ejes
plt.show()

# Función para procesar imágenes
def procesar_imagenes(image):
    imagen = image.resize((224, 224)) # Redimensionar la imagen a un tamaño fijo (ej. 224x224)
    return np.array(imagen)

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

# Verifica algunos ejemplos después de procesarlos
print("----------------")
print("Ejemplo 1 procesado:", dataset['train'][24])  # Muestra un ejemplo procesado


#------------------------------------------------------------------
# Convertir a tf.data.Dataset (DataSet adaptado a TensorFlow)
train_dataset = dataset['train'].to_tf_dataset(
    columns='flag',
    label_cols='country',
    shuffle=True,
    batch_size=32
)
print("------------------------------------")
num_ejemplos = sum(1 for _ in train_dataset)
print("Número de ejemplos en el dataset: ", num_ejemplos)

# Iterar sobre el dataset para ver algunos lotes
for batch in train_dataset.take(1):  # Tomar un lote de tamaño 1
    flags, countries = batch  # Desempaquetamos las imágenes y las etiquetas (flags y countries)
    
    print("Lote de imágenes:")
    print(flags.shape)  # Forma del tensor de imágenes, debería ser (batch_size, 224, 224, 3)
    print(flags[200])  # Muestra la primera imagen del lote (tendrá un array de valores de píxeles)
    
    print("Lote de etiquetas:")
    print(countries.shape)  # Forma del tensor de etiquetas, debería ser (batch_size,)
    print(countries[200])  # Muestra la primera etiqueta del lote (un valor codificado de país)
