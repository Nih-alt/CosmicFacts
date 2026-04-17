## Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

## Flutter InAppWebView
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-dontwarn com.pichillilorenzo.flutter_inappwebview.**
-keep class android.webkit.** { *; }

## OkHttp & Okio (used by InAppWebView & http)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**

## Firebase & Google Services
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

## Hive
-keep class ** extends com.google.protobuf.** { *; }
-keep class hive.** { *; }

## Google Fonts
-keep class com.google.android.** { *; }

## Cached Network Image
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

## URL Launcher
-keep class android.content.Intent { *; }

## Gson (if used internally by any plugin)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

## General Android
-keep class androidx.** { *; }
-dontwarn androidx.**
-keep class android.** { *; }
-dontwarn android.**

## Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

## Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

## Keep Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

## Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

## Suppress warnings
-dontwarn javax.**
-dontwarn sun.misc.**
-dontwarn java.lang.invoke.**

## R8 compatibility
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
