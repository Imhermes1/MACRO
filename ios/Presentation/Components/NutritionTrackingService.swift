import Foundation
import Combine

/// Service responsible for tracking user's nutrition progress and goals
@MainActor
class NutritionTrackingService: ObservableObject {
    struct Totals {
        var calories: Double
        var protein: Double
        var carbs: Double
        var fat: Double
    }
    struct Goals {
        var dailyCalories: Double
        var proteinGrams: Double
        var carbsGrams: Double
        var fatGrams: Double
    }
    
    @Published var todaysTotals: Totals
    @Published var goals: Goals
    
    init() {
        // Default demo values
        self.todaysTotals = Totals(calories: 1200, protein: 80, carbs: 150, fat: 40)
        self.goals = Goals(dailyCalories: 2000, proteinGrams: 150, carbsGrams: 250, fatGrams: 60)
    }
    
    func getCurrentStreak() throws -> Int {
        // Simple demo streak
        return 5
    }
    
    func getEntries(for date: Date) throws -> [Any] {
        // Demo stub: replace [Any] with your real entry type
        return ["Breakfast", "Lunch", "Snack"]
    }
}

