# Platform-Specific Cloud Storage Implementation

## 🚀 Migration Notice: Firebase → Supabase

**MACRO has migrated from Firebase to Supabase** for improved open-source infrastructure, PostgreSQL capabilities, and enhanced data sovereignty.

## iOS Cloud Storage Options

### Available Options:
1. **CloudKit (Recommended)** ☁️
   - Native iOS cloud service
   - Automatic sync across Apple devices
   - Uses Apple ID (no additional accounts)
   - Free with generous limits

2. **Supabase** 🚀
   - Open-source cross-platform cloud storage
   - PostgreSQL database with real-time features
   - Works with email, Google, and Apple ID accounts
   - Good for multi-platform users

3. **Local Only** 📱
   - Complete privacy
   - No internet required

### Implementation:
- **File**: `ios/Presentation/CloudStorageSettingsView.swift`
- **Service**: `ios/Data/SupabaseService.swift` (replaces FirebaseService)
- **Repository**: Enhanced `ios/Data/UserProfileRepository.swift`

## Android Cloud Storage Options

### Available Options:
1. **Supabase** 🚀
   - Primary cloud option for Android
   - Cross-platform compatibility
   - PostgreSQL-powered backend
   - Email, Google, and Apple authentication support

2. **Local Only** 📱
   - Complete privacy
   - No internet required

### What's NOT Available on Android:
❌ **CloudKit/iCloud** - This is iOS-only technology
❌ **Apple ID Integration** - Limited to Apple OAuth via Supabase

### Implementation:
- **Service**: `android/app/src/main/java/com/lumoralabs/macro/data/SupabaseService.kt`
- **Repository**: `android/app/src/main/java/com/lumoralabs/macro/data/UserProfileRepository.kt`
- **No CloudKit Dependencies**: Android code is completely separate from iOS CloudKit implementation

## Key Migration Changes

### ✅ Supabase Integration:
1. **Authentication**: Email + OAuth providers (Google, Apple)
2. **Database**: PostgreSQL with Row Level Security (RLS)
3. **Real-time**: Live data synchronization capabilities
4. **Open Source**: Self-hostable and transparent

### ✅ Platform Separation:
- **iOS Users**: Can choose between CloudKit (native) or Supabase (cross-platform)
- **Android Users**: Only see relevant options (Supabase or Local)
- **No Confusion**: Platform-specific interfaces prevent inappropriate options

## Code Structure

```
ios/
├── Data/
│   ├── CloudKitProfileService.swift         // iOS CloudKit integration
│   ├── CloudKitUserProfileRepository.swift  // Pure CloudKit option
│   ├── SupabaseService.swift               // Supabase integration (NEW)
│   └── UserProfileRepository.swift         // Multi-provider (CloudKit + Supabase)
└── Presentation/
    └── CloudStorageSettingsView.swift      // iOS cloud settings UI

android/
├── data/
│   ├── SupabaseService.kt                  // Supabase integration (NEW)
│   └── UserProfileRepository.kt            // Supabase + Local only
└── presentation/
    ├── SettingsActivity.kt                // Basic settings (no cloud options)
    └── LoginActivity.kt                   // Email + OAuth (supports Google/Apple via Supabase)

Configuration/
├── supabase.config                         // Supabase project configuration
├── supabase_schema.sql                     // Database schema
├── supabase_policies.sql                   // Security policies
└── firestore.rules.bak                     // Backup of old Firebase rules
```

## Security & Privacy

### iOS:
- **CloudKit**: Uses Apple's privacy-first approach
- **Supabase**: Open-source with Row Level Security (RLS)
- **User Choice**: Can select most private option

### Android:
- **Supabase**: PostgreSQL with robust security policies
- **Local Option**: Complete privacy for sensitive users
- **Authentication**: Email, Google OAuth, Apple OAuth support

## Setup Requirements

### Supabase Configuration:
1. Create project at [Supabase Dashboard](https://supabase.com/dashboard)
2. Configure authentication providers (Email, Google, Apple)
3. Run database migrations from `supabase_schema.sql`
4. Apply security policies from `supabase_policies.sql`
5. Update configuration in `supabase.config`

This ensures each platform provides the most appropriate and native cloud storage experience while maintaining complete separation between iOS and Android implementations, now powered by Supabase's open-source infrastructure.
