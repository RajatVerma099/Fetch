# Add project specific ProGuard rules here.

# Keep Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Keep scanner plugin classes
-keep class com.fetch.fetch.** { *; }
