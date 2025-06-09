import os
import pandas as pd

# Ruta al Excel y a la carpeta que contiene los directorios
ruta_excel = 'excel.xlsx'  # Cambia esto por tu archivo
columna_nombres = 'RAZA'  # Cambia esto si tu columna se llama diferente
ruta_carpetas = 'Razas_Perro_Procesadas/'  # Cambia esto por la ruta real

# Leer nombres desde el Excel
df = pd.read_excel(ruta_excel)
nombres_excel = set(df[columna_nombres].astype(str).str.strip())

# Leer nombres de carpetas existentes
nombres_carpetas = set([
    nombre for nombre in os.listdir(ruta_carpetas)
    if os.path.isdir(os.path.join(ruta_carpetas, nombre))
])

# Comprobar diferencias
faltan_carpeta = nombres_excel - nombres_carpetas
sobran_carpeta = nombres_carpetas - nombres_excel

print("FALTAN carpetas que están en el Excel pero no en el sistema de archivos:")
for nombre in faltan_carpeta:
    print("-", nombre)

print("\nSOBRAN carpetas que existen pero no están en el Excel:")
for nombre in sobran_carpeta:
    print("-", nombre)
