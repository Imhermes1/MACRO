import Foundation
import Combine

/// Service for tracking nutrition data and providing daily summaries
@MainActor
class NutritionTrackingService: ObservableObject {
    @Published var todaysTotals: DailyTotals = DailyTotals()
    @Published var goals: NutritionGoals = NutritionGoals()
    @Published var entries: [NutritionData] = []
    
    init() {
        // Load any saved data
        loadTodaysData()
        loadGoals()
    }
    
    // MARK: - Data Management
    
    func addEntry(_ entry: NutritionData) {
        entries.append(entry)
        updateTodaysTotals()
    }
    
    func getEntries(for date: Date) throws -> [NutritionData] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getCurrentStreak() throws -> Int {
        // Simple mock implementation - in a real app, this would calculate actual streak
        return 7
    }
    
    private func loadTodaysData() {
        // Load today's entries
        let today = Date()
        let calendar = Calendar.current
        entries = entries.filter { calendar.isDate($0.date, inSameDayAs: today) }
        updateTodaysTotals()
    }
    
    private func loadGoals() {
        // Load saved goals or use defaults
        goals = NutritionGoals(
            dailyCalories: UserDefaults.standard.double(forKey: "calorie_goal") > 0 ? 
                UserDefaults.standard.double(forKey: "calorie_goal") : 2000,
            proteinGrams: 150,
            carbsGrams: 200,
            fatGrams: 70
        )
    }
    
    private func updateTodaysTotals() {
        let today = Date()
        let calendar = Calendar.current
        let todaysEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: today) }
        
        todaysTotals = DailyTotals(
            calories: todaysEntries.reduce(0) { $0 + $1.calories },
            protein: todaysEntries.reduce(0) { $0 + $1.protein },
            carbs: todaysEntries.reduce(0) { $0 + $1.carbs },
            fat: todaysEntries.reduce(0) { $0 + $1.fat }
        )
    }
}

// MARK: - Supporting Models

struct DailyTotals {
    var calories: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
}

struct NutritionGoals {
    var dailyCalories: Double = 2000
    var proteinGrams: Double = 150
    var carbsGrams: Double = 200
    var fatGrams: Double = 70
}
