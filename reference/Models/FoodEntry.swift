//
//  FoodEntry.swift
//  Calorie Tracker By Luke
//
//  Created by Luke Fornieri on 11/6/2025.
//

import Foundation

// MARK: - Food Entry Model
struct FoodEntry: Identifiable, Codable {
    let id: UUID
    let userID: String // New: user identifier for cloud sync
    let timestamp: Date
    let description: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let inputMethod: InputMethod
    var confidence: Double? // Optional confidence value for nutrition accuracy
    
    /// Optional child entries for composite meals (e.g., burger, fries, drink in a meal)
    var subItems: [FoodEntry]?
    
    /// Type of food item (main, side, drink, etc.)
    var itemType: ItemType = .standalone
    
    /// Optional group ID for items entered together as a meal
    var mealGroupId: UUID?

    // Optional detailed nutrition fields (for future use, not displayed by default)
    var sugar: Double?
    var fibre: Double?
    var saturatedFat: Double?
    var sodium: Double?
    var cholesterol: Double?
    
    init(
        id: UUID = UUID(),
        userID: String = "localUser", // Default for now
        timestamp: Date,
        description: String,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        inputMethod: InputMethod,
        confidence: Double? = nil, // Initialize confidence
        subItems: [FoodEntry]? = nil,
        itemType: ItemType = .standalone,
        mealGroupId: UUID? = nil,
        sugar: Double? = nil,
        fibre: Double? = nil,
        saturatedFat: Double? = nil,
        sodium: Double? = nil,
        cholesterol: Double? = nil
    ) {
        self.id = id
        self.userID = userID
        self.timestamp = timestamp
        self.description = description
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.inputMethod = inputMethod
        self.confidence = confidence
        self.subItems = subItems
        self.itemType = itemType
        self.mealGroupId = mealGroupId
        self.sugar = sugar
        self.fibre = fibre
        self.saturatedFat = saturatedFat
        self.sodium = sodium
        self.cholesterol = cholesterol
    }
    
    enum CodingKeys: String, CodingKey {
        case id, userID, timestamp, description, calories, protein, carbs, fat, inputMethod, confidence, subItems, itemType, mealGroupId, sugar, fibre, saturatedFat, sodium, cholesterol
    }
    
    enum InputMethod: String, Codable, CaseIterable {
        case speech = "speech"
        case image = "image"
        case text = "text"
        
        var displayName: String {
            switch self {
            case .speech:
                return "Speech"
            case .image:
                return "Image"
            case .text:
                return "Text"
            }
        }
        
        var iconName: String {
            switch self {
            case .speech:
                return "mic"
            case .image:
                return "camera"
            case .text:
                return "keyboard"
            }
        }
    }
    
    enum ItemType: String, Codable {
        case standalone = "standalone"
        case meal = "meal"
        case mainItem = "mainItem"
        case side = "side"
        case drink = "drink"
        
        var icon: String {
            switch self {
            case .standalone, .mainItem:
                return "fork.knife"
            case .meal:
                return "bag"
            case .side:
                return "leaf"
            case .drink:
                return "cup.and.saucer"
            }
        }
    }
}

// MARK: - Computed Properties
extension FoodEntry {
    /// Total macronutrients in grams
    var totalMacros: Double {
        return protein + carbs + fat
    }
    
    /// Formatted time string
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    /// Formatted date string
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
    
    /// Check if entry is from today
    var isToday: Bool {
        Calendar.current.isDateInToday(timestamp)
    }
    
    /// Check if this is a composite meal
    var isCompositeMeal: Bool {
        print("[DEBUG] Checking isCompositeMeal for entry \(description). subItems is \(String(describing: subItems))")
        return subItems != nil && !subItems!.isEmpty
    }
    
    /// Get total calories including sub-items
    var totalCalories: Double {
        print("[DEBUG] Calculating totalCalories for \(description). subItems is \(String(describing: subItems))")
        if let subItems = subItems {
            return subItems.reduce(0) { $0 + $1.calories }
        }
        return calories
    }
    
    /// Get total protein including sub-items
    var totalProtein: Double {
        print("[DEBUG] Calculating totalProtein for \(description). subItems is \(String(describing: subItems))")
        if let subItems = subItems {
            return subItems.reduce(0) { $0 + $1.protein }
        }
        return protein
    }
    
    /// Get total carbs including sub-items
    var totalCarbs: Double {
        print("[DEBUG] Calculating totalCarbs for \(description). subItems is \(String(describing: subItems))")
        if let subItems = subItems {
            return subItems.reduce(0) { $0 + $1.carbs }
        }
        return carbs
    }
    
    /// Get total fat including sub-items
    var totalFat: Double {
        print("[DEBUG] Calculating totalFat for \(description). subItems is \(String(describing: subItems))")
        if let subItems = subItems {
            return subItems.reduce(0) { $0 + $1.fat }
        }
        return fat
    }
    
    /// Get a display description for composite meals
    var displayDescription: String {
        // Always use the main description, not the sub-items
        return description
    }
    
