import tensorflow as tf

# Cargar el modelo entrenado
modelo = tf.keras.models.load_model('DetectorRazas.keras')

# Convertir a TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(modelo)
tflite_model = converter.convert()

# Guardar el modelo TFLite en disco
with open('DetectorRazas.tflite', 'wb') as f:
    f.write(tflite_model)

print("Conversión completada. Modelo guardado como 'DetectorRazas.tflite'")