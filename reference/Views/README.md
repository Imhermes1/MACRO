# Views Folder Documentation

This folder contains all the SwiftUI views for the CoreTrack calorie tracking app. The views are organized by functionality and complexity.

## 📱 Core App Views

### `ContentView.swift` (25 lines)
**Purpose**: Main app entry point and environment object setup
- Sets up environment objects (FoodDataManager, OpenAIService, NotificationManager)
- Wraps MainView with proper environment context
- Simple container view for app initialization

### `MainView.swift` (138 lines)
**Purpose**: Main app interface with custom glass tab bar
- **GlassCard**: Reusable glassmorphism card modifier
- **GlowOverlay**: Animated glow effect for voice recording
- **MainView**: Primary app interface with 5-tab navigation
- Custom glass tab bar with home, coach, voice, shop, more tabs
- Background gradient and glassmorphism design

## 🍽️ Food Entry & Management

### `AddFoodView.swift` (273 lines) - **LARGE FILE**
**Purpose**: Primary food entry interface with AI chat and voice input
- **VisualEffectBlur**: UIKit blur effect wrapper
- **AddFoodView**: Main food entry view with:
  - AI chat interface for food logging
  - Voice transcription and processing
  - Camera integration (placeholder)
  - Real-time chat with nutrition analysis
  - Meal composition and macro breakdown

### `SimpleMealEntryView.swift` (68 lines)
**Purpose**: Compact meal display component
- Displays individual meal entries with macros
- Glassmorphism design with rounded corners
- Shows calories, protein, carbs, fat with icons
- Used in meal lists and summaries

### `TextInputView.swift` (56 lines)
**Purpose**: Simple text input modal for food descriptions
- Modal text input with submit/cancel actions
- Used for manual food entry
- Clean, minimal interface

## 📊 Data Display & Charts

### `DailySummaryView.swift` (213 lines)
**Purpose**: Today's nutrition summary with progress tracking
- **DailySummaryView**: Main summary with calorie progress
- **MacroView**: Individual macro nutrient display
- **CalorieProgressView**: Circular progress indicator
- **DailySummaryCompactView**: Alternative compact layout
- Shows daily totals, progress toward goals, macro breakdown

### `NutritionView.swift` (351 lines) - **LARGE FILE**
**Purpose**: Comprehensive nutrition analysis and trends
- **NutritionView**: Main nutrition analysis interface
- Time range selection (day/week/month)
- Date navigation and selection
- Integration with charts and meal lists
- **TimeRange**: Enum for different time periods

### `NutritionSummaryView.swift` (109 lines)
**Purpose**: Detailed nutrition summary with glassmorphism design
- Displays macro totals in cards
- Shows meal list for selected time period
- Glassmorphism background styling
- Used within NutritionView

### `CalorieTrendChart.swift` (48 lines)
**Purpose**: Line chart for calorie trends over time
- Uses SwiftUI Charts framework
- Shows calorie intake over selected time period
- Configurable for day/week/month views

### `MacroDistributionChart.swift` (64 lines)
**Purpose**: Donut chart for macro nutrient distribution
- Pie chart showing protein/carbs/fat ratios
- Color-coded sectors for each macro
- Used in nutrition analysis

## 🎯 AI & Smart Features

### `AICoachView.swift` (289 lines) - **LARGE FILE**
**Purpose**: AI-powered nutrition coaching interface
- **AICoachView**: Main AI coach interface
- **AdviceCard**: Reusable advice display component
- Personalized nutrition advice based on eating patterns
- Goal setting and progress tracking
- Integration with OpenAI service

### `VoiceMealPlannerView.swift` (327 lines) - **LARGE FILE**
**Purpose**: Voice-controlled meal planning
- **MealType**: Enum for breakfast/lunch/dinner/snack
- **VoiceMealPlannerView**: Voice meal planning interface
- Voice command processing for meal planning
- Planned meal display and management
- Integration with speech recognition

