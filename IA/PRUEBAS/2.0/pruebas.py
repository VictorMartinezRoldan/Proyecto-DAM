import tensorflow as tf
import time

while True:
    gpus = tf.config.list_physical_devices('GPU')
    if gpus:
        print("GPU detectada:")
        for gpu in gpus:
            print(gpu)
    else:
        print("No se detecto ninguna GPU.")
    time.sleep(1)  # Esperar un segundo
