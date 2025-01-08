import os
import numpy as np
import cv2
import tensorflow as tf
from keras import layers, models

def es_jpg(filename):
    return filename.lower().endswith('.jpg')

anchura = 124
altura = 124
ruta_train = "dataset_train"

train_x = []
train_y = []

paises = os.listdir(ruta_train)
num_paises = len(paises)
num_imagenes = 0

for i in os.listdir(ruta_train):
    pais_path = os.path.join(ruta_train, i)
    for j in os.listdir(pais_path):
        if es_jpg(j):
            num_imagenes += 1
            img_path = os.path.join(pais_path, j)
            img = cv2.imread(img_path)
            if img is not None:
                img = cv2.resize(img, (anchura, altura))
                train_x.append(img)

                pais_index = paises.index(i)
                array = np.zeros(num_paises)
                array[pais_index] = 1
                train_y.append(array)
            else:
                print(f"Error al leer la imagen: {img_path}")

print("--------------------")
print("IMÁGENES CARGADAS.")
print(f"HAY {num_paises} países")
print(f"HAY {num_imagenes} imagenes")
print("--------------------")

x_data = np.array(train_x)
y_data = np.array(train_y)

cerebro = int(num_paises / 2 * 5)

print(f"Cerebro : {cerebro} neuronas.")
print("--------------------")

model = tf.keras.Sequential([
    layers.InputLayer(input_shape=(anchura, altura, 3)),
    layers.Conv2D(32, (3, 3), activation='relu'),
    layers.MaxPooling2D(pool_size=(2, 2)),
    layers.Conv2D(64, (3, 3), activation='relu'),
    layers.MaxPooling2D(pool_size=(2, 2)),
    layers.Conv2D(64, (3, 3), activation='relu'),
    layers.MaxPooling2D(pool_size=(2, 2)),
    layers.Conv2D(128, (3, 3), activation='relu'),
    layers.MaxPooling2D(pool_size=(2, 2)),
    layers.Conv2D(128, (3, 3), activation='relu'),
    layers.MaxPooling2D(pool_size=(2, 2)),
    layers.Flatten(),
    layers.Dense(cerebro, activation='relu'),
    layers.Dropout(0.5),
    layers.Dense(num_paises, activation='sigmoid')
])

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

print("-------------")
print("TODO CORRECTO")
print("-------------")
print("Comenzando a entrenar...\n")

model.fit(x_data, y_data, epochs=9, batch_size=128, validation_split=0.2)

model.save("IA-Banderas.keras")
print("Modelo guardado.")