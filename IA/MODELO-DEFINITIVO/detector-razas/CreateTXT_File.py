import os

# Ruta base donde están las carpetas
ruta_base = "dataset_train"  # cámbiala si quieres otra carpeta

# Archivo donde se guardará la lista
archivo_salida = "lista_carpetas.txt"

# Obtener todas las carpetas dentro de la ruta_base
carpetas = [nombre for nombre in os.listdir(ruta_base)
            if os.path.isdir(os.path.join(ruta_base, nombre))]

# Guardar en un archivo txt
with open(archivo_salida, "w", encoding="utf-8") as f:
    for carpeta in sorted(carpetas):  # ordenado alfabéticamente
        f.write(carpeta + "\n")

print(f"Se han guardado {len(carpetas)} carpetas en '{archivo_salida}'")