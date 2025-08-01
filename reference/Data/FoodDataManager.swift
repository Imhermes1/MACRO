//
//  FoodDataManager.swift
//  Calorie Tracker By Luke
//
//  Created by Luke Fornieri on 11/6/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Food Data Manager
@MainActor
class FoodDataManager: ObservableObject {
    @Published var foodEntries: [FoodEntry] = []
    var currentUserID: String = "localUser" // For future user auth/cloud sync
    var currentUserName: String = "Luke" // Hardcoded for now for personalization
    
    private let userDefaults = UserDefaults.standard
    private let entriesKey = "FoodEntries"
    
    // MARK: - Caching
    private var cachedTodaysEntries: [FoodEntry] = []
    private var lastCacheDate: Date?
    private var cachedTotals: (calories: Double, protein: Double, carbs: Double, fat: Double)?
    private var lastTotalsCalculation: Date?
    
    // MARK: - Initialization`
    init() {
        loadEntries()
    }
    
    // MARK: - CRUD Operations
    
    /// Add a new food entry
    func addEntry(_ entry: FoodEntry) {
        foodEntries.append(entry)
        invalidateCache()
        saveEntries()
    }
    
    /// Delete a food entry
    func deleteEntry(_ entry: FoodEntry) {
        foodEntries.removeAll { $0.id == entry.id }
        invalidateCache()
        saveEntries()
    }
    
    /// Update an existing food entry
    func updateEntry(_ entry: FoodEntry) {
        if let index = foodEntries.firstIndex(where: { $0.id == entry.id }) {
            foodEntries[index] = entry
            invalidateCache()
            saveEntries()
        }
    }
    
    /// Delete multiple entries
    func deleteEntries(at offsets: IndexSet) {
        foodEntries.remove(atOffsets: offsets)
        invalidateCache()
        saveEntries()
    }
    
    /// Clear all entries
    func clearAllEntries() {
        foodEntries.removeAll()
        invalidateCache()
        saveEntries()
    }
    
    // MARK: - Cache Management
    private func invalidateCache() {
        lastCacheDate = nil
        cachedTotals = nil
        lastTotalsCalculation = nil
    }
    
    // MARK: - Query Methods
    
    /// Get entries for today (for current user) - Cached
    func getTodaysEntries() -> [FoodEntry] {
        let today = Date()
        
        // Check if cache is valid
        if let lastCache = lastCacheDate, 
           Calendar.current.isDate(lastCache, inSameDayAs: today) {
            return cachedTodaysEntries
        }
        
        // Rebuild cache
        let calendar = Calendar.current
        cachedTodaysEntries = foodEntries.filter { 
            $0.userID == currentUserID && calendar.isDateInToday($0.timestamp) 
        }
        lastCacheDate = today
        
        return cachedTodaysEntries
    }
    
    /// Get entries for a specific date (for current user)
    func getEntries(for date: Date) -> [FoodEntry] {
        let calendar = Calendar.current
        return foodEntries.filter { $0.userID == currentUserID && calendar.isDate($0.timestamp, inSameDayAs: date) }
    }
    
    /// Get entries for a date range (for current user)
    func getEntries(from startDate: Date, to endDate: Date) -> [FoodEntry] {
        return foodEntries.filter { $0.userID == currentUserID && $0.timestamp >= startDate && $0.timestamp <= endDate }
    }
    
