import tensorflow as tf

dispositivos = tf.config.list_physical_devices()

for d in dispositivos:
    print(d)