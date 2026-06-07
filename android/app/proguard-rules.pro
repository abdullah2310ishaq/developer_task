# Stripe Payment Sheet (required if R8/minify is enabled in release)
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
-keep class com.stripe.** { *; }

# flutter_local_notifications + permission_handler (release-safe)
-keep class com.dexterous.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }
