import os

# Ruta principal
path = "dataset_train/"

# Recorrer las carpetas por cada país
for pais in os.listdir(path):
    pathPAIS = path + pais
    
    print(pathPAIS)
    
    
    nombrePais = pais.replace(" ", "")
    
    print(f"Procesando imágenes en: {pathPAIS}")
    
    # Enumerar y renombrar las imágenes
    for i, img in enumerate(os.listdir(pathPAIS), start=1):
        _, extension = os.path.splitext(img)
        # Crear el nuevo nombre según el formato
        nuevo_nombre = f"Ejemplo{nombrePais}{i}{extension}"
        ruta_actual = pathPAIS + f"/{img}"
        nueva_ruta = pathPAIS + f"/{nuevo_nombre}"
        os.rename(ruta_actual, nueva_ruta)
    
print("Renombrado de imágenes completado.")