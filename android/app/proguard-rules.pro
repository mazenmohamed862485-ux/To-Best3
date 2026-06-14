# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dio / Retrofit
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# SQLite
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# App models
-keep class com.tobest.app.** { *; }

# Flutter secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# WebView
-keep class com.google.android.gms.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

-dontwarn java.lang.invoke.**
-dontwarn **$$serializer
