# Google OAuth Setup Guide for MACRO Android App

## Prerequisites
1. Google Cloud Console project
2. Supabase project with authentication enabled
3. Android app configured in Google Cloud Console

## Step 1: Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable Google+ API and Google Sign-In API
4. Create OAuth 2.0 credentials:
   - **Android client**: Use your app's package name (`io.lumoralabs.macro`) and SHA-1 certificate fingerprint
   - **Web client**: For Supabase authentication

### Get SHA-1 Certificate Fingerprint
```bash
# For debug builds
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release builds (use your actual keystore)
keytool -list -v -keystore /path/to/your/release-keystore.jks -alias your-alias
```

## Step 2: Supabase Configuration

1. Go to your [Supabase Dashboard](https://app.supabase.com/)
2. Navigate to Authentication > Settings > Auth
3. Enable Google provider
4. Add your Google OAuth credentials:
   - **Client ID**: Use the Web client ID from Google Cloud Console
   - **Client Secret**: Use the Web client secret from Google Cloud Console
5. Add authorized redirect URLs:
   - `https://your-project-id.supabase.co/auth/v1/callback`

## Step 3: Android App Configuration

1. Download `google-services.json` from Google Cloud Console
2. Place it in `android/app/` directory (replace the example file)
3. Update the Web Client ID in `SupabaseService.kt`:
   ```kotlin
   .requestIdToken("YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com")
   ```

## Step 4: Build Configuration

Add Google Services plugin to `android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

Add to `android/gradle/libs.versions.toml`:
```toml
[versions]
googleServices = "4.4.0"

[plugins]
google-services = { id = "com.google.gms.google-services", version.ref = "googleServices" }
```

## Step 5: Testing

1. Build the app with the new configuration
2. Test Google Sign-In flow
3. Verify user data appears in Supabase Auth dashboard

## Important Notes

- The Web Client ID (not Android Client ID) should be used for `requestIdToken()`
- Ensure your app's SHA-1 fingerprint matches the one in Google Cloud Console
- Test both debug and release builds with appropriate certificates
- The Google Sign-In flow requires ActivityResultLauncher for production use

## Troubleshooting

- **Error 10**: Usually means SHA-1 fingerprint mismatch
- **Error 12500**: Check google-services.json configuration
- **Invalid ID token**: Verify Web Client ID is correct in both Google Cloud Console and Supabase