    /// Get item count for display
    var itemCount: Int {
        print("[DEBUG] Getting itemCount for \(description). subItems is \(String(describing: subItems))")
        return subItems?.count ?? 1
    }
    
    /// Get a meal name from the components
    var mealName: String {
        print("[DEBUG] Getting mealName for \(description). subItems is \(String(describing: subItems))")
        if isCompositeMeal, let mainItem = subItems?.first(where: { $0.itemType == .mainItem }) {
            // If it's a composite meal, create a nice name based on the main item
            let baseName = mainItem.description
                .replacingOccurrences(of: "cooked ", with: "")
                .replacingOccurrences(of: "Cooked ", with: "")
            
            // Check if we have all typical meal components
            let hasFries = subItems?.contains(where: { $0.itemType == .side && $0.description.lowercased().contains("fries") }) ?? false
            let hasDrink = subItems?.contains(where: { $0.itemType == .drink }) ?? false
            
            if hasFries && hasDrink {
                return "\(baseName) Meal"
            } else if hasFries {
                return "\(baseName) with Fries"
            } else if hasDrink {
                return "\(baseName) with Drink"
            } else {
                return baseName
            }
        }
        return description
    }
}

// MARK: - Factory Methods
extension FoodEntry {
    /// Create a composite meal from components
    static func createMeal(
        mainItem: FoodEntry,
        side: FoodEntry? = nil,
        drink: FoodEntry? = nil,
        inputMethod: InputMethod,
        timestamp: Date = Date()
    ) -> FoodEntry {
        var subItems: [FoodEntry] = []
        
        // Add main item with correct type
        var main = mainItem
        main.itemType = .mainItem
        subItems.append(main)
        
        // Add side with correct type
        if let side = side {
            var sideItem = side
            sideItem.itemType = .side
            subItems.append(sideItem)
        }
        
        // Add drink with correct type
        if let drink = drink {
            var drinkItem = drink
            drinkItem.itemType = .drink
            subItems.append(drinkItem)
        }
        
        // Calculate totals from sub-items
        let totalCalories = subItems.reduce(0) { $0 + $1.calories }
        let totalProtein = subItems.reduce(0) { $0 + $1.protein }
        let totalCarbs = subItems.reduce(0) { $0 + $1.carbs }
        let totalFat = subItems.reduce(0) { $0 + $1.fat }
        
        // Generate a proper meal name
        let mealName: String
        if let main = subItems.first {
            let baseName = main.description
                .replacingOccurrences(of: "cooked ", with: "")
                .replacingOccurrences(of: "Cooked ", with: "")
            
            if let _ = side, let _ = drink {
                mealName = "\(baseName) Meal"
            } else if let side = side {
                mealName = "\(baseName) with \(side.description)"
            } else if let drink = drink {
                mealName = "\(baseName) with \(drink.description)"
            } else {
                mealName = baseName
            }
        } else {
            mealName = "Meal"
        }
        
        return FoodEntry(
            id: UUID(),
            timestamp: timestamp,
            description: mealName,
            calories: totalCalories,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat,
            inputMethod: inputMethod,
            subItems: subItems,
            itemType: .meal,
            mealGroupId: nil
        )
    }
}

// MARK: - Sample Data (for previews/testing)
#if DEBUG
extension FoodEntry {
    static let sampleBurger = FoodEntry(
        id: UUID(),
        timestamp: Date(),
        description: "Big Mac",
        calories: 550,
        protein: 25,
        carbs: 45,
        fat: 30,
        inputMethod: .text,
        itemType: .mainItem
    )
    
    static let sampleFries = FoodEntry(
        id: UUID(),
        timestamp: Date(),
        description: "Large Fries",
        calories: 560,
        protein: 6,
        carbs: 70,
        fat: 30,
        inputMethod: .text,
        itemType: .side
    )
    
    static let sampleDrink = FoodEntry(
        id: UUID(),
        timestamp: Date(),
        description: "Large Coke",
        calories: 290,
        protein: 0,
        carbs: 75,
        fat: 0,
        inputMethod: .text,
        itemType: .drink
    )
    
    static let sampleMeal = FoodEntry.createMeal(
        mainItem: sampleBurger,
        side: sampleFries,
        drink: sampleDrink,
        inputMethod: .text
    )
    
    static let sampleEntries: [FoodEntry] = [
        sampleMeal,
        FoodEntry(
            id: UUID(),
            timestamp: Date().addingTimeInterval(-3600),
            description: "Chicken Salad",
            calories: 350,
            protein: 30,
            carbs: 15,
            fat: 20,
            inputMethod: .speech
        ),
        FoodEntry(
            id: UUID(),
            timestamp: Date().addingTimeInterval(-7200),
            description: "Protein Shake",
            calories: 200,
            protein: 25,
            carbs: 10,
            fat: 5,
            inputMethod: .text
        )
    ]
    
    static let sampleEntry = sampleEntries[0]
}
#endif

