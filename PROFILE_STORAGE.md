# Profile Data Storage System

## Overview

The app now supports multiple cloud storage options with intelligent switching based on user preference and platform capabilities:

- **Local Storage**: UserDefaults (iOS) / SharedPreferences (Android) 
- **CloudKit**: Apple's native cloud service (iOS only)
- **Firebase**: Cross-platform cloud storage (iOS & Android)

## Storage Strategy by User Type

### Anonymous Users
- **Local Storage Only**: Profile data stored locally using UserDefaults/SharedPreferences
- **No Cloud Sync**: Data remains on device only
- **Use Case**: Demo users, privacy-conscious users, or users not ready to create accounts

### Authenticated Users (iOS)
Users can choose from three storage options:

#### 1. CloudKit (Recommended for iOS)
- **Native Integration**: Seamless with iOS ecosystem and iCloud
- **Automatic Sync**: Works across all user's Apple devices
- **Privacy**: Uses Apple ID, highly secure and private
- **No Setup**: Works automatically if user is signed into iCloud
- **Free**: Generous limits for personal use

#### 2. Firebase (Cross-Platform)
- **Multi-Platform**: Works across iOS, Android, web
- **Real-time Sync**: Fast synchronization
- **Authentication**: Requires Firebase account

#### 3. Local Only
- **Complete Privacy**: Data never leaves the device
- **No Internet Required**: Works entirely offline

### Authenticated Users (Android)
- **Firebase**: Primary cloud option
- **Local Only**: Privacy-focused alternative

## iOS Implementation Details

### CloudKit Integration (CloudKitUserProfileRepository.swift)
```swift
// Save profile to CloudKit + local backup
func saveProfile(_ profile: UserProfile)

// Load from CloudKit with local fallback
func loadProfile(completion: @escaping (UserProfile?) -> Void)

// Check iCloud account status
func checkCloudKitStatus(completion: @escaping (String) -> Void)
```

### Hybrid Repository (UserProfileRepository.swift)
```swift
// Set preferred cloud provider
func setCloudProvider(_ provider: CloudProvider)

// Get available providers based on device capabilities
func getAvailableCloudProviders(completion: @escaping ([CloudProvider]) -> Void)

// Automatic fallback between CloudKit → Firebase → Local
```

### User Choice Interface (CloudStorageSettingsView.swift)
- Settings UI to choose storage preference
- Real-time iCloud status checking
- Educational information about each option

## Security

### Firestore Security Rules
- Users can only access their own profile data (`/userProfiles/{userId}`)
- Authentication required for all cloud operations
- Anonymous users cannot access cloud storage

### Data Privacy
- Anonymous users: Complete privacy, no data leaves the device
- Authenticated users: Data encrypted in transit and at rest via Firebase security

## Migration Scenarios

### Anonymous → Authenticated
1. User creates account or signs in
2. System automatically calls `migrateLocalToCloud()`
3. Local profile data is uploaded to cloud
4. Future operations use cloud storage

### Account Switching
1. User signs out: Local data can be cleared using `clearLocalProfile()`
2. User signs in: Cloud data is downloaded and cached locally

## Error Handling

### Cloud Storage Failures
- App falls back to local storage
- User experience remains uninterrupted
- Background retry mechanism for cloud sync

### Offline Operation
- All operations work offline using local storage
- Cloud sync resumes when connection is restored

## Benefits

1. **Seamless Experience**: No interruption whether user is anonymous or authenticated
2. **Data Portability**: Authenticated users can switch devices without losing data
3. **Privacy Options**: Anonymous users keep complete privacy
4. **Reliability**: Local storage ensures app works offline
5. **Future-Proof**: Easy to add features like profile sharing, family accounts, etc.

## Usage Examples

### For Anonymous Users
```swift
// iOS
let repo = UserProfileRepository()
repo.saveProfile(profile) // Saves locally only
repo.loadProfile() // Returns local data only
```

### For Authenticated Users
```swift
// iOS
let repo = UserProfileRepository()
repo.saveProfile(profile) // Saves locally + cloud
repo.loadProfile { profile in 
    // Returns cloud data (with local fallback)
}
```

## Firebase Collections

### userProfiles
```
/userProfiles/{userId}
  ├── firstName: String
  ├── lastName: String?
  ├── age: Number
  ├── dob: String?
  ├── height: Number
  ├── weight: Number
  └── lastUpdated: Timestamp
```