    /// Get entries for the current week (for current user)
    func getThisWeeksEntries() -> [FoodEntry] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else {
            return []
        }
        return getEntries(from: weekInterval.start, to: weekInterval.end)
    }
    
    /// Get entries for the current month (for current user)
    func getThisMonthsEntries() -> [FoodEntry] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: Date()) else {
            return []
        }
        return getEntries(from: monthInterval.start, to: monthInterval.end)
    }
    
    // MARK: - Calculation Methods
    
    /// Get today's nutritional totals - Cached
    func getTodaysTotals() -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        let now = Date()
        
        // Check if cache is valid (within last 5 minutes and same day)
        if let lastCalc = lastTotalsCalculation,
           let cached = cachedTotals,
           Calendar.current.isDate(lastCalc, inSameDayAs: now),
           now.timeIntervalSince(lastCalc) < 300 { // 5 minutes
            return cached
        }
        
        // Recalculate and cache
        let totals = calculateTotals(for: getTodaysEntries())
        cachedTotals = totals
        lastTotalsCalculation = now
        
        return totals
    }
    
    /// Get nutritional totals for a specific date
    func getTotals(for date: Date) -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        return calculateTotals(for: getEntries(for: date))
    }
    
    /// Calculate totals for a set of entries
    private func calculateTotals(for entries: [FoodEntry]) -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        return entries.reduce((calories: 0, protein: 0, carbs: 0, fat: 0)) { totals, entry in
            (
                calories: totals.calories + entry.calories,
                protein: totals.protein + entry.protein,
                carbs: totals.carbs + entry.carbs,
                fat: totals.fat + entry.fat
            )
        }
    }
    
    /// Get average daily intake for the past N days
    func getAverageDailyIntake(days: Int = 7) -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            return (0, 0, 0, 0)
        }
        
        let entries = getEntries(from: startDate, to: endDate)
        let totals = calculateTotals(for: entries)
        
        let dayCount = Double(days)
        return (
            calories: totals.calories / dayCount,
            protein: totals.protein / dayCount,
            carbs: totals.carbs / dayCount,
            fat: totals.fat / dayCount
        )
    }
    
    // MARK: - Statistics
    
    /// Get streak of consecutive days with logged meals
    func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while true {
            if !getEntries(for: currentDate).isEmpty {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else {
                break
            }
        }
        
        return streak
    }
    
    /// Get most consumed foods (for current user)
    func getMostConsumedFoods(limit: Int = 5) -> [(description: String, count: Int)] {
        let foodCounts = foodEntries.filter { $0.userID == currentUserID }.reduce(into: [String: Int]()) { counts, entry in
            counts[entry.description, default: 0] += 1
        }
        
        return foodCounts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { (description: $0.key, count: $0.value) }
    }
    
    // MARK: - Persistence
    
    /// Save entries to UserDefaults
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(foodEntries) {
            userDefaults.set(encoded, forKey: entriesKey)
        }
    }
    
    /// Load entries from UserDefaults
    private func loadEntries() {
        if let data = userDefaults.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([FoodEntry].self, from: data) {
            foodEntries = decoded
        }
    }
    
    /// Export data as JSON
    func exportData() -> Data? {
        return try? JSONEncoder().encode(foodEntries)
    }
    
    /// Import data from JSON
    func importData(from data: Data) -> Bool {
        guard let entries = try? JSONDecoder().decode([FoodEntry].self, from: data) else {
            return false
        }
        foodEntries = entries
        saveEntries()
        return true
    }
    
    // MARK: - Debug/Testing
    
    #if DEBUG
    /// Add sample data for testing
    func addSampleData() {
        let sampleEntries = [
            FoodEntry(
                timestamp: Date(),
                description: "Chicken Breast with Rice",
                calories: 450,
                protein: 40,
                carbs: 50,
                fat: 8,
                inputMethod: .text
            ),
            FoodEntry(
                timestamp: Date().addingTimeInterval(-3600),
                description: "Greek Yogurt with Berries",
                calories: 200,
                protein: 20,
                carbs: 25,
                fat: 3,
                inputMethod: .speech
            ),
            FoodEntry(
                timestamp: Date().addingTimeInterval(-7200),
                description: "Avocado Toast",
                calories: 320,
                protein: 8,
                carbs: 35,
                fat: 18,
                inputMethod: .image
            )
        ]
        
        foodEntries.append(contentsOf: sampleEntries)
        saveEntries()
    }
    
    /// Clear all data (for testing)
    func clearAllDataForTesting() {
        clearAllEntries()
    }
    #endif
    
    // MARK: - Additional Properties for Settings
    
    /// Get number of days tracked
    var daysTracked: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(foodEntries.map { calendar.startOfDay(for: $0.timestamp) })
        return uniqueDays.count
    }
    
    /// Get total calories across all entries
    var totalCalories: Int {
        return Int(foodEntries.reduce(0) { $0 + $1.calories })
    }
    
    /// Get data size in KB
    var dataSize: String {
        if let data = try? JSONEncoder().encode(foodEntries) {
            let sizeInKB = Double(data.count) / 1024.0
            return String(format: "%.1f KB", sizeInKB)
        }
        return "0 KB"
    }
    
    /// Backup to iCloud (placeholder for future implementation)
    func backupToiCloud() {
        // TODO: Implement iCloud backup
        print("iCloud backup would be implemented here")
    }
}

// MARK: - Preview Helper
#if DEBUG
extension FoodDataManager {
    static var preview: FoodDataManager {
        let manager = FoodDataManager()
        manager.addSampleData()
        return manager
    }
}
#endif

