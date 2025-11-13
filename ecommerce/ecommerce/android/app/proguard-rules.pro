# Keep annotation classes referenced by Google libraries (Tink, etc.)
-keep class com.google.errorprone.annotations.** { *; }
-dontwarn com.google.errorprone.annotations.**

-keep class javax.annotation.** { *; }
-dontwarn javax.annotation.**

-keep class javax.annotation.concurrent.** { *; }
-dontwarn javax.annotation.concurrent.**

# Keep Google Tink primitives if referenced
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Keep annotation attributes so R8 doesn't strip useful metadata
-keepattributes *Annotation*

# Optionally keep Flutter plugin registrant (safe)
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Keep AndroidX and support libs used by plugins
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep okhttp/okio if used by HTTP packages
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
