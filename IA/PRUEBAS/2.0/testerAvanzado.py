from keras import models
import os
import numpy as np
import cv2
import random

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
    index = 0
    errores = []
    for pais in os.listdir(ruta_nombrePaises):
        # Por cada pais
        imagenes = []
        for imagen in os.listdir(ruta_nombrePaises+pais):
            imagenes.append(imagen)
        fallos = 0
        for intento in range(49):
            img = imagenes[random.randint(0,len(imagenes) - 1)]
            rutaIMG = ruta_nombrePaises + pais + "/" + img
            imagen = cv2.imread(rutaIMG)
            imagen = cv2.resize(imagen, (ancho, alto))
            # Preguntar al modelo IA
            resultado = model.predict(np.array([imagen]))
            nombre = nombres[resultado.argmax()]
            if nombres[index] != nombre:
                fallos += 1
            
        if fallos > 0:
            errores.append(f"{nombres[index]} ==> {fallos}")
            
        index += 1
        # OTRO PAIS
    
    print("Lista de errores")
    for error in errores:
        print(error)