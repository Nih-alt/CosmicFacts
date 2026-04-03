# ─────────────────────────────────────────
# Flutter core
# ─────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ─────────────────────────────────────────
# Hive (key-value storage)
# ─────────────────────────────────────────
-keep class hive.** { *; }
-keep class com.hivedb.** { *; }
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ─────────────────────────────────────────
# Firebase (future use)
# ─────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ─────────────────────────────────────────
# Google Mobile Ads (future use)
# ─────────────────────────────────────────
-keep class com.google.android.gms.ads.** { *; }

# ─────────────────────────────────────────
# OkHttp / Okio (used by http package)
# ─────────────────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ─────────────────────────────────────────
# CachedNetworkImage / Glide
# ─────────────────────────────────────────
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep class * extends com.bumptech.glide.module.AppGlideModule { *; }
-keep public enum com.bumptech.glide.load.ImageHeaderParser$** {
    **[] $VALUES;
    public *;
}

# ─────────────────────────────────────────
# App model classes (Hive serialization)
# ─────────────────────────────────────────
-keep class com.cosmicfacts.app.** { *; }
-keepclassmembers class ** {
    @com.google.gson.annotations.Expose *;
}

# ─────────────────────────────────────────
# Plugin: AudioPlayers
# ─────────────────────────────────────────
-keep class xyz.luan.audioplayers.** { *; }

# ─────────────────────────────────────────
# Plugin: Share Plus
# ─────────────────────────────────────────
-keep class dev.fluttercommunity.plus.share.** { *; }

# ─────────────────────────────────────────
# Plugin: URL Launcher
# ─────────────────────────────────────────
-keep class io.flutter.plugins.urllauncher.** { *; }

# ─────────────────────────────────────────
# Plugin: Flutter Local Notifications
# ─────────────────────────────────────────
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# ─────────────────────────────────────────
# WebView
# ─────────────────────────────────────────
-keep class android.webkit.** { *; }

# ─────────────────────────────────────────
# Attribute preservation
# ─────────────────────────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# ─────────────────────────────────────────
# fl_chart
# ─────────────────────────────────────────
-keep class com.github.mikephil.** { *; }

# ─────────────────────────────────────────
# XML parser
# ─────────────────────────────────────────
-dontwarn org.xmlpull.**
-dontwarn org.w3c.**

# ─────────────────────────────────────────
# Timezone
# ─────────────────────────────────────────
-keep class com.timezone.** { *; }
-dontwarn com.timezone.**

# ─────────────────────────────────────────
# General optimisation
# ─────────────────────────────────────────
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose
