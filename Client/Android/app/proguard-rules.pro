# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

-repackageclasses 'ls'

-dontwarn com.bytedance.**
-dontwarn com.effectsar.labcv.**
-dontwarn com.ss.**

-dontwarn com.google.android.exoplayer2.util.Log
-dontwarn okhttp3.internal.Version
-dontwarn okhttp3.internal.connection.StreamAllocation

# for MediaLive
-keep class com.bytedance.** { *; }
-keep class com.bytertc.** { *; }
-keep class com.pandora.** { *; }
-keep class com.pandora.ttlicense2.** { *; }
-keep class com.ss.** { *; }
