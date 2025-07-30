# MACRO App Development TODO List 📱

## Next Session Priorities

### 🔧 Technical Fixes
- [ ] **Debug profile save crash**: Investigate why app sometimes crashes after saving profile
- [ ] **Fix compile errors**: Resolve `UserProfile`, `UserProfileRepository`, and `UIApplication` scope issues in iOS
- [ ] **Test navigation flow**: Ensure profile → BMI → main app navigation works smoothly
- [ ] **Implement missing login methods**: Add actual Google Sign-In and email login functionality

### 🎨 UI/UX Improvements
- [ ] **Add app icon**: Create and add proper app icons for both iOS and Android
- [ ] **Set accent color**: Choose and implement accent color in asset catalogs
- [ ] **Test logo animation**: Verify the animated glow effect works on both platforms
- [ ] **Improve keyboard handling**: Ensure Done buttons work consistently across all text fields

### 🚀 Feature Implementation
- [ ] **Complete BMI Calculator**: Fix any issues with BMI calculation and display
- [ ] **Main app functionality**: Implement core nutrition tracking features
- [ ] **Firebase integration**: Complete Google Sign-In and anonymous auth setup
- [ ] **Data persistence**: Ensure profile data saves and loads correctly

### 🧪 Testing & QA
- [ ] **Test on real devices**: Verify UI looks good on different screen sizes
- [ ] **Test login flows**: Ensure all login methods work (anonymous, Google, email)
- [ ] **Profile data validation**: Test edge cases for profile setup
- [ ] **Cross-platform consistency**: Ensure iOS and Android behave similarly

### 📱 Platform-Specific
#### iOS
- [ ] Fix Xcode project configuration for asset catalog
- [ ] Ensure proper SwiftUI navigation between views
- [ ] Test Firebase configuration with GoogleService-Info.plist

#### Android
- [ ] Verify navigation between activities works smoothly
- [ ] Test Firebase configuration with google-services.json
- [ ] Ensure Material 3 design consistency

### 🔐 Security & Performance
- [ ] **Environment variables**: Move sensitive Firebase config to environment variables
- [ ] **Error handling**: Add comprehensive error handling throughout the app
- [ ] **Loading states**: Improve loading indicators and user feedback
- [ ] **Offline handling**: Plan for offline functionality

## Completed This Session ✅
- ✅ Enhanced login screens with cleaner UI (removed email/password fields)
- ✅ Added Lumora Labs logo with animated glow effect
- ✅ Improved profile setup layout with centered headers
- ✅ Added DOB incentive popup with red exclamation button
- ✅ Enhanced keyboard handling with Done buttons
- ✅ Fixed background gradient (blue-green with glass effect)
- ✅ Added proper asset management for both platforms
- ✅ Improved error handling in profile save functionality

## Notes for Next Session 📝
- Firebase configuration files are now properly placed
- Asset catalogs need proper setup in Xcode
- Main focus should be on fixing compile errors and testing the complete user flow
- Consider implementing a proper state management solution for navigation
