# MACRO App Security Guide

## 🚨 CRITICAL SECURITY NOTICE
Your Firebase configuration files contain exposed API keys that are currently in your public GitHub repository!

### Immediate Actions Required:

1. **Remove sensitive files from repository:**
   ```bash
   git rm --cached ios/GoogleService-Info.plist
   git rm --cached android/app/google-services.json
   git commit -m "Remove sensitive Firebase config files"
   git push origin main
   ```

2. **Regenerate Firebase API keys:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project: `macro-7c60a`
   - Regenerate all API keys
   - Download new configuration files
   - Place them locally (they're now gitignored)

3. **Check for API key usage:**
   - Review Firebase project usage logs
   - Monitor for unauthorized access
   - Consider rotating all secrets

## 🔐 Security Configuration Explained

### Currently Exposed Information:
- **iOS API Key:** `AIzaSyCF0-d3vIofj-YX6TQnguFMQmW4pOBhysE`
- **Android API Key:** `AIzaSyD_UNecm0TrYRfEZaQOCTbWMo2K9m71MkU`
- **Project ID:** `macro-7c60a`
- **Database URL:** `https://macro-7c60a-default-rtdb.asia-southeast1.firebasedatabase.app`

### What This Means:
- Anyone can access your Firebase project
- Potential for data breaches
- Unauthorized API usage costs
- App security compromised

## 📋 Protected File Categories

### 1. Firebase Configuration (CRITICAL)
- `ios/GoogleService-Info.plist` - iOS Firebase config
- `android/app/google-services.json` - Android Firebase config

### 2. API Keys & Environment
- `.env*` files - Environment variables
- `*-keys.json` - API key files
- `secrets.json` - Application secrets

### 3. iOS Security
- `*.p8` - Apple Developer certificates
- `*.mobileprovision` - Provisioning profiles
- `*.p12` - PKCS#12 certificates

### 4. Android Security
- `*.jks` - Java keystores
- `keystore.properties` - Signing configurations
- `local.properties` - Local Android settings

### 5. Database Credentials
- Database connection strings
- Authentication tokens
- OAuth secrets

### 6. Third-Party Services
- Analytics (Google Analytics, Mixpanel)
- Payment processing (Stripe, PayPal)
- Cloud services (AWS, Azure, GCP)
- Social media APIs

## 🛡️ Best Practices

### For Developers:
1. **Never commit secrets to version control**
2. **Use environment variables for configuration**
3. **Rotate API keys regularly**
4. **Use Firebase App Check for additional security**
5. **Implement proper Firebase Security Rules**

### For Production:
1. **Use different Firebase projects for dev/prod**
2. **Implement API rate limiting**
3. **Monitor API usage and logs**
4. **Use Firebase Security Rules to restrict access**
5. **Enable Firebase App Check**

## 🔧 Firebase Security Rules Example

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Groups are readable by members only
    match /groups/{groupId} {
      allow read, write: if request.auth != null 
        && request.auth.uid in resource.data.members;
    }
  }
}
```

## 📞 Emergency Response
If you suspect a security breach:
1. Immediately rotate all API keys
2. Check Firebase Console for unusual activity
3. Review app analytics for suspicious usage
4. Consider temporary service suspension
5. Update security rules to be more restrictive

## 📚 Resources
- [Firebase Security](https://firebase.google.com/docs/security)
- [Android Security](https://developer.android.com/topic/security)
- [iOS Security](https://developer.apple.com/documentation/security)
- [Git Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
