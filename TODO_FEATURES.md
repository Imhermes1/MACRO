# Macro App: Major Feature Roadmap & Known Issues

## 1. [BUG] Input bar placement is wrong when opening keyboard and when Pro Tip is displayed.
- The keyboard sometimes gets thrown off the top of the screen.
- Need to refactor keyboard height handling and overlay stacking to ensure input bar and tip are always visible above the keyboard, never occluded or misplaced.
- Consider using GeometryReader or safe area insets for more robust layout.
- Test on all device sizes and orientations.

## 2. [CORE] Implement food logic and AI/database logging.
- Find the best way to use 2 systems (AI + database) to ensure food logging is as accurate as possible.
- Consider hybrid approach: AI for parsing/understanding, database for validation and nutrition lookup.
- Ensure at least 95% accuracy before expanding features.

## 3. [UI/UX] Add barcode and photo to extra function in input bar (+ button).
- Make photo button work.
- Implement alpha version of food detection (after food analysis is 95%+ accurate).
- Wire up settings button for user preferences.

## 4. [COACH] Draft Nutrition Coach (or similar name).
- Personalized feedback, tips, and progress tracking.
- Integrate with chat and meal planner.

## 5. [PLANNER] Meal planner and smart shopping list.
- Integrate with DoorDash, Uber Eats, Woolworths, Coles APIs for real-world ordering.
- Suggest meals based on nutrition goals and inventory.

## 6. [UPLOAD] PDF upload, image-to-text recognition from influencers and doctors.
- Add disclaimer for doctor uploads.
- Use OCR for extracting nutrition info from images and PDFs.

## 7. [SYMPTOMS] Symptom analysis and suggestions with disclaimers.
- Allow users to log symptoms, get AI-driven suggestions, always with medical disclaimer.

## 8. [NOTIFICATIONS] Notification system for reminders, tips, and progress.
- Push notifications for meal times, hydration, and goals.

## 9. [PAYWALL] Paywall system for premium features.
- Subscription management, feature gating, and onboarding for paid users.

---

## **Additional Suggestions**

- **Integrate Apple HealthKit and Google Fit for automatic nutrition/activity sync.**
- **Add voice-based food logging with real-time transcription and correction.**
- **Implement streaks, achievements, and gamification to boost engagement.**
- **Enable family/group meal planning and shared shopping lists.**
- **Add AI-powered recipe suggestions based on pantry and dietary restrictions.**
- **Integrate with wearable devices for real-time biometrics and adaptive nutrition advice.**
- **Add in-app chat support for nutritionist consultations.**
- **Implement advanced analytics dashboard for macro/micro tracking and trends.**
- **Support for multiple languages and localization.**
- **Accessibility improvements: voiceover, high-contrast, and dyslexia-friendly modes.**
- **Export data to CSV/PDF for sharing with healthcare providers.**
