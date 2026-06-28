# Flutter
# Keep Dart classes and methods used via reflection.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }

# Gal (gallery saver)
-keep class com.gallery.** { *; }

# Play Core (Flutter deferred components glue references these optional classes)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Don't warn about missing optional classes
-dontwarn org.jetbrains.annotations.**
-dontwarn javax.lang.model.element.**
-dontwarn kotlin.Unit
