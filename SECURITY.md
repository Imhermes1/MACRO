# MACRO App Security Guide

## 🚀 Migration Notice: Firebase → Supabase

**MACRO has migrated from Firebase to Supabase.** This security guide has been updated to reflect the new infrastructure.

## 🎯 Security vs. Functionality Balance

**CRITICAL PRINCIPLE:** Protect sensitive API keys while preserving files needed for app operation.

### ✅ Files that MUST be tracked (needed for app to work):
- `ios/Info.plist` - iOS app configuration and permissions
- `android/app/src/main/AndroidManifest.xml` - Android app configuration  
- `ios/Presentation/*.swift` - iOS source code
- `android/app/src/main/java/**/*.kt` - Android source code
- `build.gradle.kts` files - Android build configuration
- `shared/data/*.json` - App content and data
- `Podfile` - iOS dependencies (but not Podfile.lock with versions)
- `supabase_schema.sql` - Database schema (public structure)
- `supabase_policies.sql` - Security policies (public rules)

### ❌ Files that MUST be protected (contain secrets):
- `supabase.config` - Contains Supabase API keys and database credentials
- `ios/SupabaseConfig.plist` - iOS Supabase configuration
- `android/app/supabase.properties` - Android Supabase configuration
- `*.jks`, `*.p8`, `*.p12` - Signing certificates
- `.env` files - Environment variables with secrets

### Immediate Actions Required:

1. **Remove sensitive files from repository:**
   ```bash
   git rm --cached supabase.config
   git rm --cached ios/SupabaseConfig.plist
   git rm --cached android/app/supabase.properties
   git commit -m "Remove sensitive Supabase config files"
   git push origin main
   ```

2. **Regenerate Supabase API keys:**
   - Go to [Supabase Dashboard](https://supabase.com/dashboard)
   - Select your project
   - Go to Settings > API
   - Generate new anon key and service role key
   - Update local configuration files (they're now gitignored)

3. **Check for API key usage:**
   - Review Supabase project logs
   - Monitor for unauthorized access
   - Consider rotating all secrets

## 🔐 Security Configuration Explained

### Migration Changes:
- **Old:** Firebase authentication and Firestore database
- **New:** Supabase authentication and PostgreSQL database
- **Security:** Migrated from Firestore rules to PostgreSQL Row Level Security (RLS)

### What Could Be Exposed:
- **Supabase URL:** Your project URL (e.g., `https://your-project.supabase.co`)
- **Anon Key:** Public API key for client applications
- **Service Role Key:** Admin API key (CRITICAL - never expose)
- **Database Credentials:** PostgreSQL connection details

### What This Means:
- Anyone could access your Supabase project
- Potential for data breaches
- Unauthorized API usage costs
- App security compromised

## 📋 Protected File Categories

### 1. Supabase Configuration (CRITICAL)
- `supabase.config` - Main Supabase configuration
- `ios/SupabaseConfig.plist` - iOS Supabase config
- `android/app/supabase.properties` - Android Supabase config

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
- PostgreSQL connection strings
- Database passwords
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
4. **Implement proper Supabase RLS policies**
5. **Use Supabase's built-in security features**

### For Production:
1. **Use different Supabase projects for dev/prod**
2. **Implement API rate limiting**
3. **Monitor API usage and logs**
4. **Use Row Level Security (RLS) to restrict access**
5. **Enable email verification and strong password policies**

## 🔧 Supabase Security Policies Example

```sql
-- Row Level Security (RLS) Policies
-- Replaces Firebase Security Rules

-- Users can only access their own profile data
CREATE POLICY "Users can view own profile"
ON user_profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON user_profiles FOR UPDATE
USING (auth.uid() = id);

-- Groups are accessible by authenticated users
CREATE POLICY "Authenticated users can view groups"
ON groups FOR SELECT
USING (auth.role() = 'authenticated');
```

## 📞 Emergency Response
If you suspect a security breach:
1. Immediately rotate all Supabase API keys
2. Check Supabase Dashboard for unusual activity
3. Review database logs for suspicious queries
4. Consider temporary API rate limiting
5. Update RLS policies to be more restrictive

## 📚 Resources
- [Supabase Security](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL RLS](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Android Security](https://developer.android.com/topic/security)
- [iOS Security](https://developer.apple.com/documentation/security)
- [Git Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## 🔄 Migration Security Improvements

### Enhanced Security with Supabase:
- **Open Source:** Full transparency into backend security
- **PostgreSQL:** More mature database security features
- **RLS:** Fine-grained row-level access controls
- **Self-hostable:** Option for complete data sovereignty
- **Built-in Auth:** Email verification, password policies, OAuth providers