### `SmartGroceryView.swift` (419 lines) - **LARGE FILE**
**Purpose**: AI-generated grocery shopping lists
- **SmartGroceryView**: Smart grocery list interface
- **GroceryItemRow**: Individual grocery item display
- **AddGroceryItemView**: Manual grocery item addition
- Generates shopping lists based on eating patterns
- Category filtering and organization
- Integration with meal planning data

## 📋 Meal Management

### `TodaysMealsView.swift` (1130 lines) - **LARGEST FILE**
**Purpose**: Comprehensive meal management and display
- **CompositeMealEntryView**: Complex meal entry with sub-items
- **EditMode**: Enum for different edit states
- Meal composition with multiple food items
- Edit and delete functionality
- Nutrition data editing
- Context menus and confirmation dialogs
- **NEEDS REFACTORING** - Too large and complex

### `MealRowView.swift` (344 lines) - **LARGE FILE**
**Purpose**: Individual meal row display with expandable details
- **MealRowView**: Main meal row component
- **MacroNutrientView**: Macro display component
- Expandable meal details
- Long press gestures and animations
- Macro percentage calculations
- Edit/delete action buttons

## ⚙️ Settings & Configuration

### `SettingsView.swift` (201 lines) - **LARGE FILE**
**Purpose**: App settings and user preferences
- **SettingsView**: Main settings interface
- **TimePickerView**: Time selection component
- Calorie goal setting with slider
- Reminder time configuration
- Glassmorphism design consistent with app theme

## 🎨 UI Components

### `NutritionCard.swift` (46 lines)
**Purpose**: Reusable nutrition metric card
- Displays nutrition values with title, value, unit, color
- Used throughout app for consistent nutrition display
- Glassmorphism styling

### `ImagePicker.swift` (65 lines)
**Purpose**: Camera and photo library integration
- **ImagePicker**: UIKit wrapper for image selection
- **Coordinator**: Delegate for image picker
- Camera and photo library support
- Used for food photo logging (placeholder feature)

## 📈 Data Confidence & Accuracy

### `NutritionConfidenceView.swift` (268 lines) - **LARGE FILE**
**Purpose**: Nutrition data accuracy assessment
- **NutritionConfidenceView**: Main confidence display
- **AccuracyFactorRow**: Individual accuracy factor
- **NutritionAccuracyCard**: Comprehensive accuracy card
- Confidence level visualization
- Australian-specific data indicators
- Accuracy factor breakdown

## 🗂️ Suggested Organization

### Current Issues:
1. **TodaysMealsView.swift** (1130 lines) - Too large, needs splitting
2. Several large files could benefit from component extraction
3. Some views have overlapping functionality

### Recommended Structure:
```
Views/
├── Core/
│   ├── ContentView.swift
│   ├── MainView.swift
│   └── TabBar/
├── FoodEntry/
│   ├── AddFoodView.swift
│   ├── SimpleMealEntryView.swift
│   └── TextInputView.swift
├── DataDisplay/
│   ├── DailySummaryView.swift
│   ├── NutritionView.swift
│   ├── Charts/
│   │   ├── CalorieTrendChart.swift
│   │   └── MacroDistributionChart.swift
│   └── Components/
│       ├── NutritionCard.swift
│       └── NutritionSummaryView.swift
├── AI/
│   ├── AICoachView.swift
│   ├── VoiceMealPlannerView.swift
│   └── SmartGroceryView.swift
├── Meals/
│   ├── TodaysMealsView.swift (needs splitting)
│   ├── MealRowView.swift
│   └── Components/
├── Settings/
│   └── SettingsView.swift
├── Utils/
│   ├── ImagePicker.swift
│   └── NutritionConfidenceView.swift
└── README.md
```

### Priority Refactoring:
1. **Split TodaysMealsView.swift** into smaller components
2. Extract reusable components from large files
3. Create shared UI components library
4. Standardize glassmorphism styling across views 