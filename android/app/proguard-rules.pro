# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.mlkit.** { *; }

# Keep Firebase Instance ID
-keep class com.google.firebase.iid.FirebaseInstanceId { *; }

# Keep Annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature

# Keep Exceptions
-keep public class * extends java.lang.Exception

# Firebase Authentication
-keepattributes Signature
-keepattributes *Annotation*

# Firebase Realtime Database
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers class com.example.untitled1.models.** {
  *;
}

# Firebase Cloud Messaging
-keep class com.google.firebase.messaging.** { *; }

# Agora RTC
-keep class io.agora.** { *; }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# androidx.window classes
-keep class androidx.window.** { *; }
-keep class androidx.window.extensions.** { *; }
-keep class androidx.window.sidecar.** { *; }

# Play Core library
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# WebRTC
-keep class org.webrtc.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Enum
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelables
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Keep R
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep JavaScript Interface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Don't warn about optional return null
-dontwarn kotlin.Unit

# Don't warn about Kotlin annotations
-dontwarn kotlin.annotations.Metadata

# Don't warn about missing WebRTC classes
-dontwarn org.webrtc.**

# Don't warn about missing Firebase classes
-dontwarn com.google.firebase.**

# Don't warn about missing Play Services classes
-dontwarn com.google.android.gms.**