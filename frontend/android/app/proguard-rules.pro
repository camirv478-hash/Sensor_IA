# Reglas para que R8 ignore las clases faltantes de TensorFlow Lite GPU
-dontwarn org.tensorflow.lite.gpu.**
-keep class org.tensorflow.lite.** { *; }