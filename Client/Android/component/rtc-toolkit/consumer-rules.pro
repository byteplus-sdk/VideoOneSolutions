# For Event which maybe reflect created by Gson
-keepclassmembers,allowobfuscation @com.vertcdemo.core.annotation.Event class * {
    <init>();
}

# For BytePlusRTC
# Understand the @CalledByNative support annotation.
-keep class com.bytedance.realx.base.CalledByNative

-keep @com.bytedance.realx.base.CalledByNative class * {*;}

-keepclasseswithmembers class * {
    @com.bytedance.realx.base.CalledByNative <methods>;
}

-keepclasseswithmembers class * {
    @com.bytedance.realx.base.CalledByNative <fields>;
}

-keepclasseswithmembers class * {
    @com.bytedance.realx.base.CalledByNative <init>(...);
}
