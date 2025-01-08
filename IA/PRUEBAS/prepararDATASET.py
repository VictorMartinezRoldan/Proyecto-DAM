import os
import shutil
path = "dataset_train/"
for pais in os.listdir(path):
    print(pais)
    pathPAIS = path + pais
    pathIMG = path + pais + "/images/"
    if os.path.exists(pathIMG):
        print("--------> TIENE CARPETA 'images'")
        for img in os.listdir(pathIMG):
            pathIMGENES = pathIMG + img
            shutil.move(pathIMGENES, pathPAIS)
        os.rmdir(pathIMG)
print("Operación realizada con éxito.")