from keras import models
import os
import numpy as np
import cv2

# ---------------------------------------------------------
ruta_imagen = "dataset_train/Espana/EjemploEspana777.jpg"
# ---------------------------------------------------------

model = models.load_model("IA-Banderas.keras")
print("MODELO CARGADO CON ÉXITO\n")

ancho = 124
alto = 124

ruta_nombrePaises = "dataset_train/"

nombres = []

try:
    with open("listaPaises.txt", "r", encoding="utf-8") as archivo:
        for pais in archivo.readlines():
            nombres.append(pais.strip())
except FileNotFoundError as fnf:
    print("--------------------------------------")
    print("Archivo listaPaises.txt no encontrado.")
    print("Ejecutando plan B...")
    print("--------------------------------------")
    if os.path.exists(ruta_nombrePaises):
        for pais in os.listdir(ruta_nombrePaises):
            nombres.append(pais)
    else:
        print("Directorio dataset_train no encontrado.")
if not nombres:
    print("Faltan archivos, no se puede continuar la ejecución.")
else:
    if os.path.exists(ruta_imagen):
        # Preparar la imagen
        imagen = cv2.imread(ruta_imagen)
        imagen = cv2.resize(imagen, (ancho, alto))

        # Preguntar al modelo IA
        resultado = model.predict(np.array([imagen]))

        # A partir del índice buscar el nombre del país
        nombre = nombres[resultado.argmax()]

        print("------------------------------------")
        print(f"Creo que es la bandera de {nombre}")
        print("------------------------------------")
    else:
        print("Ruta de la imagen mal introducida o no existe.")