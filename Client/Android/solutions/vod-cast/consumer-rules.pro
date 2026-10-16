# Cast framework classes are referenced by name from the manifest / Play Services.
-keep class com.google.android.gms.cast.framework.** { *; }

# OptionsProvider is instantiated by the Cast framework via its name in the manifest.
-keep class com.byteplus.vodcast.impl.chromecast.CastOptionsProvider { *; }

# Bootstrapper is the single entry that installs the ChromeCast impl into CastSdk.
# Keep it so consuming apps with R8 enabled do not strip/rename it away.
-keep class com.byteplus.vodcast.impl.chromecast.ChromecastBootstrapper { *; }
