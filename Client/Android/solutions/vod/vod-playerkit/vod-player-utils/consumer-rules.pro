-keep class com.byteplus.playerkit.utils.**{*;}
-keepclassmembers,allowobfuscation class * extends com.byteplus.playerkit.utils.event.Event {
   <init>();
}